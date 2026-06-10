import 'package:drift/drift.dart';

import '../enums.dart';
import 'base.dart';

/// Negocio registrado en esta instalación (RE-05: uno por instalación).
class Negocios extends BaseTable {
  TextColumn get nombre => text().withLength(min: 1, max: 120)();

  /// RNC o cédula del negocio (opcional).
  TextColumn get identificacion => text().nullable()();
  TextColumn get direccion => text().nullable()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get moneda => text().withDefault(const Constant('DOP'))();
}

/// Usuarios locales del negocio (RF-AUTH). Contraseña SOLO como hash PBKDF2.
@TableIndex(name: 'idx_usuarios_username', columns: {#username}, unique: true)
class Usuarios extends SoftDeleteTable {
  TextColumn get negocioId => text().references(Negocios, #id)();
  TextColumn get nombre => text().withLength(min: 1, max: 120)();
  TextColumn get username => text().withLength(min: 3, max: 60)();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  TextColumn get rol => textEnum<RolUsuario>()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
}

/// Espejo local de la licencia en Supabase (RF-LIC-04: caché para operar
/// offline con período de gracia).
class LicenciasCache extends BaseTable {
  TextColumn get tipo => textEnum<TipoLicencia>()();
  TextColumn get estado => textEnum<EstadoLicencia>()();
  TextColumn get claveLicencia => text().nullable()();
  TextColumn get deviceId => text()();
  DateTimeColumn get fechaActivacion => dateTime()();
  DateTimeColumn get fechaVencimiento => dateTime().nullable()();
  DateTimeColumn get ultimaValidacion => dateTime()();
}

/// Configuración del negocio como clave-valor (ej. `permitir_stock_negativo`,
/// `cajero_puede_cerrar_caja`, `dias_alerta_renovacion`).
class Configuraciones extends Table {
  TextColumn get clave => text()();
  TextColumn get valor => text()();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {clave};
}
