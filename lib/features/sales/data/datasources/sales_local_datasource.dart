import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/sync/payloads/auditoria_payload.dart';
import '../../../../core/sync/payloads/operacion_payloads.dart';
import '../../../../core/sync/sync_queue_writer.dart';
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

/// Lanzada dentro de la transacción de [SalesLocalDatasource.registrarVenta]
/// cuando un ítem referencia un producto que ya no existe (RN-05): revierte
/// la transacción completa. El repositorio la traduce a un `ValidationFailure`
/// con el nombre del producto para el usuario.
class ProductoInexistenteException implements Exception {
  const ProductoInexistenteException(this.productoId);

  final String productoId;
}

/// Lanzada dentro de la transacción de [SalesLocalDatasource.registrarVenta]
/// (RN-12) cuando el administrador NO permite vender sin stock y las líneas de
/// un producto (sumadas) superan su existencia. Se lanza antes de escribir
/// nada. El repositorio la traduce a un `BusinessRuleFailure`.
class StockInsuficienteException implements Exception {
  const StockInsuficienteException({
    required this.productoId,
    required this.unidad,
    required this.disponible,
    required this.solicitado,
  });

  final String productoId;
  final String unidad;
  final double disponible;
  final double solicitado;
}

/// Acceso a `ventas`/`venta_items` (RF-VEN) y a la apertura mínima de
/// `caja_sesiones` (RN-01).
class SalesLocalDatasource {
  SalesLocalDatasource(this._db);

  final AppDatabase _db;

