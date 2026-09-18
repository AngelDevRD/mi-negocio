import 'dart:async';

import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/customers/domain/entities/cliente.dart';
import 'package:app_gestion/features/customers/domain/repositories/customers_repository.dart';

/// Repositorio de clientes en memoria para widget tests (sin drift: sus
/// streams dejan timers pendientes). Aplica las mismas reglas que el real en
/// lo que las pantallas necesitan: abono > saldo, monto <= 0, caja cerrada y
/// eliminar con movimientos.
class RepoClientesFalso implements CustomersRepository {
  RepoClientesFalso([List<Cliente> iniciales = const []]) {
    _clientes.addAll(iniciales);
  }

  final _clientes = <Cliente>[];
  final _movimientos = <String, List<MovimientoCliente>>{};
  final _cambios = StreamController<void>.broadcast();
  int _secuencia = 0;

  /// Si es `false`, un abono en efectivo falla (RN-01).
  bool cajaAbierta = true;

  /// Llamadas registradas, para verificar en los tests.
  final creados = <({String nombre, String? telefono, Money? limite})>[];
  final actualizados = <({String id, Money? limite})>[];
  final abonos = <({String clienteId, Money monto, MetodoPago metodo})>[];
  int llamadasAbono = 0;

  List<Cliente> get clientes => List.unmodifiable(_clientes);

  Future<void> cerrar() => _cambios.close();

  /// Agrega un cargo al libro del cliente (deja al cliente debiendo).
  void cargo(String clienteId, int centavos, {String? ventaId}) {
    _movimientos
        .putIfAbsent(clienteId, () => [])
        .add(
          MovimientoCliente(
            id: 'm${_secuencia++}',
            tipo: TipoMovimientoCliente.cargo,
            monto: Money(centavos),
            ventaId: ventaId ?? 'venta-$clienteId',
            fecha: DateTime(2026, 1, 15, 10),
            usuarioNombre: 'Ana Admin',
          ),
        );
    _ajustarSaldo(clienteId, centavos);
  }

  void movimiento(String clienteId, MovimientoCliente m) {
    _movimientos.putIfAbsent(clienteId, () => []).add(m);
    _ajustarSaldo(clienteId, m.monto.cents);
  }

  void _ajustarSaldo(String id, int delta) {
    final i = _clientes.indexWhere((c) => c.id == id);
    _clientes[i] = _clientes[i].copyWith(
      saldo: Money(_clientes[i].saldo.cents + delta),
    );
    _cambios.add(null);
  }

  Stream<T> _reactivo<T>(T Function() calcular) async* {
    yield calcular();
    await for (final _ in _cambios.stream) {
      yield calcular();
    }
  }

  @override
  Stream<List<Cliente>> watchClientes({String busqueda = '', bool? activo}) {
    return _reactivo(() {
      final q = busqueda.trim().toLowerCase();
      final lista = [
        for (final c in _clientes)
          if ((activo == null || c.activo == activo) &&
              (q.isEmpty ||
                  c.nombre.toLowerCase().contains(q) ||
                  (c.telefono ?? '').toLowerCase().contains(q)))
            c,
      ]..sort((a, b) => a.nombre.compareTo(b.nombre));
      return lista;
    });
  }

  @override
  Future<Cliente?> obtenerCliente(String id) async {
    for (final c in _clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Stream<List<MovimientoCliente>> watchMovimientos(String clienteId) {
    return _reactivo(
      () => List.of(
        _movimientos[clienteId] ?? const <MovimientoCliente>[],
      ).reversed.toList(),
    );
  }

  @override
  Future<Result<String>> crearCliente({
    required String nombre,
    String? telefono,
    String? nota,
    Money? limiteCredito,
    required String usuarioId,
  }) async {
    if (nombre.trim().isEmpty) {
      return const Result.fail(ValidationFailure('El nombre es obligatorio.'));
    }
    final id = 'c${++_secuencia}';
    final tel = (telefono == null || telefono.trim().isEmpty)
        ? null
        : telefono.trim();
    creados.add((nombre: nombre.trim(), telefono: tel, limite: limiteCredito));
    _clientes.add(
      Cliente(
        id: id,
        nombre: nombre.trim(),
        telefono: tel,
        limiteCredito: limiteCredito,
        activo: true,
        saldo: const Money(0),
      ),
    );
    _cambios.add(null);
    return Result.ok(id);
  }

  @override
  Future<Result<void>> actualizarCliente({
    required String id,
    required String nombre,
    String? telefono,
    String? nota,
    Money? limiteCredito,
    required String usuarioId,
  }) async {
    actualizados.add((id: id, limite: limiteCredito));
    final i = _clientes.indexWhere((c) => c.id == id);
    _clientes[i] = _clientes[i].copyWith(
      nombre: nombre.trim(),
      telefono: telefono,
      limiteCredito: limiteCredito,
    );
    _cambios.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  }) async {
    final i = _clientes.indexWhere((c) => c.id == id);
    _clientes[i] = _clientes[i].copyWith(activo: activo);
    _cambios.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> eliminarCliente(
    String id, {
    required String usuarioId,
  }) async {
    if ((_movimientos[id] ?? const []).isNotEmpty) {
      return const Result.fail(
        BusinessRuleFailure(
          'El cliente tiene movimientos y no puede eliminarse: desactívalo '
          'para conservar su historial.',
          rule: 'FIADO-CLIENTE',
        ),
      );
    }
    _clientes.removeWhere((c) => c.id == id);
    _cambios.add(null);
    return const Result.ok(null);
  }

  @override
  Future<Result<String>> registrarAbono({
    required String clienteId,
    required Money monto,
    required MetodoPago metodo,
    required String usuarioId,
    String? nota,
  }) async {
    llamadasAbono++;
    final cliente = await obtenerCliente(clienteId);
    if (monto.cents <= 0) {
      return const Result.fail(
        ValidationFailure('El monto del abono debe ser mayor que cero.'),
      );
    }
    if (monto.cents > cliente!.saldo.cents) {
      return Result.fail(
        BusinessRuleFailure(
          'El abono de ${monto.format()} supera el saldo pendiente de '
          '${cliente.nombre}: ${cliente.saldo.format()}.',
          rule: 'FIADO-ABONO',
        ),
      );
    }
    if (metodo == MetodoPago.efectivo && !cajaAbierta) {
      return const Result.fail(
        BusinessRuleFailure(
          'Debe abrir una caja antes de registrar un abono en efectivo.',
          rule: 'RN-01',
        ),
      );
    }
    abonos.add((clienteId: clienteId, monto: monto, metodo: metodo));
    movimiento(
      clienteId,
      MovimientoCliente(
        id: 'm${_secuencia++}',
        tipo: TipoMovimientoCliente.abono,
        monto: Money(-monto.cents),
        metodoPago: metodo,
        nota: nota,
        fecha: DateTime(2026, 1, 16, 9),
        usuarioNombre: 'Ana Admin',
      ),
    );
    return const Result.ok('abono');
  }
}
