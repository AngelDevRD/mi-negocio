import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../inventory/data/datasources/inventory_local_datasource.dart';

/// Ítem de entrada para [SalesLocalDatasource.registrarVenta].
class VentaItemEntrada {
  const VentaItemEntrada({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitarioCents,
  });

  final String productoId;
  final double cantidad;
  final int precioUnitarioCents;
}

/// Acceso a `ventas`/`venta_items` (RF-VEN) y a la apertura mínima de
/// `caja_sesiones` (RN-01).
class SalesLocalDatasource {
  SalesLocalDatasource(this._db);

  final AppDatabase _db;

  /// Id de la sesión de caja abierta, si hay una (RN-01).
  Future<String?> obtenerCajaAbiertaId() async {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta));
    final sesion = await query.getSingleOrNull();
    return sesion?.id;
  }

  /// `true` si existe un producto activo (no eliminado) con ese id.
  Future<bool> existeProducto(String id) async {
    final query = _db.select(_db.productos)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return await query.getSingleOrNull() != null;
  }

  /// Ventas con el nombre del usuario, más reciente primero.
  Stream<List<(Venta, String)>> watchVentas({
    EstadoVenta? estado,
    DateTime? desde,
    DateTime? hasta,
  }) {
    final query = _db.select(_db.ventas).join([
      innerJoin(_db.usuarios, _db.usuarios.id.equalsExp(_db.ventas.usuarioId)),
    ])..orderBy([OrderingTerm.desc(_db.ventas.fecha)]);

    if (estado != null) {
      query.where(_db.ventas.estado.equalsValue(estado));
    }
    if (desde != null) {
      query.where(_db.ventas.fecha.isBiggerOrEqualValue(desde));
    }
    if (hasta != null) {
      query.where(_db.ventas.fecha.isSmallerOrEqualValue(hasta));
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) =>
                (row.readTable(_db.ventas), row.readTable(_db.usuarios).nombre),
          )
          .toList(),
    );
  }

  Future<(Venta, String)?> obtenerVenta(String id) async {
    final query = _db.select(_db.ventas).join([
      innerJoin(_db.usuarios, _db.usuarios.id.equalsExp(_db.ventas.usuarioId)),
    ])..where(_db.ventas.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return (row.readTable(_db.ventas), row.readTable(_db.usuarios).nombre);
  }

  /// Ítems de una venta con el nombre del producto.
  Future<List<(VentaItem, String)>> obtenerItemsVenta(String ventaId) {
    final query =
        _db.select(_db.ventaItems).join([
            innerJoin(
              _db.productos,
              _db.productos.id.equalsExp(_db.ventaItems.productoId),
            ),
          ])
          ..where(_db.ventaItems.ventaId.equals(ventaId))
          ..orderBy([OrderingTerm.asc(_db.ventaItems.createdAt)]);
    return query.get().then(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.ventaItems),
              row.readTable(_db.productos).nombre,
            ),
          )
          .toList(),
    );
  }

  /// Registra la venta completa en una transacción (RN-05): `ventas` +
  /// `venta_items` con el costo vigente capturado por ítem, salida de
  /// inventario por ítem (`InventoryLocalDatasource.applyMovement`), entrada
  /// en `caja_movimientos` y auditoría.
  Future<String> registrarVenta({
    required TipoVenta tipo,
    required List<VentaItemEntrada> items,
    String? nota,
    required String cajaSesionId,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final ventaId = generateUuidV4();
      final inventory = InventoryLocalDatasource(_db);

      var total = 0;
      var ganancia = 0;
      final costos = <String, int>{};
      for (final item in items) {
        final producto = await inventory.obtenerProducto(item.productoId);
        final costo = producto?.precioCompra ?? 0;
        costos[item.productoId] = costo;
        total += (item.precioUnitarioCents * item.cantidad).round();
        ganancia += ((item.precioUnitarioCents - costo) * item.cantidad)
            .round();
      }

      await _db
          .into(_db.ventas)
          .insert(
            VentasCompanion.insert(
              id: Value(ventaId),
              tipo: tipo,
              total: total,
              ganancia: ganancia,
              cajaSesionId: cajaSesionId,
              usuarioId: usuarioId,
              estado: EstadoVenta.completada,
              nota: Value(nota),
              fecha: DateTime.now().toUtc(),
            ),
          );

      for (final item in items) {
        await _db
            .into(_db.ventaItems)
            .insert(
              VentaItemsCompanion.insert(
                ventaId: ventaId,
                productoId: item.productoId,
                cantidad: item.cantidad,
                precioUnitario: item.precioUnitarioCents,
                costoUnitario: costos[item.productoId]!,
              ),
            );

        final producto = await inventory.obtenerProducto(item.productoId);
        if (producto == null) continue;

        await inventory.applyMovement(
          producto: producto,
          tipo: TipoMovimientoInventario.venta,
          cantidad: -item.cantidad,
          referenciaId: ventaId,
          usuarioId: usuarioId,
        );
      }

      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: 'crear',
              modulo: 'ventas',
              entidadId: Value(ventaId),
              datosDespues: Value(
                jsonEncode({
                  'total': total,
                  'ganancia': ganancia,
                  'items': items.length,
                  'tipo': tipo.name,
                }),
              ),
            ),
          );

      await _db
          .into(_db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              cajaSesionId: cajaSesionId,
              tipo: TipoCajaMovimiento.venta,
              monto: total,
              referenciaId: Value(ventaId),
              usuarioId: usuarioId,
            ),
          );

      return ventaId;
    });
  }

  /// Anula una venta completada (RN-10): revierte el stock de cada ítem,
  /// registra la salida compensatoria en `caja_movimientos`, marca la venta
  /// como anulada y registra auditoría.
  Future<void> anularVenta(String id, {required String usuarioId}) {
    return _db.transaction(() async {
      final venta = await (_db.select(
        _db.ventas,
      )..where((t) => t.id.equals(id))).getSingle();
      final items = await (_db.select(
        _db.ventaItems,
      )..where((t) => t.ventaId.equals(id))).get();

      final inventory = InventoryLocalDatasource(_db);
      for (final item in items) {
        final producto = await inventory.obtenerProducto(item.productoId);
        if (producto == null) continue;
        await inventory.applyMovement(
          producto: producto,
          tipo: TipoMovimientoInventario.anulacionVenta,
          cantidad: item.cantidad,
          referenciaId: id,
          usuarioId: usuarioId,
        );
      }

      await (_db.update(_db.ventas)..where((t) => t.id.equals(id))).write(
        VentasCompanion(
          estado: Value(EstadoVenta.anulada),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      await _db
          .into(_db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              cajaSesionId: venta.cajaSesionId,
              tipo: TipoCajaMovimiento.venta,
              monto: -venta.total,
              referenciaId: Value(id),
              usuarioId: usuarioId,
            ),
          );

      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: 'anular',
              modulo: 'ventas',
              entidadId: Value(id),
              datosAntes: Value(jsonEncode({'estado': venta.estado.name})),
              datosDespues: Value(
                jsonEncode({'estado': EstadoVenta.anulada.name}),
              ),
            ),
          );
    });
  }

  /// Abre una nueva sesión de caja (RN-01: requisito mínimo para vender).
  Future<void> abrirCaja({
    required int montoAperturaCents,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final id = generateUuidV4();
      await _db
          .into(_db.cajaSesiones)
          .insert(
            CajaSesionesCompanion.insert(
              id: Value(id),
              fechaApertura: DateTime.now().toUtc(),
              montoApertura: montoAperturaCents,
              usuarioApertura: usuarioId,
              estado: EstadoCajaSesion.abierta,
            ),
          );

      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: 'abrir',
              modulo: 'caja',
              entidadId: Value(id),
              datosDespues: Value(
                jsonEncode({'montoApertura': montoAperturaCents}),
              ),
            ),
          );
    });
  }
}
