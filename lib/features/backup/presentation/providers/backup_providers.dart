import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/backup_dao.dart';
import '../../data/services/backup_file_service.dart';

final backupDaoProvider = Provider<BackupDao>(
  (ref) => BackupDao(ref.watch(appDatabaseProvider)),
);

final backupFileServiceProvider = Provider<BackupFileService>(
  (ref) => BackupFileService(ref.watch(backupDaoProvider)),
);

/// Historial de respaldos realizados (RF-RES-03), más reciente primero.
final historialRespaldosProvider = StreamProvider<List<Respaldo>>(
  (ref) => ref.watch(backupDaoProvider).watchHistorial(),
);
