import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/profile_local_datasource.dart';

final profileLocalDatasourceProvider = Provider<ProfileLocalDatasource>((ref) {
  return ProfileLocalDatasource(ref.watch(appDatabaseProvider));
});

/// Negocio registrado en esta instalación (RE-05), para el perfil editable.
final negocioProvider = StreamProvider<Negocio?>((ref) {
  return ref.watch(profileLocalDatasourceProvider).watchNegocio();
});
