import 'package:app_gestion/features/backup/data/services/backup_archive_builder.dart';
import 'package:app_gestion/features/backup/data/services/backup_file_service.dart';
import 'package:app_gestion/features/backup/domain/entities/backup_manifest.dart';
import 'package:share_plus/share_plus.dart';

/// Respaldo de mentira para las capturas: el selector de archivos del sistema
/// no existe en un test, así que "elegir" devuelve un respaldo ficticio ya
/// validado. No toca la base ni el disco.
class RespaldoVisual implements BackupFileService {
  @override
  Future<String?> elegirArchivoRespaldo() async => 'respaldo_demo.zip';

  @override
  Future<BackupArchive> validar(String rutaZip) async => BackupArchive(
    manifest: BackupManifest(
      schemaVersion: 3,
      appVersion: '1.0.0',
      fechaCreacion: DateTime.now().subtract(const Duration(days: 12)).toUtc(),
      negocioId: 'demo',
      negocioNombre: 'Colmado Doña Carmen',
    ),
    datos: const {},
    media: const {},
  );

  @override
  Future<XFile> exportar() async => XFile('respaldo_demo.zip');

  @override
  Future<void> compartir(XFile archivo) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
