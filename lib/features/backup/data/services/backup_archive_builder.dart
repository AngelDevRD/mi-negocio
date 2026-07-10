import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/entities/backup_manifest.dart';

/// Excepción lanzada cuando el ZIP no es un respaldo válido (manifest
/// ausente o corrupto) -- CU-12, alternativo A2.
class BackupFormatException implements Exception {
  const BackupFormatException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Resultado de leer un paquete de respaldo: manifest + datos por tabla +
/// archivos de media (ruta relativa -> bytes).
class BackupArchive {
  const BackupArchive({
    required this.manifest,
    required this.datos,
    required this.media,
  });

  final BackupManifest manifest;
  final Map<String, List<Map<String, Object?>>> datos;
  final Map<String, List<int>> media;
}

/// Construye y lee el paquete ZIP de respaldo (RF-RES-01):
/// `manifest.json` + `data/<tabla>.json` + `media/<ruta original>`.
class BackupArchiveBuilder {
  const BackupArchiveBuilder._();

  static List<int> construir({
    required BackupManifest manifest,
    required Map<String, List<Map<String, Object?>>> datos,
    required Map<String, List<int>> media,
  }) {
    final archive = Archive();
    _agregarJson(archive, 'manifest.json', manifest.toJson());
    for (final entry in datos.entries) {
      _agregarJson(archive, 'data/${entry.key}.json', entry.value);
    }
    for (final entry in media.entries) {
      archive.addFile(
        ArchiveFile('media/${entry.key}', entry.value.length, entry.value),
      );
    }

    final bytes = ZipEncoder().encode(archive);
    if (bytes == null) {
      throw const BackupFormatException(
        'No se pudo generar el archivo de respaldo.',
      );
    }
    return bytes;
  }

  static BackupArchive leer(List<int> bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const BackupFormatException(
        'El archivo de respaldo está corrupto o no es un ZIP válido.',
      );
    }

    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      throw const BackupFormatException(
        'El archivo no es un respaldo válido (falta manifest.json).',
      );
    }
    final manifest = BackupManifest.fromJson(
      jsonDecode(utf8.decode(manifestFile.content as List<int>))
          as Map<String, dynamic>,
    );

    final datos = <String, List<Map<String, Object?>>>{};
    final media = <String, List<int>>{};
    for (final archivo in archive.files) {
      if (!archivo.isFile) continue;
      if (archivo.name.startsWith('data/') && archivo.name.endsWith('.json')) {
        final tabla = archivo.name.substring(
          'data/'.length,
          archivo.name.length - '.json'.length,
        );
        final filas = jsonDecode(utf8.decode(archivo.content as List<int>));
        datos[tabla] = [
          for (final fila in filas as List)
            (fila as Map<String, dynamic>).cast<String, Object?>(),
        ];
      } else if (archivo.name.startsWith('media/')) {
        media[archivo.name.substring('media/'.length)] =
            archivo.content as List<int>;
      }
    }

    return BackupArchive(manifest: manifest, datos: datos, media: media);
  }

  static void _agregarJson(Archive archive, String nombre, Object? contenido) {
    final bytes = utf8.encode(jsonEncode(contenido));
    archive.addFile(ArchiveFile(nombre, bytes.length, bytes));
  }
}
