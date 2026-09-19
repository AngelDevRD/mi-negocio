import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/sync/payloads/auditoria_payload.dart';
import '../../../../core/sync/payloads/operacion_payloads.dart';
import '../../../../core/sync/payloads/producto_payloads.dart';
import '../../../../core/sync/sync_queue_writer.dart';
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

/// Desenlace de [PurchasesLocalDatasource.anularCompra].
enum EstadoAnulacionCompra { aplicada, noExiste, yaAnulada, sinPermiso }

/// Qué hizo (o por qué no hizo nada) [PurchasesLocalDatasource.anularCompra].
class AnulacionCompraLocal {
  const AnulacionCompraLocal(
    this.estado, {
    this.cajaYaCerrada = false,
    this.costoRestaurado = const [],
    this.costoConservado = const [],
  });

  final EstadoAnulacionCompra estado;
  final bool cajaYaCerrada;
  final List<String> costoRestaurado;
  final List<String> costoConservado;
}

/// Ventana (a cada lado del instante de la compra) en que se busca el cambio
/// de costo que ESA compra dejó en `historial_precios`: la compra y su
/// historial se escriben en la misma transacción, con milisegundos de
/// diferencia, pero las fechas se guardan en segundos.
const _ventanaCostoCompra = Duration(seconds: 10);

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
    final fila = await (_db.select(
      _db.proveedores,
    )..where((t) => t.id.equals(id))).getSingle();
    await enqueueSync(
      _db,
      tabla: 'proveedores',
      registroId: id,
      operacion: OperacionSync.insert,
      payload: proveedorPayload(fila),
    );
    return fila;
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

  /// Ítems de una compra con nombre, unidad y existencia actual del producto
  /// (todo en la misma consulta, sin una consulta por ítem).
  Future<List<(CompraItem, String, String, double)>> obtenerItemsCompra(
    String compraId,
  ) {
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
              row.readTable(_db.productos).unidad,
              row.readTable(_db.productos).stockActual,
            ),
          )
          .toList(),
    );
  }

  /// Para una compra pagada de caja: `true` si la sesión de caja de ESE pago
  /// (la del `caja_movimiento` de la compra) sigue abierta, `false` si ya se
  /// cerró, `null` si no hay registro del pago.
  Future<bool?> cajaDelPagoAbierta(String compraId) async {
    final fila =
        await (_db.select(_db.cajaMovimientos).join([
              innerJoin(
                _db.cajaSesiones,
                _db.cajaSesiones.id.equalsExp(_db.cajaMovimientos.cajaSesionId),
              ),
            ])..where(
              _db.cajaMovimientos.referenciaId.equals(compraId) &
                  _db.cajaMovimientos.tipo.equalsValue(
                    TipoCajaMovimiento.compra,
                  ) &
                  _db.cajaMovimientos.monto.isSmallerThanValue(0),
            ))
            .getSingleOrNull();
    if (fila == null) return null;
    return fila.readTable(_db.cajaSesiones).estado == EstadoCajaSesion.abierta;
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
      final compraFila = await (_db.select(
        _db.compras,
      )..where((t) => t.id.equals(compraId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'compras',
        registroId: compraId,
        operacion: OperacionSync.insert,
        payload: compraPayload(compraFila),
      );

      for (final item in items) {
        final itemId = generateUuidV4();
        await _db
            .into(_db.compraItems)
            .insert(
              CompraItemsCompanion.insert(
                id: Value(itemId),
                compraId: compraId,
                productoId: item.productoId,
                cantidad: item.cantidad,
                costoUnitario: item.costoUnitarioCents,
              ),
            );
        final itemFila = await (_db.select(
          _db.compraItems,
        )..where((t) => t.id.equals(itemId))).getSingle();
        await enqueueSync(
          _db,
          tabla: 'compra_items',
          registroId: itemId,
          operacion: OperacionSync.insert,
          payload: compraItemPayload(itemFila),
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
          final histId = generateUuidV4();
          await _db
              .into(_db.historialPrecios)
              .insert(
                HistorialPreciosCompanion.insert(
                  id: Value(histId),
                  productoId: item.productoId,
                  tipo: TipoPrecio.compra,
                  precioAnterior: producto.precioCompra,
                  precioNuevo: item.costoUnitarioCents,
                  usuarioId: usuarioId,
                ),
              );
          final histFila = await (_db.select(
            _db.historialPrecios,
          )..where((t) => t.id.equals(histId))).getSingle();
          await enqueueSync(
            _db,
            tabla: 'historial_precios',
            registroId: histId,
            operacion: OperacionSync.insert,
            payload: historialPrecioPayload(histFila),
          );

          await (_db.update(
            _db.productos,
          )..where((t) => t.id.equals(item.productoId))).write(
            ProductosCompanion(
              precioCompra: Value(item.costoUnitarioCents),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
          final productoFila = await (_db.select(
            _db.productos,
          )..where((t) => t.id.equals(item.productoId))).getSingle();
          await enqueueSync(
            _db,
            tabla: 'productos',
            registroId: item.productoId,
            operacion: OperacionSync.update,
            payload: productoPayload(productoFila),
          );
        }
      }

      final auditId = generateUuidV4();
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              id: Value(auditId),
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

      if (cajaSesionId != null) {
        final movId = generateUuidV4();
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                id: Value(movId),
                cajaSesionId: cajaSesionId,
                tipo: TipoCajaMovimiento.compra,
                monto: -total,
                referenciaId: Value(compraId),
                usuarioId: usuarioId,
              ),
            );
        final movFila = await (_db.select(
          _db.cajaMovimientos,
        )..where((t) => t.id.equals(movId))).getSingle();
        await enqueueSync(
          _db,
          tabla: 'caja_movimientos',
          registroId: movId,
          operacion: OperacionSync.insert,
          payload: cajaMovimientoPayload(movFila),
        );
      }

      return compraId;
    });
  }

  /// Anula una compra (RN-10) en UNA transacción. Solo un Administrador
  /// (se comprueba aquí, con el rol guardado del usuario). Revalida
  /// existencia y estado como primera lectura DENTRO de la transacción: dos
  /// llamadas concurrentes solo aplican la reversión una vez; si no se aplica
  /// no se escribe nada.
  ///
  /// - Stock: `anulacionCompra` por ítem, aunque quede negativo (corrección).
  /// - Costo: restaura el anterior SOLO si se puede atribuir sin ambigüedad el
  ///   cambio a esta compra y nadie lo cambió después (ver `_restaurarCosto`).
  /// - Caja: si la compra se pagó de caja y la sesión de ese pago sigue
  ///   abierta, un movimiento compensatorio (+total); si ya se cerró, nada
  ///   (ese cierre ya cuadró) y se avisa con `cajaYaCerrada`.
  Future<AnulacionCompraLocal> anularCompra(
    String id, {
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final usuario = await (_db.select(
        _db.usuarios,
      )..where((t) => t.id.equals(usuarioId))).getSingleOrNull();
      if (usuario == null || usuario.rol != RolUsuario.administrador) {
        return const AnulacionCompraLocal(EstadoAnulacionCompra.sinPermiso);
      }
      final compra = await (_db.select(
        _db.compras,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (compra == null) {
        return const AnulacionCompraLocal(EstadoAnulacionCompra.noExiste);
      }
      if (compra.estado == EstadoCompra.anulada) {
        return const AnulacionCompraLocal(EstadoAnulacionCompra.yaAnulada);
      }

      final items = await (_db.select(
        _db.compraItems,
      )..where((t) => t.compraId.equals(id))).get();

      final inventory = InventoryLocalDatasource(_db);
      for (final item in items) {
        final producto = await inventory.obtenerProducto(item.productoId);
        if (producto == null) continue;
        await inventory.applyMovement(
          producto: producto,
          tipo: TipoMovimientoInventario.anulacionCompra,
          cantidad: -item.cantidad,
          referenciaId: id,
          usuarioId: usuarioId,
        );
      }

      final restaurados = <String>[];
      final conservados = <String>[];
      for (final item in items) {
        final resultado = await _restaurarCosto(
          compra: compra,
          item: item,
          repeticiones: items
              .where((i) => i.productoId == item.productoId)
              .length,
          usuarioId: usuarioId,
        );
        if (resultado == null) continue;
        (resultado.restaurado ? restaurados : conservados).add(
          resultado.producto,
        );
      }

      final cajaYaCerrada = await _compensarCaja(compra, usuarioId);

      await (_db.update(_db.compras)..where((t) => t.id.equals(id))).write(
        ComprasCompanion(
          estado: const Value(EstadoCompra.anulada),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      final compraFila = await (_db.select(
        _db.compras,
      )..where((t) => t.id.equals(id))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'compras',
        registroId: id,
        operacion: OperacionSync.update,
        payload: compraPayload(compraFila),
      );

      final auditId = generateUuidV4();
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              id: Value(auditId),
              usuarioId: usuarioId,
              accion: 'anular',
              modulo: 'compras',
              entidadId: Value(id),
              datosAntes: Value(jsonEncode({'estado': compra.estado.name})),
              datosDespues: Value(
                jsonEncode({
                  'estado': EstadoCompra.anulada.name,
                  'total': compra.total,
                  'items': items.length,
                  'cajaYaCerrada': cajaYaCerrada,
                  if (restaurados.isNotEmpty) 'costoRestaurado': restaurados,
                  if (conservados.isNotEmpty) 'costoConservado': conservados,
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

      return AnulacionCompraLocal(
        EstadoAnulacionCompra.aplicada,
        cajaYaCerrada: cajaYaCerrada,
        costoRestaurado: restaurados,
        costoConservado: conservados,
      );
    });
  }

  /// Devuelve `null` si esta compra no cambió el costo del producto; si lo
  /// cambió, `(producto, restaurado)`.
  ///
  /// `historial_precios` no guarda de qué compra vino cada cambio, así que se
  /// identifica por: mismo producto y usuario, tipo compra, `precio_nuevo` =
  /// costo del ítem y fecha pegada a la de la compra. Solo se restaura si
  /// hay UN candidato, no hay otra compra del producto en esa ventana, ningún
  /// cambio de costo posterior y el costo actual sigue siendo el que dejó esta
  /// compra. En cualquier otro caso el costo se deja como está.
  Future<({String producto, bool restaurado})?> _restaurarCosto({
    required Compra compra,
    required CompraItem item,
    required int repeticiones,
    required String usuarioId,
  }) async {
    final producto = await (_db.select(
      _db.productos,
    )..where((t) => t.id.equals(item.productoId))).getSingleOrNull();
    if (producto == null) return null;

    final historial =
        await (_db.select(_db.historialPrecios)
              ..where(
                (t) =>
                    t.productoId.equals(item.productoId) &
                    t.tipo.equalsValue(TipoPrecio.compra),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
            .get();
    final desde = compra.fecha.subtract(_ventanaCostoCompra);
    final hasta = compra.fecha.add(_ventanaCostoCompra);
    final candidatos = historial.where(
      (h) =>
          h.usuarioId == compra.usuarioId &&
          h.precioNuevo == item.costoUnitario &&
          !h.fecha.isBefore(compra.fecha) &&
          !h.fecha.isAfter(hasta),
    );
    if (candidatos.isEmpty) return null; // esta compra no cambió el costo

    final nombre = producto.nombre;
    if (candidatos.length > 1 || repeticiones > 1) {
      return (producto: nombre, restaurado: false);
    }
    final cambio = candidatos.single;

    // Otra compra del mismo producto pegada a esta: no se sabe de cuál es el
    // cambio.
    final otras =
        await (_db.select(_db.compraItems).join([
              innerJoin(
                _db.compras,
                _db.compras.id.equalsExp(_db.compraItems.compraId),
              ),
            ])..where(
              _db.compraItems.productoId.equals(item.productoId) &
                  _db.compras.id.equals(compra.id).not() &
                  _db.compras.fecha.isBetweenValues(desde, hasta),
            ))
            .get();
    if (otras.isNotEmpty) return (producto: nombre, restaurado: false);

    // Cambio posterior de costo (aunque haya vuelto al mismo valor).
    final posterior = historial.any(
      (h) => h.id != cambio.id && !h.fecha.isBefore(cambio.fecha),
    );
    if (posterior || producto.precioCompra != cambio.precioNuevo) {
      return (producto: nombre, restaurado: false);
    }

    final histId = generateUuidV4();
    await _db
        .into(_db.historialPrecios)
        .insert(
          HistorialPreciosCompanion.insert(
            id: Value(histId),
            productoId: item.productoId,
            tipo: TipoPrecio.compra,
            precioAnterior: producto.precioCompra,
            precioNuevo: cambio.precioAnterior,
            usuarioId: usuarioId,
          ),
        );
    final histFila = await (_db.select(
      _db.historialPrecios,
    )..where((t) => t.id.equals(histId))).getSingle();
    await enqueueSync(
      _db,
      tabla: 'historial_precios',
      registroId: histId,
      operacion: OperacionSync.insert,
      payload: historialPrecioPayload(histFila),
    );
    await (_db.update(
      _db.productos,
    )..where((t) => t.id.equals(item.productoId))).write(
      ProductosCompanion(
        precioCompra: Value(cambio.precioAnterior),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    final productoFila = await (_db.select(
      _db.productos,
    )..where((t) => t.id.equals(item.productoId))).getSingle();
    await enqueueSync(
      _db,
      tabla: 'productos',
      registroId: item.productoId,
      operacion: OperacionSync.update,
      payload: productoPayload(productoFila),
    );
    return (producto: nombre, restaurado: true);
  }

  /// Compensa la salida de caja de la compra si la sesión de ESE pago sigue
  /// abierta. Devuelve `true` si el pago fue de una sesión ya cerrada (no se
  /// inserta nada: ese cierre ya cuadró con el efectivo real).
  Future<bool> _compensarCaja(Compra compra, String usuarioId) async {
    if (!compra.pagadaDeCaja) return false;
    final pago =
        await (_db.select(_db.cajaMovimientos)
              ..where(
                (t) =>
                    t.referenciaId.equals(compra.id) &
                    t.tipo.equalsValue(TipoCajaMovimiento.compra) &
                    t.monto.isSmallerThanValue(0),
              )
              ..limit(1))
            .getSingleOrNull();
    if (pago == null) return false;
    final sesion = await (_db.select(
      _db.cajaSesiones,
    )..where((t) => t.id.equals(pago.cajaSesionId))).getSingle();
    if (sesion.estado != EstadoCajaSesion.abierta) return true;

    final movId = generateUuidV4();
    await _db
        .into(_db.cajaMovimientos)
        .insert(
          CajaMovimientosCompanion.insert(
            id: Value(movId),
            cajaSesionId: sesion.id,
            tipo: TipoCajaMovimiento.compra,
            monto: -pago.monto,
            motivo: const Value('Anulación de compra'),
            referenciaId: Value(compra.id),
            usuarioId: usuarioId,
          ),
        );
    final movFila = await (_db.select(
      _db.cajaMovimientos,
    )..where((t) => t.id.equals(movId))).getSingle();
    await enqueueSync(
      _db,
      tabla: 'caja_movimientos',
      registroId: movId,
      operacion: OperacionSync.insert,
      payload: cajaMovimientoPayload(movFila),
    );
    return false;
  }
}
