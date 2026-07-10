import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';

/// Acceso a las tablas `negocios` y `usuarios` (RF-AUTH).
class AuthLocalDatasource {
  AuthLocalDatasource(this._db);

  final AppDatabase _db;

  Future<bool> hayNegocio() async {
    final row = await _db.select(_db.negocios).getSingleOrNull();
    return row != null;
  }

  Future<String> obtenerNegocioId() async {
    final row = await (_db.select(_db.negocios)..limit(1)).getSingle();
    return row.id;
  }

  Future<String> crearNegocio({
    required String nombre,
    String? identificacion,
    String? direccion,
    String? telefono,
    String? email,
  }) async {
    final id = generateUuidV4();
    await _db
        .into(_db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(id),
            nombre: nombre,
            identificacion: Value(identificacion),
            direccion: Value(direccion),
            telefono: Value(telefono),
            email: Value(email),
          ),
        );
    return id;
  }

  Future<Usuario> crearUsuario({
    required String negocioId,
    required String nombre,
    required String username,
    required String passwordHash,
    required String salt,
    required RolUsuario rol,
  }) async {
    final id = generateUuidV4();
    final companion = UsuariosCompanion.insert(
      id: Value(id),
      negocioId: negocioId,
      nombre: nombre,
      username: username,
      passwordHash: passwordHash,
      salt: salt,
      rol: rol,
    );
    await _db.into(_db.usuarios).insert(companion);
    return obtenerPorId(id).then((row) => row!);
  }

  /// Crea un Cajero y registra la auditoría (RF-AUD-02): [actorId] es el
  /// Administrador que ejecuta la acción.
  Future<Usuario> crearCajeroConAuditoria({
    required String negocioId,
    required String nombre,
    required String username,
    required String passwordHash,
    required String salt,
    required String actorId,
  }) {
    return _db.transaction(() async {
      final usuario = await crearUsuario(
        negocioId: negocioId,
        nombre: nombre,
        username: username,
        passwordHash: passwordHash,
        salt: salt,
        rol: RolUsuario.cajero,
      );
      await _registrarAuditoria(
        usuarioId: actorId,
        accion: 'crear',
        entidadId: usuario.id,
        datosDespues: {
          'nombre': nombre,
          'username': username,
          'rol': RolUsuario.cajero.name,
        },
      );
      return usuario;
    });
  }

  Future<Usuario?> obtenerPorUsername(String username) {
    return (_db.select(_db.usuarios)
          ..where((t) => t.username.equals(username) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<Usuario?> obtenerPorId(String id) {
    return (_db.select(
      _db.usuarios,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  Future<List<Usuario>> listar() {
    return (_db.select(_db.usuarios)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
  }

  Future<bool> existeUsername(String username) async {
    final row = await obtenerPorUsername(username);
    return row != null;
  }

  Future<int> contarAdministradoresActivos() async {
    final query = _db.selectOnly(_db.usuarios)
      ..addColumns([_db.usuarios.id.count()])
      ..where(
        _db.usuarios.deletedAt.isNull() &
            _db.usuarios.activo.equals(true) &
            _db.usuarios.rol.equalsValue(RolUsuario.administrador),
      );
    final row = await query.getSingle();
    return row.read(_db.usuarios.id.count()) ?? 0;
  }

  /// Cambia la contraseña y registra la auditoría (RF-AUD-02): [accion] es
  /// `'resetear_password'` (el Administrador resetea la de otro usuario) o
  /// `'cambiar_password'` (el propio usuario), y [actorId] es quien ejecuta
  /// la acción.
  Future<void> actualizarPassword(
    String id,
    String passwordHash,
    String salt, {
    required String actorId,
    required String accion,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.usuarios)..where((t) => t.id.equals(id))).write(
        UsuariosCompanion(
          passwordHash: Value(passwordHash),
          salt: Value(salt),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _registrarAuditoria(
        usuarioId: actorId,
        accion: accion,
        entidadId: id,
      );
    });
  }

  /// Activa/desactiva una cuenta y registra la auditoría (RF-AUD-02):
  /// [actorId] es el Administrador que ejecuta la acción.
  Future<void> establecerActivo(
    String id,
    bool activo, {
    required String actorId,
  }) {
    return _db.transaction(() async {
      await (_db.update(_db.usuarios)..where((t) => t.id.equals(id))).write(
        UsuariosCompanion(
          activo: Value(activo),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await _registrarAuditoria(
        usuarioId: actorId,
        accion: activo ? 'activar' : 'desactivar',
        entidadId: id,
        datosAntes: {'activo': !activo},
        datosDespues: {'activo': activo},
      );
    });
  }

  // ---------------------------------------------------------------------
  // Auditoría (RF-AUD-02)
  // ---------------------------------------------------------------------

  Future<void> _registrarAuditoria({
    required String usuarioId,
    required String accion,
    String? entidadId,
    Map<String, Object?>? datosAntes,
    Map<String, Object?>? datosDespues,
  }) {
    return _db
        .into(_db.auditoria)
        .insert(
          AuditoriaCompanion.insert(
            usuarioId: usuarioId,
            accion: accion,
            modulo: 'usuarios',
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
