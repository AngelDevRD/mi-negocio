import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../inventory/data/datasources/inventory_local_datasource.dart';

/// Ítem de entrada para [PurchasesLocalDatasource.registrarCompra].
class CompraItemEntrada {
  const CompraItemEntrada({
    required this.productoId,
    required this.cantidad,
    required this.costoUnitarioCents,
  });

  final String productoId;
  final double cantidad;
  final int costoUnitarioCents;
}

/// Acceso a `proveedores`, `compras` y `compra_items` (RF-COM).
class PurchasesLocalDatasource {
  PurchasesLocalDatasource(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------
  // Proveedores
  // ---------------------------------------------------------------------

  Stream<List<Proveedore>> watchProveedores() {
    return (_db.select(_db.proveedores)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  Future<bool> existeProveedor(String nombre) async {
    final query = _db.select(_db.proveedores)
      ..where((t) => t.nombre.equals(nombre) & t.deletedAt.isNull());
    return await query.getSingleOrNull() != null;
  }

  Future<Proveedore> crearProveedor({
    required String nombre,
    String? telefono,
  }) async {
    final id = generateUuidV4();
    await _db
        .into(_db.proveedores)
        .insert(
          ProveedoresCompanion.insert(
            id: Value(id),
            nombre: nombre,
            telefono: Value(telefono),
          ),
        );
    return (_db.select(
      _db.proveedores,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  // ---------------------------------------------------------------------
  // Compras
  // ---------------------------------------------------------------------

  /// Compras con proveedor (puede ser `null`) y usuario, más reciente
  /// primero.
  Stream<List<(Compra, String?, String)>> watchCompras({
    String? proveedorId,
    DateTime? desde,
    DateTime? hasta,
  }) {
    final query = _db.select(_db.compras).join([
      leftOuterJoin(
        _db.proveedores,
        _db.proveedores.id.equalsExp(_db.compras.proveedorId),
      ),
      innerJoin(_db.usuarios, _db.usuarios.id.equalsExp(_db.compras.usuarioId)),
    ])..orderBy([OrderingTerm.desc(_db.compras.fecha)]);

    if (proveedorId != null) {
      query.where(_db.compras.proveedorId.equals(proveedorId));
    }
    if (desde != null) {
      query.where(_db.compras.fecha.isBiggerOrEqualValue(desde));
    }
    if (hasta != null) {
      query.where(_db.compras.fecha.isSmallerOrEqualValue(hasta));
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.compras),
              row.readTableOrNull(_db.proveedores)?.nombre,
              row.readTable(_db.usuarios).nombre,
            ),
          )
          .toList(),
    );
  }

  Future<(Compra, String?, String)?> obtenerCompra(String id) async {
    final query = _db.select(_db.compras).join([
      leftOuterJoin(
        _db.proveedores,
        _db.proveedores.id.equalsExp(_db.compras.proveedorId),
      ),
      innerJoin(_db.usuarios, _db.usuarios.id.equalsExp(_db.compras.usuarioId)),
    ])..where(_db.compras.id.equals(id));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return (
      row.readTable(_db.compras),
      row.readTableOrNull(_db.proveedores)?.nombre,
      row.readTable(_db.usuarios).nombre,
    );
  }

  /// Ítems de una compra con el nombre del producto.
  Future<List<(CompraItem, String)>> obtenerItemsCompra(String compraId) {
    final query =
        _db.select(_db.compraItems).join([
            innerJoin(
              _db.productos,
              _db.productos.id.equalsExp(_db.compraItems.productoId),
            ),
          ])
          ..where(_db.compraItems.compraId.equals(compraId))
          ..orderBy([OrderingTerm.asc(_db.compraItems.createdAt)]);
    return query.get().then(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.compraItems),
              row.readTable(_db.productos).nombre,
            ),
          )
          .toList(),
    );
  }

  /// `true` si existe un producto activo (no eliminado) con ese id.
  Future<bool> existeProducto(String id) async {
    final query = _db.select(_db.productos)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return await query.getSingleOrNull() != null;
  }

  /// Id de la sesión de caja abierta, si hay una (RF-CAJ).
  Future<String?> obtenerCajaAbiertaId() async {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta));
    final sesion = await query.getSingleOrNull();
    return sesion?.id;
  }

  /// Registra la compra completa en una transacción (RN-06):
  /// `compras` + `compra_items`, entrada de inventario por ítem
  /// (`InventoryLocalDatasource.applyMovement`), actualización de
  /// `precio_compra` + `historial_precios` si el costo difiere, auditoría y,
  /// si `cajaSesionId != null`, una salida en `caja_movimientos`.
  Future<String> registrarCompra({
    String? proveedorId,
    String? numeroFactura,
    String? fotoFacturaPath,
    required List<CompraItemEntrada> items,
    String? cajaSesionId,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final compraId = generateUuidV4();
      final inventory = InventoryLocalDatasource(_db);
      final total = items.fold<int>(
        0,
        (suma, item) =>
            suma + (item.costoUnitarioCents * item.cantidad).round(),
      );

      await _db
          .into(_db.compras)
          .insert(
            ComprasCompanion.insert(
              id: Value(compraId),
              proveedorId: Value(proveedorId),
              numeroFactura: Value(numeroFactura),
              fotoFacturaPath: Value(fotoFacturaPath),
              total: total,
              pagadaDeCaja: Value(cajaSesionId != null),
              estado: EstadoCompra.completada,
              usuarioId: usuarioId,
              fecha: DateTime.now().toUtc(),
            ),
          );

      for (final item in items) {
        await _db
            .into(_db.compraItems)
            .insert(
              CompraItemsCompanion.insert(
                compraId: compraId,
                productoId: item.productoId,
                cantidad: item.cantidad,
                costoUnitario: item.costoUnitarioCents,
              ),
            );

        final producto = await inventory.obtenerProducto(item.productoId);
        if (producto == null) continue;

        await inventory.applyMovement(
          producto: producto,
          tipo: TipoMovimientoInventario.compra,
          cantidad: item.cantidad,
          referenciaId: compraId,
          usuarioId: usuarioId,
        );

        if (item.costoUnitarioCents != producto.precioCompra) {
          await _db
              .into(_db.historialPrecios)
              .insert(
                HistorialPreciosCompanion.insert(
                  productoId: item.productoId,
                  tipo: TipoPrecio.compra,
                  precioAnterior: producto.precioCompra,
                  precioNuevo: item.costoUnitarioCents,
                  usuarioId: usuarioId,
                ),
              );
          await (_db.update(
            _db.productos,
          )..where((t) => t.id.equals(item.productoId))).write(
            ProductosCompanion(
              precioCompra: Value(item.costoUnitarioCents),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
        }
      }

      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: 'crear',
              modulo: 'compras',
              entidadId: Value(compraId),
              datosDespues: Value(
                jsonEncode({
                  'total': total,
                  'items': items.length,
                  'proveedorId': ?proveedorId,
                  'numeroFactura': ?numeroFactura,
                }),
              ),
            ),
          );

      if (cajaSesionId != null) {
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                cajaSesionId: cajaSesionId,
                tipo: TipoCajaMovimiento.compra,
                monto: -total,
                referenciaId: Value(compraId),
                usuarioId: usuarioId,
              ),
            );
      }

      return compraId;
    });
  }
}
