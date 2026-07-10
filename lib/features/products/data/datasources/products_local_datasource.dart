import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';

/// Acceso a las tablas `categorias`, `productos`, `historial_precios` y
/// `movimientos_inventario` (RF-PROD).
class ProductsLocalDatasource {
  ProductsLocalDatasource(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------
  // Categorías
  // ---------------------------------------------------------------------

  Stream<List<Categoria>> watchCategorias() {
    return (_db.select(_db.categorias)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  Future<bool> existeCategoria(String nombre, {String? excluirId}) async {
    final query = _db.select(_db.categorias)
      ..where((t) => t.nombre.equals(nombre) & t.deletedAt.isNull());
    if (excluirId != null) {
      query.where((t) => t.id.equals(excluirId).not());
    }
    return await query.getSingleOrNull() != null;
  }

  Future<Categoria> crearCategoria(String nombre) async {
    final id = generateUuidV4();
    await _db
        .into(_db.categorias)
        .insert(CategoriasCompanion.insert(id: Value(id), nombre: nombre));
    return (_db.select(
      _db.categorias,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> renombrarCategoria(String id, String nombre) {
    return (_db.update(_db.categorias)..where((t) => t.id.equals(id))).write(
      CategoriasCompanion(
        nombre: Value(nombre),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> eliminarCategoria(String id) {
    final ahora = DateTime.now().toUtc();
    return (_db.update(_db.categorias)..where((t) => t.id.equals(id))).write(
      CategoriasCompanion(deletedAt: Value(ahora), updatedAt: Value(ahora)),
    );
  }

  // ---------------------------------------------------------------------
  // Productos
  // ---------------------------------------------------------------------

  /// Productos con el nombre de su categoría (join, puede ser `null`).
  Stream<List<(Producto, String?)>> watchProductos({
    String busqueda = '',
    String? categoriaId,
    bool? activo,
  }) {
    final query = _db.select(_db.productos).join([
      leftOuterJoin(
        _db.categorias,
        _db.categorias.id.equalsExp(_db.productos.categoriaId),
      ),
    ])..where(_db.productos.deletedAt.isNull());

    if (busqueda.trim().isNotEmpty) {
      query.where(_db.productos.nombre.like('%${busqueda.trim()}%'));
    }
    if (categoriaId != null) {
      query.where(_db.productos.categoriaId.equals(categoriaId));
    }
    if (activo != null) {
      query.where(_db.productos.activo.equals(activo));
    }
    query.orderBy([OrderingTerm.asc(_db.productos.nombre)]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.productos),
              row.readTableOrNull(_db.categorias)?.nombre,
            ),
          )
          .toList(),
    );
  }

  Future<(Producto, String?)?> obtenerProducto(String id) async {
    final query = _db.select(_db.productos).join([
      leftOuterJoin(
        _db.categorias,
        _db.categorias.id.equalsExp(_db.productos.categoriaId),
      ),
    ])..where(_db.productos.id.equals(id) & _db.productos.deletedAt.isNull());
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return (
      row.readTable(_db.productos),
      row.readTableOrNull(_db.categorias)?.nombre,
    );
  }

  Future<bool> existeNombreProducto(String nombre, {String? excluirId}) async {
    final query = _db.select(_db.productos)
      ..where((t) => t.nombre.equals(nombre) & t.deletedAt.isNull());
    if (excluirId != null) {
      query.where((t) => t.id.equals(excluirId).not());
    }
    return await query.getSingleOrNull() != null;
  }

  /// Crea el producto. Si `stockInicial != 0`, registra el movimiento de
  /// inventario `stockInicial` (RN-03) y deja `auditoria` (RF-AUD-01).
  Future<String> crearProducto({
    required String nombre,
    String? categoriaId,
    required String unidad,
    required int precioCompra,
    required int precioVenta,
    required double stockInicial,
    required double stockMinimo,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final id = generateUuidV4();
      await _db
          .into(_db.productos)
          .insert(
            ProductosCompanion.insert(
              id: Value(id),
              nombre: nombre,
              categoriaId: Value(categoriaId),
              unidad: Value(unidad),
              precioCompra: Value(precioCompra),
              precioVenta: Value(precioVenta),
              stockActual: Value(stockInicial),
              stockMinimo: Value(stockMinimo),
            ),
          );

      if (stockInicial != 0) {
        await _db
            .into(_db.movimientosInventario)
            .insert(
              MovimientosInventarioCompanion.insert(
                productoId: id,
                tipo: TipoMovimientoInventario.stockInicial,
                cantidad: stockInicial,
                stockResultante: stockInicial,
                usuarioId: usuarioId,
                motivo: const Value('Stock inicial'),
              ),
            );
      }

      await _registrarAuditoria(
        usuarioId: usuarioId,
        accion: 'crear',
        entidadId: id,
        datosDespues: {
          'nombre': nombre,
          'categoriaId': categoriaId,
          'unidad': unidad,
          'precioCompra': precioCompra,
          'precioVenta': precioVenta,
          'stockInicial': stockInicial,
          'stockMinimo': stockMinimo,
        },
      );

      return id;
    });
  }

  /// Actualiza el producto. Si `precioCompra` o `precioVenta` difieren del
  /// valor actual, inserta una entrada en `historial_precios` por cada uno
  /// (RN-04), y registra `auditoria` con el antes/después.
  Future<void> actualizarProducto({
    required String id,
    required Producto actual,
    required String nombre,
    String? categoriaId,
    required String unidad,
    required int precioCompra,
    required int precioVenta,
    required double stockMinimo,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      if (actual.precioCompra != precioCompra) {
        await _db
            .into(_db.historialPrecios)
            .insert(
              HistorialPreciosCompanion.insert(
                productoId: id,
                tipo: TipoPrecio.compra,
                precioAnterior: actual.precioCompra,
                precioNuevo: precioCompra,
                usuarioId: usuarioId,
              ),
            );
      }
      if (actual.precioVenta != precioVenta) {
        await _db
            .into(_db.historialPrecios)
            .insert(
              HistorialPreciosCompanion.insert(
                productoId: id,
                tipo: TipoPrecio.venta,
                precioAnterior: actual.precioVenta,
                precioNuevo: precioVenta,
                usuarioId: usuarioId,
              ),
            );
      }

      await (_db.update(_db.productos)..where((t) => t.id.equals(id))).write(
        ProductosCompanion(
          nombre: Value(nombre),
          categoriaId: Value(categoriaId),
          unidad: Value(unidad),
          precioCompra: Value(precioCompra),
          precioVenta: Value(precioVenta),
          stockMinimo: Value(stockMinimo),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      await _registrarAuditoria(
        usuarioId: usuarioId,
        accion: 'editar',
        entidadId: id,
        datosAntes: {
          'nombre': actual.nombre,
          'categoriaId': actual.categoriaId,
          'unidad': actual.unidad,
          'precioCompra': actual.precioCompra,
          'precioVenta': actual.precioVenta,
          'stockMinimo': actual.stockMinimo,
        },
        datosDespues: {
          'nombre': nombre,
          'categoriaId': categoriaId,
          'unidad': unidad,
          'precioCompra': precioCompra,
          'precioVenta': precioVenta,
          'stockMinimo': stockMinimo,
        },
      );
    });
  }

  Future<void> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.productos)..where((t) => t.id.equals(id))).write(
        ProductosCompanion(
          activo: Value(activo),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _registrarAuditoria(
        usuarioId: usuarioId,
        accion: activo ? 'activar' : 'desactivar',
        entidadId: id,
        datosDespues: {'activo': activo},
      );
    });
  }

  // ---------------------------------------------------------------------
  // Historial de precios
  // ---------------------------------------------------------------------

  Stream<List<(HistorialPrecio, String)>> watchHistorialPrecios(
    String productoId,
  ) {
    final query =
        _db.select(_db.historialPrecios).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.historialPrecios.usuarioId),
            ),
          ])
          ..where(_db.historialPrecios.productoId.equals(productoId))
          ..orderBy([OrderingTerm.desc(_db.historialPrecios.fecha)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.historialPrecios),
              row.readTable(_db.usuarios).nombre,
            ),
          )
          .toList(),
    );
  }

  // ---------------------------------------------------------------------
  // Auditoría (RF-AUD-01)
  // ---------------------------------------------------------------------

  Future<void> _registrarAuditoria({
    required String usuarioId,
    required String accion,
    required String entidadId,
    Map<String, Object?>? datosAntes,
    Map<String, Object?>? datosDespues,
  }) {
    return _db
        .into(_db.auditoria)
        .insert(
          AuditoriaCompanion.insert(
            usuarioId: usuarioId,
            accion: accion,
            modulo: 'productos',
            entidadId: Value(entidadId),
            datosAntes: Value(
              datosAntes == null ? null : jsonEncode(datosAntes),
            ),
            datosDespues: Value(
              datosDespues == null ? null : jsonEncode(datosDespues),
            ),
          ),
        );
  }
}
