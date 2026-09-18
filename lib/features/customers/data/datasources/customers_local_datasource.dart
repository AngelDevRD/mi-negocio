import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/sync/payloads/auditoria_payload.dart';
import '../../../../core/sync/payloads/operacion_payloads.dart';
import '../../../../core/sync/sync_queue_writer.dart';

/// Saldo del cliente en centavos: suma de sus movimientos (libro mayor). Es
/// la ÚNICA fórmula del saldo; también la usa la venta a crédito.
Future<int> saldoDeCliente(AppDatabase db, String clienteId) async {
  final suma = db.movimientosCliente.monto.sum();
  final query = db.selectOnly(db.movimientosCliente)
    ..addColumns([suma])
    ..where(db.movimientosCliente.clienteId.equals(clienteId));
  final fila = await query.getSingle();
  return fila.read(suma) ?? 0;
}

/// El cliente no existe (o fue eliminado).
class ClienteInexistenteException implements Exception {
  const ClienteInexistenteException(this.clienteId);

  final String clienteId;
}

/// Abono en efectivo sin caja abierta (RN-01).
class SinCajaAbiertaException implements Exception {
  const SinCajaAbiertaException();
}

/// El abono supera el saldo pendiente del cliente.
class AbonoExcedeSaldoException implements Exception {
  const AbonoExcedeSaldoException({
    required this.nombre,
    required this.saldo,
    required this.monto,
  });

  final String nombre;
  final int saldo;
  final int monto;
}

