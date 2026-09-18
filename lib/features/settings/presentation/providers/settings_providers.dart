import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/settings_local_datasource.dart';

final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>((
  ref,
) {
  return SettingsLocalDatasource(ref.watch(appDatabaseProvider));
});

/// ¿Se permite vender con stock insuficiente? (RN-12; por defecto sí).
final permitirStockNegativoProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsLocalDatasourceProvider)
      .watchPermitirStockNegativo();
});
