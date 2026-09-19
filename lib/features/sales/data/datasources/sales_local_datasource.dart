import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/sync/payloads/auditoria_payload.dart';
import '../../../../core/sync/payloads/operacion_payloads.dart';
import '../../../../core/sync/sync_queue_writer.dart';
import '../../../customers/data/datasources/customers_local_datasource.dart';
import '../../../inventory/data/datasources/inventory_local_datasource.dart';

/// Pagos de una venta. Regla de compatibilidad ÚNICA: una venta SIN filas en
/// `venta_pagos` (todas las anteriores a la v2) se trata como un pago en
/// EFECTIVO por su [total]. Es una función suelta (como `saldoDeCliente`) para
/// que otros módulos, como el arqueo de caja, la reutilicen en vez de repetirla.
Future<List<({MetodoPago metodo, int monto})>> pagosDeVenta(
  AppDatabase db,
  String ventaId,
  int total,
) async {
  final filas = await (db.select(
    db.ventaPagos,
  )..where((t) => t.ventaId.equals(ventaId))).get();
  if (filas.isEmpty) return [(metodo: MetodoPago.efectivo, monto: total)];
  return [for (final f in filas) (metodo: f.metodo, monto: f.monto)];
}

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

/// Venta a crédito con un cliente inexistente, eliminado o inactivo: no se
/// escribe nada.
class ClienteNoDisponibleException implements Exception {
  const ClienteNoDisponibleException(this.clienteId);

  final String clienteId;
}

/// Venta a crédito que deja el saldo del cliente por encima de su límite de
/// crédito: no se escribe nada.
class LimiteCreditoExcedidoException implements Exception {
  const LimiteCreditoExcedidoException({
    required this.nombre,
    required this.saldo,
    required this.limite,
  });

  final String nombre;
  final int saldo;
  final int limite;
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

  /// Pagos de una venta (ver [pagosDeVenta]: la venta sin `venta_pagos` cuenta
  /// como efectivo).
  Future<List<({MetodoPago metodo, int monto})>> obtenerPagos(
    String ventaId,
    int total,
  ) => pagosDeVenta(_db, ventaId, total);

  Future<void> _insertarMovimientoCliente({
    required String clienteId,
    required TipoMovimientoCliente tipo,
    required int monto,
    required String ventaId,
    required String usuarioId,
  }) async {
    final movId = generateUuidV4();
    await _db
        .into(_db.movimientosCliente)
        .insert(
          MovimientosClienteCompanion.insert(
            id: Value(movId),
            clienteId: clienteId,
            tipo: tipo,
            monto: monto,
            ventaId: Value(ventaId),
            usuarioId: usuarioId,
          ),
        );
    final fila = await (_db.select(
      _db.movimientosCliente,
    )..where((t) => t.id.equals(movId))).getSingle();
    await enqueueSync(
      _db,
      tabla: 'movimientos_cliente',
      registroId: movId,
      operacion: OperacionSync.insert,
      payload: movimientoClientePayload(fila),
    );
  }

  /// Nombre del cliente al que se le fió la venta, si fue a crédito.
  Future<String?> nombreClienteDeVenta(String ventaId) async {
    final query =
        _db.select(_db.movimientosCliente).join([
          innerJoin(
            _db.clientes,
            _db.clientes.id.equalsExp(_db.movimientosCliente.clienteId),
          ),
        ])..where(
          _db.movimientosCliente.ventaId.equals(ventaId) &
              _db.movimientosCliente.tipo.equalsValue(
                TipoMovimientoCliente.cargo,
              ),
        );
    final fila = await query.getSingleOrNull();
    return fila?.readTable(_db.clientes).nombre;
  }

  /// Método de pago de la venta (el del primer pago; hoy hay uno solo).
  Future<MetodoPago> metodoDePago(String ventaId, int total) async =>
      (await obtenerPagos(ventaId, total)).first.metodo;

  Future<int> _montoEnEfectivo(String ventaId, int total) async {
    final pagos = await obtenerPagos(ventaId, total);
    return pagos
        .where((p) => p.metodo == MetodoPago.efectivo)
        .fold<int>(0, (suma, p) => suma + p.monto);
  }

