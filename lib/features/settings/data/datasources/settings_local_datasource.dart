import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Lectura/escritura de la tabla clave-valor `configuraciones` con claves
/// tipadas. Por ahora solo `permitir_stock_negativo` (RN-12).
///
/// Las configuraciones NO se encolan para sync: no existe un payload de
/// configuración en `core/sync/payloads`.
class SettingsLocalDatasource {
  SettingsLocalDatasource(this._db);

  final AppDatabase _db;

  static const clavePermitirStockNegativo = 'permitir_stock_negativo';

  /// Booleano guardado como 'true'/'false'; ausente = `true` (por defecto se
  /// permite vender sin stock, para no romper negocios con inventario sin
  /// llevar al día).
  static bool _leerBool(String? valor) => valor != 'false';

  SimpleSelectStatement<$ConfiguracionesTable, Configuracione> _fila() =>
      _db.select(_db.configuraciones)
        ..where((t) => t.clave.equals(clavePermitirStockNegativo));

  Stream<bool> watchPermitirStockNegativo() =>
      _fila().watchSingleOrNull().map((fila) => _leerBool(fila?.valor));

  Future<bool> permitirStockNegativo() async =>
      _leerBool((await _fila().getSingleOrNull())?.valor);

  /// Guarda el ajuste y registra la auditoría (usuario, `actualizar`,
  /// módulo `configuracion`, antes/después) en una sola transacción.
  Future<void> establecerPermitirStockNegativo(
    bool valor, {
    required String usuarioId,
  }) {
    return _db.transaction(() async {
      final antes = await permitirStockNegativo();
      await _db
          .into(_db.configuraciones)
          .insertOnConflictUpdate(
            ConfiguracionesCompanion.insert(
              clave: clavePermitirStockNegativo,
              valor: valor.toString(),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
      await _db
          .into(_db.auditoria)
          .insert(
            AuditoriaCompanion.insert(
              usuarioId: usuarioId,
              accion: 'actualizar',
              modulo: 'configuracion',
              entidadId: const Value(clavePermitirStockNegativo),
              datosAntes: Value(
                jsonEncode({clavePermitirStockNegativo: antes}),
              ),
              datosDespues: Value(
                jsonEncode({clavePermitirStockNegativo: valor}),
              ),
            ),
          );
    });
  }
}
