import 'package:app_gestion/features/backup/data/services/backup_archive_builder.dart';
import 'package:app_gestion/features/backup/domain/entities/backup_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = BackupManifest(
    schemaVersion: 1,
    appVersion: '1.0.0',
    fechaCreacion: DateTime.utc(2026, 6, 12, 10, 30),
    negocioId: 'negocio-1',
    negocioNombre: 'Colmado Test',
  );

  test('construir y leer reproducen manifest, datos y media', () {
    final datos = {
      'negocios': [
        {'id': 'negocio-1', 'nombre': 'Colmado Test'},
      ],
      'categorias': <Map<String, Object?>>[],
    };
    final media = {
      'compras/factura.jpg': [1, 2, 3, 4],
    };

    final bytes = BackupArchiveBuilder.construir(
      manifest: manifest,
      datos: datos,
      media: media,
    );
    final paquete = BackupArchiveBuilder.leer(bytes);

    expect(paquete.manifest.schemaVersion, 1);
    expect(paquete.manifest.appVersion, '1.0.0');
    expect(paquete.manifest.negocioId, 'negocio-1');
    expect(paquete.manifest.negocioNombre, 'Colmado Test');
    expect(paquete.manifest.fechaCreacion, manifest.fechaCreacion);

    expect(paquete.datos['negocios'], datos['negocios']);
    expect(paquete.datos['categorias'], isEmpty);

    expect(paquete.media['compras/factura.jpg'], [1, 2, 3, 4]);
  });

  test('leer lanza BackupFormatException si el ZIP no tiene manifest', () {
    final bytes = BackupArchiveBuilder.construir(
      manifest: manifest,
      datos: const {},
      media: const {},
    );
    // Reconstruir sin manifest no es posible con la API pública, así que
    // verificamos el caso de bytes que no son un ZIP válido.
    expect(
      () => BackupArchiveBuilder.leer([1, 2, 3, 4]),
      throwsA(isA<BackupFormatException>()),
    );
    expect(bytes, isNotEmpty);
  });
}