/// Acceso a `clientes` y `movimientos_cliente` (fiado).
class CustomersLocalDatasource {
  CustomersLocalDatasource(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------
  // Lectura
  // ---------------------------------------------------------------------

  /// Clientes con su saldo calculado, por nombre. [busqueda] filtra por
  /// nombre o teléfono; [activo] por estado (`null` = todos). Reactivo: se
  /// reemite al cambiar clientes o movimientos.
  Stream<List<(Cliente, int)>> watchClientes({
    String busqueda = '',
    bool? activo,
  }) {
    final suma = _db.movimientosCliente.monto.sum();
    final query =
        _db.select(_db.clientes).join([
            leftOuterJoin(
              _db.movimientosCliente,
              _db.movimientosCliente.clienteId.equalsExp(_db.clientes.id),
            ),
          ])
          ..addColumns([suma])
          ..where(_db.clientes.deletedAt.isNull())
          ..groupBy([_db.clientes.id])
          ..orderBy([OrderingTerm.asc(_db.clientes.nombre)]);

    final texto = busqueda.trim();
    if (texto.isNotEmpty) {
      query.where(
        _db.clientes.nombre.like('%$texto%') |
            _db.clientes.telefono.like('%$texto%'),
      );
    }
    if (activo != null) query.where(_db.clientes.activo.equals(activo));

    return query.watch().map(
      (filas) => [
        for (final f in filas) (f.readTable(_db.clientes), f.read(suma) ?? 0),
      ],
    );
  }

  Future<(Cliente, int)?> obtenerCliente(String id) async {
    final fila = await (_db.select(
      _db.clientes,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    if (fila == null) return null;
    return (fila, await saldoDeCliente(_db, id));
  }

  /// Historial del cliente con el nombre del usuario, más reciente primero.
  Stream<List<(MovimientoClienteData, String)>> watchMovimientos(
    String clienteId,
  ) {
    final query =
        _db.select(_db.movimientosCliente).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.movimientosCliente.usuarioId),
            ),
          ])
          ..where(_db.movimientosCliente.clienteId.equals(clienteId))
          ..orderBy([
            OrderingTerm.desc(_db.movimientosCliente.fecha),
            OrderingTerm.desc(_db.movimientosCliente.createdAt),
          ]);
    return query.watch().map(
      (filas) => [
        for (final f in filas)
          (
            f.readTable(_db.movimientosCliente),
            f.readTable(_db.usuarios).nombre,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Clientes
  // ---------------------------------------------------------------------

  Future<String> crearCliente({
    required String nombre,
    String? telefono,
    String? nota,
    int? limiteCreditoCents,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final id = generateUuidV4();
      await _db
          .into(_db.clientes)
          .insert(
            ClientesCompanion.insert(
              id: Value(id),
              nombre: nombre,
              telefono: Value(telefono),
              nota: Value(nota),
              limiteCredito: Value(limiteCreditoCents),
            ),
          );
      await _encolarCliente(id, OperacionSync.insert);
      await _auditar(
        usuarioId: usuarioId,
        accion: 'crear',
        entidadId: id,
        datosDespues: {
          'nombre': nombre,
          'telefono': telefono,
          'limite_credito': limiteCreditoCents,
        },
      );
      return id;
    });
  }

  Future<void> actualizarCliente({
    required String id,
    required String nombre,
    String? telefono,
    String? nota,
    int? limiteCreditoCents,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.clientes)..where((t) => t.id.equals(id))).write(
        ClientesCompanion(
          nombre: Value(nombre),
          telefono: Value(telefono),
          nota: Value(nota),
          limiteCredito: Value(limiteCreditoCents),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _encolarCliente(id, OperacionSync.update);
      await _auditar(
        usuarioId: usuarioId,
        accion: 'editar',
        entidadId: id,
        datosDespues: {
          'nombre': nombre,
          'telefono': telefono,
          'limite_credito': limiteCreditoCents,
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
      await (_db.update(_db.clientes)..where((t) => t.id.equals(id))).write(
        ClientesCompanion(
          activo: Value(activo),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _encolarCliente(id, OperacionSync.update);
      await _auditar(
        usuarioId: usuarioId,
        accion: activo ? 'activar' : 'desactivar',
        entidadId: id,
        datosDespues: {'activo': activo},
      );
    });
  }

  /// Borrado lógico. Devuelve `false` SIN escribir nada si el cliente tiene
  /// movimientos (su historial debe conservarse): solo puede desactivarse.
  Future<bool> eliminarCliente(String id, {required String usuarioId}) {
    return _db.transaction(() async {
      final movimientos = await (_db.select(
        _db.movimientosCliente,
      )..where((t) => t.clienteId.equals(id))).get();
      if (movimientos.isNotEmpty) return false;

      await (_db.update(_db.clientes)..where((t) => t.id.equals(id))).write(
        ClientesCompanion(
          deletedAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _encolarCliente(id, OperacionSync.update);
      await _auditar(usuarioId: usuarioId, accion: 'eliminar', entidadId: id);
      return true;
    });
  }

  // ---------------------------------------------------------------------
  // Abonos
  // ---------------------------------------------------------------------

  /// Registra un abono en UNA transacción: movimiento `abono` (monto
  /// negativo) y, si es en efectivo, el `caja_movimiento` `abonoCliente`
  /// (+monto) con `referenciaId` = id del movimiento. Tarjeta/transferencia
  /// no tocan la caja. Lanza [ClienteInexistenteException],
  /// [AbonoExcedeSaldoException] o [SinCajaAbiertaException] SIN escribir.
  Future<String> registrarAbono({
    required String clienteId,
    required int montoCents,
    required MetodoPago metodo,
    required String usuarioId,
    String? nota,
  }) {
    return _db.transaction(() async {
      final cliente =
          await (_db.select(_db.clientes)
                ..where((t) => t.id.equals(clienteId) & t.deletedAt.isNull()))
              .getSingleOrNull();
      if (cliente == null) throw ClienteInexistenteException(clienteId);

      final saldo = await saldoDeCliente(_db, clienteId);
      if (montoCents > saldo) {
        throw AbonoExcedeSaldoException(
          nombre: cliente.nombre,
          saldo: saldo,
          monto: montoCents,
        );
      }

      String? cajaSesionId;
      if (metodo == MetodoPago.efectivo) {
        cajaSesionId = await _cajaAbiertaId();
        if (cajaSesionId == null) throw const SinCajaAbiertaException();
      }

      final movId = generateUuidV4();
      await _db
          .into(_db.movimientosCliente)
          .insert(
            MovimientosClienteCompanion.insert(
              id: Value(movId),
              clienteId: clienteId,
              tipo: TipoMovimientoCliente.abono,
              monto: -montoCents,
              metodoPago: Value(metodo),
              cajaSesionId: Value(cajaSesionId),
              usuarioId: usuarioId,
              nota: Value(nota),
            ),
          );
      final movFila = await (_db.select(
        _db.movimientosCliente,
      )..where((t) => t.id.equals(movId))).getSingle();
      await enqueueSync(
        _db,
        tabla: 'movimientos_cliente',
        registroId: movId,
        operacion: OperacionSync.insert,
        payload: movimientoClientePayload(movFila),
      );

      if (cajaSesionId != null) {
        final cajaMovId = generateUuidV4();
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                id: Value(cajaMovId),
                cajaSesionId: cajaSesionId,
                tipo: TipoCajaMovimiento.abonoCliente,
                monto: montoCents,
                motivo: Value('Abono de ${cliente.nombre}'),
                referenciaId: Value(movId),
                usuarioId: usuarioId,
              ),
            );
        final cajaFila = await (_db.select(
          _db.cajaMovimientos,
        )..where((t) => t.id.equals(cajaMovId))).getSingle();
        await enqueueSync(
          _db,
          tabla: 'caja_movimientos',
          registroId: cajaMovId,
          operacion: OperacionSync.insert,
          payload: cajaMovimientoPayload(cajaFila),
        );
      }

      await _auditar(
        usuarioId: usuarioId,
        accion: 'abonar',
        entidadId: movId,
        datosDespues: {
          'cliente_id': clienteId,
          'monto': montoCents,
          'metodo': metodo.name,
        },
      );
      return movId;
    });
  }

  // ---------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------

  /// Sesión de caja abierta más reciente (misma regla tolerante que ventas).
  Future<String?> _cajaAbiertaId() async {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta))
      ..orderBy([(t) => OrderingTerm.desc(t.fechaApertura)])
      ..limit(1);
    return (await query.getSingleOrNull())?.id;
  }

  Future<void> _encolarCliente(String id, OperacionSync operacion) async {
    final fila = await (_db.select(
      _db.clientes,
    )..where((t) => t.id.equals(id))).getSingle();
    await enqueueSync(
      _db,
      tabla: 'clientes',
      registroId: id,
      operacion: operacion,
      payload: clientePayload(fila),
    );
  }

  Future<void> _auditar({
    required String usuarioId,
    required String accion,
    String? entidadId,
    Map<String, Object?>? datosDespues,
  }) async {
    final auditId = generateUuidV4();
    await _db
        .into(_db.auditoria)
        .insert(
          AuditoriaCompanion.insert(
            id: Value(auditId),
            usuarioId: usuarioId,
            accion: accion,
            modulo: 'clientes',
            entidadId: Value(entidadId),
            datosDespues: Value(
              datosDespues == null ? null : jsonEncode(datosDespues),
            ),
          ),
        );
    final fila = await (_db.select(
      _db.auditoria,
    )..where((t) => t.id.equals(auditId))).getSingle();
    await enqueueSync(
      _db,
      tabla: 'auditoria',
      registroId: auditId,
      operacion: OperacionSync.insert,
      payload: auditoriaPayload(fila),
    );
  }
}
