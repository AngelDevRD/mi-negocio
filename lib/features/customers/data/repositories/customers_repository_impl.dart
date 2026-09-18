import '../../../../core/database/app_database.dart' as db;
import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_local_datasource.dart';

/// Implementación de clientes con fiado.
class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl(this._local);

  final CustomersLocalDatasource _local;

  Cliente _aEntidad((db.Cliente, int) fila) {
    final (c, saldo) = fila;
    return Cliente(
      id: c.id,
      nombre: c.nombre,
      telefono: c.telefono,
      nota: c.nota,
      limiteCredito: c.limiteCredito == null ? null : Money(c.limiteCredito!),
      activo: c.activo,
      saldo: Money(saldo),
    );
  }

  MovimientoCliente _movimientoAEntidad(
    (db.MovimientoClienteData, String) fila,
  ) {
    final (m, usuarioNombre) = fila;
    return MovimientoCliente(
      id: m.id,
      tipo: m.tipo,
      monto: Money(m.monto),
      ventaId: m.ventaId,
      metodoPago: m.metodoPago,
      nota: m.nota,
      fecha: m.fecha,
      usuarioNombre: usuarioNombre,
    );
  }

  ValidationFailure? _validarFicha(String nombre, Money? limiteCredito) {
    final n = nombre.trim();
    if (n.isEmpty) return const ValidationFailure('El nombre es obligatorio.');
    if (n.length > 120) {
      return const ValidationFailure(
        'El nombre no puede tener más de 120 caracteres.',
      );
    }
    if (limiteCredito != null && limiteCredito.isNegative) {
      return const ValidationFailure(
        'El límite de crédito no puede ser negativo.',
      );
    }
    return null;
  }

  String? _vacioANulo(String? texto) {
    final t = texto?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  @override
  Stream<List<Cliente>> watchClientes({String busqueda = '', bool? activo}) {
    return _local
        .watchClientes(busqueda: busqueda, activo: activo)
        .map((filas) => filas.map(_aEntidad).toList());
  }

  @override
  Future<Cliente?> obtenerCliente(String id) async {
    final fila = await _local.obtenerCliente(id);
    return fila == null ? null : _aEntidad(fila);
  }

  @override
  Stream<List<MovimientoCliente>> watchMovimientos(String clienteId) {
    return _local
        .watchMovimientos(clienteId)
        .map((filas) => filas.map(_movimientoAEntidad).toList());
  }

  @override
  Future<Result<String>> crearCliente({
    required String nombre,
    String? telefono,
    String? nota,
    Money? limiteCredito,
    required String usuarioId,
  }) async {
    final invalido = _validarFicha(nombre, limiteCredito);
    if (invalido != null) return Result.fail(invalido);
    final id = await _local.crearCliente(
      nombre: nombre.trim(),
      telefono: _vacioANulo(telefono),
      nota: _vacioANulo(nota),
      limiteCreditoCents: limiteCredito?.cents,
      usuarioId: usuarioId,
    );
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
    final invalido = _validarFicha(nombre, limiteCredito);
    if (invalido != null) return Result.fail(invalido);
    if (await _local.obtenerCliente(id) == null) {
      return const Result.fail(ValidationFailure('El cliente no existe.'));
    }
    await _local.actualizarCliente(
      id: id,
      nombre: nombre.trim(),
      telefono: _vacioANulo(telefono),
      nota: _vacioANulo(nota),
      limiteCreditoCents: limiteCredito?.cents,
      usuarioId: usuarioId,
    );
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> establecerActivo({
    required String id,
    required bool activo,
    required String usuarioId,
  }) async {
    if (await _local.obtenerCliente(id) == null) {
      return const Result.fail(ValidationFailure('El cliente no existe.'));
    }
    await _local.establecerActivo(id: id, activo: activo, usuarioId: usuarioId);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> eliminarCliente(
    String id, {
    required String usuarioId,
  }) async {
    if (await _local.obtenerCliente(id) == null) {
      return const Result.fail(ValidationFailure('El cliente no existe.'));
    }
    final eliminado = await _local.eliminarCliente(id, usuarioId: usuarioId);
    if (!eliminado) {
      return const Result.fail(
        BusinessRuleFailure(
          'El cliente tiene movimientos y no puede eliminarse: desactívalo '
          'para conservar su historial.',
          rule: 'FIADO-CLIENTE',
        ),
      );
    }
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
    if (monto.cents <= 0) {
      return const Result.fail(
        ValidationFailure('El monto del abono debe ser mayor que cero.'),
      );
    }
    if (metodo == MetodoPago.credito) {
      return const Result.fail(
        ValidationFailure('Un abono no puede pagarse con fiado.'),
      );
    }
    try {
      final id = await _local.registrarAbono(
        clienteId: clienteId,
        montoCents: monto.cents,
        metodo: metodo,
        usuarioId: usuarioId,
        nota: _vacioANulo(nota),
      );
      return Result.ok(id);
    } on ClienteInexistenteException {
      return const Result.fail(ValidationFailure('El cliente no existe.'));
    } on AbonoExcedeSaldoException catch (e) {
      return Result.fail(
        BusinessRuleFailure(
          'El abono de ${Money(e.monto).format()} supera el saldo pendiente '
          'de ${e.nombre}: ${Money(e.saldo).format()}.',
          rule: 'FIADO-ABONO',
        ),
      );
    } on SinCajaAbiertaException {
      return const Result.fail(
        BusinessRuleFailure(
          'Debe abrir una caja antes de registrar un abono en efectivo.',
          rule: 'RN-01',
        ),
      );
    }
  }
}