  /// Ventas con el nombre del usuario y su método de pago, más reciente
  /// primero. El método sale de la MISMA consulta (un `left join` agregado con
  /// `venta_pagos`, no una consulta por venta): sin filas de pago = efectivo
  /// (regla de [pagosDeVenta]); con más de un método distinto, `mixto`.
  Stream<List<(Venta, String, MetodoPago?, bool)>> watchVentas({
    EstadoVenta? estado,
    DateTime? desde,
    DateTime? hasta,
  }) {
    final primerMetodo = _db.ventaPagos.metodo.min();
    final ultimoMetodo = _db.ventaPagos.metodo.max();
    final query =
        _db.select(_db.ventas).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.ventas.usuarioId),
            ),
            leftOuterJoin(
              _db.ventaPagos,
              _db.ventaPagos.ventaId.equalsExp(_db.ventas.id),
            ),
          ])
          ..addColumns([primerMetodo, ultimoMetodo])
          ..groupBy([_db.ventas.id])
          ..orderBy([OrderingTerm.desc(_db.ventas.fecha)]);

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
      (rows) => rows.map((row) {
        final primero = row.read(primerMetodo);
        final mixto = primero != row.read(ultimoMetodo);
        return (
          row.readTable(_db.ventas),
          row.readTable(_db.usuarios).nombre,
          mixto
              ? null
              : (primero == null
                    ? MetodoPago.efectivo
                    : MetodoPago.values.byName(primero)),
          mixto,
        );
      }).toList(),
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
  /// Con [MetodoPago.credito] (fiado) exige un [clienteId] activo, valida el
  /// límite de crédito DENTRO de la transacción (lanza
  /// [ClienteNoDisponibleException] / [LimiteCreditoExcedidoException] sin
  /// escribir nada) y registra un cargo (+total) en el libro del cliente.
  ///
  /// [metodoPago]: se registra un pago por el total en `venta_pagos`; SOLO un
  /// pago en efectivo genera el movimiento de `caja_movimientos` (tarjeta y
  /// transferencia no entran a la caja física).
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
    MetodoPago metodoPago = MetodoPago.efectivo,
    String? clienteId,
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

      if (metodoPago == MetodoPago.credito) {
        final cliente = clienteId == null
            ? null
            : await (_db.select(_db.clientes)
                    ..where((t) => t.id.equals(clienteId) & t.deletedAt.isNull()))
                .getSingleOrNull();
        if (cliente == null || !cliente.activo) {
          throw ClienteNoDisponibleException(clienteId ?? '');
        }
        final limite = cliente.limiteCredito;
        if (limite != null) {
          final saldo = await saldoDeCliente(_db, cliente.id);
          if (saldo + total > limite) {
            throw LimiteCreditoExcedidoException(
              nombre: cliente.nombre,
              saldo: saldo,
              limite: limite,
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

      final pagoId = generateUuidV4();
      await _db
          .into(_db.ventaPagos)
          .insert(
            VentaPagosCompanion.insert(
              id: Value(pagoId),
              ventaId: ventaId,
              metodo: metodoPago,
              monto: total,
            ),
          );
      final pagoFila = await (_db.select(
        _db.ventaPagos,
      )..where((t) => t.id.equals(pagoId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'venta_pagos',
        registroId: pagoId,
        operacion: OperacionSync.insert,
        payload: ventaPagoPayload(pagoFila),
      );

      if (metodoPago == MetodoPago.credito) {
        await _insertarMovimientoCliente(
          clienteId: clienteId!,
          tipo: TipoMovimientoCliente.cargo,
          monto: total,
          ventaId: ventaId,
          usuarioId: usuarioId,
        );
      }

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

      if (metodoPago == MetodoPago.efectivo) {
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
      }

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

      // Lo cobrado a crédito se compensa en el libro del cliente (no toca la
      // caja: el fiado nunca entró a ella).
      final pagos = await obtenerPagos(id, venta.total);
      final enCredito = pagos
          .where((p) => p.metodo == MetodoPago.credito)
          .fold<int>(0, (suma, p) => suma + p.monto);
      if (enCredito > 0) {
        final cargo =
            await (_db.select(_db.movimientosCliente)
                  ..where(
                    (t) =>
                        t.ventaId.equals(id) &
                        t.tipo.equalsValue(TipoMovimientoCliente.cargo),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (cargo != null) {
          await _insertarMovimientoCliente(
            clienteId: cargo.clienteId,
            tipo: TipoMovimientoCliente.anulacion,
            monto: -enCredito,
            ventaId: id,
            usuarioId: usuarioId,
          );
        }
      }

      // Solo lo cobrado en efectivo entró a la caja: solo eso se compensa.
      final enEfectivo = await _montoEnEfectivo(id, venta.total);
      if (enEfectivo > 0) {
        final cajaMovId = generateUuidV4();
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                id: Value(cajaMovId),
                cajaSesionId: venta.cajaSesionId,
                tipo: TipoCajaMovimiento.venta,
                monto: -enEfectivo,
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
      }

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
