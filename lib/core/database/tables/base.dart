import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Generador de PKs. Público: Drift copia la expresión `clientDefault` al
/// código generado en la librería de `app_database.dart`.
String generateUuidV4() => _uuid.v4();

/// Columnas comunes a todas las tablas: UUID v4 como PK y timestamps UTC
/// (RNF-12: requisito para la sincronización offline-first).
abstract class BaseTable extends Table {
  TextColumn get id => text().clientDefault(generateUuidV4)();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Tablas con soft delete (RN-13): las lecturas filtran `deletedAt IS NULL`.
abstract class SoftDeleteTable extends BaseTable {
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