  /// Id de la sesión de caja abierta, si hay una (RN-01).
  ///
  /// Tolerante a más de una sesión abierta preexistente: no debería ocurrir,
  /// pero un dato ya corrupto en una instalación publicada no debe tumbar la
  /// app con una excepción cruda al intentar vender. Se toma la más reciente
  /// por `fechaApertura` (`limit(1)` acota la fila para que `getSingleOrNull`
  /// nunca lance `StateError`).
  Future<String?> obtenerCajaAbiertaId() async {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta))
      ..orderBy([(t) => OrderingTerm.desc(t.fechaApertura)])
      ..limit(1);
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
  ///
  /// Con [permitirStockNegativo] en `false` lanza [StockInsuficienteException]
  /// (RN-12) si alguna línea deja el stock por debajo de cero.
  ///
  /// Revalida dentro de la transacción que cada producto exista (RN-05): si
  /// un ítem referencia un producto inexistente/eliminado, lanza
  /// [ProductoInexistenteException] y la transacción entera se revierte, en
  /// vez de registrar la venta con costo 0 y sin descontar stock. Cada
  /// producto se consulta una sola vez por ítem (antes se consultaba dos
  /// veces: una para el costo, otra para el descuento de stock).
  Future<String> registrarVenta({
    required TipoVenta tipo,
    required List<VentaItemEntrada> items,
    String? nota,
    required String cajaSesionId,
    required String usuarioId,
    required bool permitirStockNegativo,
  }) {
    return _db.transaction(() async {
      final ventaId = generateUuidV4();
      final inventory = InventoryLocalDatasource(_db);

      var total = 0;
      var ganancia = 0;
      final productos = <String, Producto>{};
      for (final item in items) {
        final producto = await inventory.obtenerProducto(item.productoId);
        if (producto == null) {
          throw ProductoInexistenteException(item.productoId);
        }
        productos[item.productoId] = producto;
        final costo = producto.precioCompra;
        total += (item.precioUnitarioCents * item.cantidad).round();
        ganancia += ((item.precioUnitarioCents - costo) * item.cantidad)
            .round();
      }

      // RN-12: sin permiso para stock negativo, la existencia se revalida aquí
      // (no solo en la UI), sumando las líneas del mismo producto y ANTES de
      // escribir nada.
      if (!permitirStockNegativo) {
        final solicitado = <String, double>{};
        for (final item in items) {
          solicitado[item.productoId] =
              (solicitado[item.productoId] ?? 0) + item.cantidad;
        }
        for (final entrada in solicitado.entries) {
          final producto = productos[entrada.key]!;
          // Tolerancia: sumas como 0.1 + 0.2 no deben rechazar un 0.3 exacto.
          if (producto.stockActual - entrada.value < -1e-9) {
            throw StockInsuficienteException(
              productoId: entrada.key,
              unidad: producto.unidad,
              disponible: producto.stockActual,
              solicitado: entrada.value,
            );
          }
        }
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
      final ventaFila = await (_db.select(
        _db.ventas,
      )..where((t) => t.id.equals(ventaId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'ventas',
        registroId: ventaId,
        operacion: OperacionSync.insert,
        payload: ventaPayload(ventaFila),
      );

      for (final item in items) {
        final itemId = generateUuidV4();
        await _db
            .into(_db.ventaItems)
            .insert(
              VentaItemsCompanion.insert(
                id: Value(itemId),
                ventaId: ventaId,
                productoId: item.productoId,
                cantidad: item.cantidad,
                precioUnitario: item.precioUnitarioCents,
                costoUnitario: productos[item.productoId]!.precioCompra,
              ),
            );
        final itemFila = await (_db.select(
          _db.ventaItems,
        )..where((t) => t.id.equals(itemId))).getSingle();
        await enqueueSync(
          _db,
          tabla: 'venta_items',
          registroId: itemId,
          operacion: OperacionSync.insert,
          payload: ventaItemPayload(itemFila),
        );

        await inventory.applyMovement(
          producto: productos[item.productoId]!,
          tipo: TipoMovimientoInventario.venta,
          cantidad: -item.cantidad,
          referenciaId: ventaId,
          usuarioId: usuarioId,
        );
      }

      final auditId = generateUuidV4();
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              id: Value(auditId),
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
      final auditFila = await (_db.select(
        _db.auditoria,
      )..where((t) => t.id.equals(auditId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'auditoria',
        registroId: auditId,
        operacion: OperacionSync.insert,
        payload: auditoriaPayload(auditFila),
      );

      final cajaMovId = generateUuidV4();
      await _db
          .into(_db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              id: Value(cajaMovId),
              cajaSesionId: cajaSesionId,
              tipo: TipoCajaMovimiento.venta,
              monto: total,
              referenciaId: Value(ventaId),
              usuarioId: usuarioId,
            ),
          );
      final cajaMovFila = await (_db.select(
        _db.cajaMovimientos,
      )..where((t) => t.id.equals(cajaMovId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'caja_movimientos',
        registroId: cajaMovId,
        operacion: OperacionSync.insert,
        payload: cajaMovimientoPayload(cajaMovFila),
      );

      return ventaId;
    });
  }

  /// Anula una venta completada (RN-10): revierte el stock de cada ítem,
  /// registra la salida compensatoria en `caja_movimientos`, marca la venta
  /// como anulada y registra auditoría.
  ///
  /// Revalida el estado de la venta como primera operación DENTRO de la
  /// transacción (RN-10): dos llamadas concurrentes solo aplican la
  /// reversión una vez. Devuelve `false` sin escribir nada si la venta no
  /// existe o ya estaba anulada; `true` si la anulación se aplicó.
  Future<bool> anularVenta(String id, {required String usuarioId}) {
    return _db.transaction(() async {
      final venta = await (_db.select(
        _db.ventas,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (venta == null || venta.estado == EstadoVenta.anulada) {
        return false;
      }
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
      final ventaFila = await (_db.select(
        _db.ventas,
      )..where((t) => t.id.equals(id))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'ventas',
        registroId: id,
        operacion: OperacionSync.update,
        payload: ventaPayload(ventaFila),
      );

      final cajaMovId = generateUuidV4();
      await _db
          .into(_db.cajaMovimientos)
          .insert(
            CajaMovimientosCompanion.insert(
              id: Value(cajaMovId),
              cajaSesionId: venta.cajaSesionId,
              tipo: TipoCajaMovimiento.venta,
              monto: -venta.total,
              referenciaId: Value(id),
              usuarioId: usuarioId,
            ),
          );
      final cajaMovFila = await (_db.select(
        _db.cajaMovimientos,
      )..where((t) => t.id.equals(cajaMovId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'caja_movimientos',
        registroId: cajaMovId,
        operacion: OperacionSync.insert,
        payload: cajaMovimientoPayload(cajaMovFila),
      );

      final auditId = generateUuidV4();
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              id: Value(auditId),
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
      final auditFila = await (_db.select(
        _db.auditoria,
      )..where((t) => t.id.equals(auditId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'auditoria',
        registroId: auditId,
        operacion: OperacionSync.insert,
        payload: auditoriaPayload(auditFila),
      );
      return true;
    });
  }

  /// Abre una nueva sesión de caja (RN-01: requisito mínimo para vender).
  ///
  /// Revalida que no exista una sesión abierta como primera operación
  /// DENTRO de la transacción (RN-01): dos llamadas concurrentes solo
  /// abren una sesión. Devuelve `false` sin escribir nada si ya había una
  /// sesión abierta; `true` si la apertura se aplicó.
  Future<bool> abrirCaja({
    required int montoAperturaCents,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      // Tolerante a más de una sesión abierta preexistente (ver
      // obtenerCajaAbiertaId): `limit(1)` acota la fila para que
      // `getSingleOrNull` nunca lance `StateError` dentro de la transacción.
      final existente =
          await (_db.select(_db.cajaSesiones)
                ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta))
                ..orderBy([(t) => OrderingTerm.desc(t.fechaApertura)])
                ..limit(1))
              .getSingleOrNull();
      if (existente != null) {
        return false;
      }
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
      final cajaFila = await (_db.select(
        _db.cajaSesiones,
      )..where((t) => t.id.equals(id))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'caja_sesiones',
        registroId: id,
        operacion: OperacionSync.insert,
        payload: cajaSesionPayload(cajaFila),
      );

      final auditId = generateUuidV4();
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              id: Value(auditId),
              usuarioId: usuarioId,
              accion: 'abrir',
              modulo: 'caja',
              entidadId: Value(id),
              datosDespues: Value(
                jsonEncode({'montoApertura': montoAperturaCents}),
              ),
            ),
          );
      final auditFila = await (_db.select(
        _db.auditoria,
      )..where((t) => t.id.equals(auditId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'auditoria',
        registroId: auditId,
        operacion: OperacionSync.insert,
        payload: auditoriaPayload(auditFila),
      );
      return true;
    });
  }
}
