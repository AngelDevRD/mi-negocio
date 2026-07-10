import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';

/// Acceso a `empleados` y `pagos_empleados` (RF-EMP).
class EmployeesLocalDatasource {
  EmployeesLocalDatasource(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------
  // Empleados
  // ---------------------------------------------------------------------

  Stream<List<Empleado>> watchEmpleados({TipoEmpleado? tipo, bool? activo}) {
    final query = _db.select(_db.empleados)..where((t) => t.deletedAt.isNull());
    if (tipo != null) {
      query.where((t) => t.tipo.equalsValue(tipo));
    }
    if (activo != null) {
      query.where((t) => t.activo.equals(activo));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    return query.watch();
  }

  Future<Empleado?> obtenerEmpleado(String id) {
    final query = _db.select(_db.empleados)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return query.getSingleOrNull();
  }

  Future<String> crearEmpleado({
    required TipoEmpleado tipo,
    String? fotoPath,
    required String nombre,
    String? cedula,
    String? direccion,
    String? telefono,
    required DateTime fechaIngreso,
    int? salarioCents,
    String? frecuenciaPago,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final id = generateUuidV4();
      await _db
          .into(_db.empleados)
          .insert(
            EmpleadosCompanion.insert(
              id: Value(id),
              tipo: tipo,
              fotoPath: Value(fotoPath),
              nombre: nombre,
              cedula: Value(cedula),
              direccion: Value(direccion),
              telefono: Value(telefono),
              fechaIngreso: fechaIngreso,
              salario: Value(salarioCents),
              frecuenciaPago: Value(frecuenciaPago),
            ),
          );

      await _registrarAuditoria(
        usuarioId: usuarioId,
        accion: 'crear',
        entidadId: id,
        datosDespues: {
          'tipo': tipo.name,
          'nombre': nombre,
          'cedula': cedula,
          'salario': salarioCents,
        },
      );

      return id;
    });
  }

  Future<void> actualizarEmpleado({
    required String id,
    required TipoEmpleado tipo,
    String? fotoPath,
    required String nombre,
    String? cedula,
    String? direccion,
    String? telefono,
    required DateTime fechaIngreso,
    int? salarioCents,
    String? frecuenciaPago,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.empleados)..where((t) => t.id.equals(id))).write(
        EmpleadosCompanion(
          tipo: Value(tipo),
          fotoPath: Value(fotoPath),
          nombre: Value(nombre),
          cedula: Value(cedula),
          direccion: Value(direccion),
          telefono: Value(telefono),
          fechaIngreso: Value(fechaIngreso),
          salario: Value(salarioCents),
          frecuenciaPago: Value(frecuenciaPago),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      await _registrarAuditoria(
        usuarioId: usuarioId,
        accion: 'editar',
        entidadId: id,
        datosDespues: {
          'tipo': tipo.name,
          'nombre': nombre,
          'cedula': cedula,
          'salario': salarioCents,
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
      await (_db.update(_db.empleados)..where((t) => t.id.equals(id))).write(
        EmpleadosCompanion(
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
  // Pagos
  // ---------------------------------------------------------------------

  Stream<List<(PagosEmpleado, String)>> watchPagos(String empleadoId) {
    final query =
        _db.select(_db.pagosEmpleados).join([
            innerJoin(
              _db.usuarios,
              _db.usuarios.id.equalsExp(_db.pagosEmpleados.usuarioId),
            ),
          ])
          ..where(_db.pagosEmpleados.empleadoId.equals(empleadoId))
          ..orderBy([OrderingTerm.desc(_db.pagosEmpleados.fecha)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => (
              row.readTable(_db.pagosEmpleados),
              row.readTable(_db.usuarios).nombre,
            ),
          )
          .toList(),
    );
  }

  Stream<int> watchTotalPagadoCents(String empleadoId) {
    final sumExp = _db.pagosEmpleados.monto.sum();
    final query = _db.selectOnly(_db.pagosEmpleados)
      ..addColumns([sumExp])
      ..where(_db.pagosEmpleados.empleadoId.equals(empleadoId));
    return query.watchSingle().map((row) => row.read(sumExp) ?? 0);
  }

  /// Id de la sesión de caja abierta, si hay una (RF-CAJ).
  Future<String?> obtenerCajaAbiertaId() async {
    final query = _db.select(_db.cajaSesiones)
      ..where((t) => t.estado.equalsValue(EstadoCajaSesion.abierta));
    final sesion = await query.getSingleOrNull();
    return sesion?.id;
  }

  /// Registra el pago y, si [cajaSesionId] no es nulo, una salida en
  /// `caja_movimientos` (RN-20), junto con la auditoría.
  Future<String> registrarPago({
    required String empleadoId,
    required DateTime fecha,
    required int montoCents,
    String? periodo,
    String? cajaSesionId,
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final id = generateUuidV4();

      await _db
          .into(_db.pagosEmpleados)
          .insert(
            PagosEmpleadosCompanion.insert(
              id: Value(id),
              empleadoId: empleadoId,
              fecha: fecha,
              monto: montoCents,
              periodo: Value(periodo),
              cajaSesionId: Value(cajaSesionId),
              usuarioId: usuarioId,
            ),
          );

      await _registrarAuditoria(
        usuarioId: usuarioId,
        accion: 'crear',
        entidadId: id,
        datosDespues: {
          'empleadoId': empleadoId,
          'monto': montoCents,
          'periodo': periodo,
          'saleDeCaja': cajaSesionId != null,
        },
      );

      if (cajaSesionId != null) {
        await _db
            .into(_db.cajaMovimientos)
            .insert(
              CajaMovimientosCompanion.insert(
                cajaSesionId: cajaSesionId,
                tipo: TipoCajaMovimiento.pagoEmpleado,
                monto: -montoCents,
                referenciaId: Value(id),
                usuarioId: usuarioId,
              ),
            );
      }

      return id;
    });
  }

  // ---------------------------------------------------------------------
  // Auditoría (RF-AUD-02)
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
            modulo: 'empleados',
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
