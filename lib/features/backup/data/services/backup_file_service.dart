import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/backup_manifest.dart';
import '../datasources/backup_dao.dart';
import 'backup_archive_builder.dart';

/// El respaldo elegido para restaurar es de una versión de schema distinta
/// a la de esta instalación (CU-12, alternativo A1).
class BackupSchemaException implements Exception {
  const BackupSchemaException({
    required this.versionRespaldo,
    required this.versionActual,
  });

  final int versionRespaldo;
  final int versionActual;

  @override
  String toString() =>
      'El respaldo es de la versión de esquema $versionRespaldo y esta '
      'instalación usa la versión $versionActual.';
}

/// Genera y restaura paquetes de respaldo (RF-RES-01/02): orquesta
/// [BackupDao] (datos), [BackupArchiveBuilder] (ZIP) y el sistema de
/// archivos (fotos en `media/`, compartir, selector de ZIP).
class BackupFileService {
  BackupFileService(this._dao);

  final BackupDao _dao;

  static final DateFormat _marcaTiempo = DateFormat('yyyyMMdd_HHmmss');

  /// Genera el ZIP de respaldo, lo guarda en el directorio temporal y
  /// registra la operación en el historial (RF-RES-03).
  Future<XFile> exportar() async {
    final negocio = await _dao.obtenerNegocio();
    final paquete = await PackageInfo.fromPlatform();

    final manifest = BackupManifest(
      schemaVersion: _dao.schemaVersion,
      appVersion: paquete.version,
      fechaCreacion: DateTime.now().toUtc(),
      negocioId: negocio?.id ?? '',
      negocioNombre: negocio?.nombre ?? '',
    );

    final datos = await _dao.volcarDatos();
    final media = await _recolectarMedia(negocio?.logoPath);

    final bytes = BackupArchiveBuilder.construir(
      manifest: manifest,
      datos: datos,
      media: media,
    );

    final directorio = await getTemporaryDirectory();
    final nombre = 'respaldo_${_marcaTiempo.format(DateTime.now())}.zip';
    final archivo = File('${directorio.path}/$nombre');
    await archivo.writeAsBytes(bytes, flush: true);

    await _dao.registrarRespaldo(
      tipo: TipoRespaldo.manual,
      archivo: nombre,
      tamanoBytes: bytes.length,
      resultado: 'ok',
    );

    return XFile(archivo.path, mimeType: 'application/zip', name: nombre);
  }

  Future<void> compartir(XFile archivo) async {
    await Share.shareXFiles([archivo], subject: 'Respaldo');
  }

  /// Abre el selector de archivos del sistema para elegir un ZIP de
  /// respaldo. Devuelve `null` si el usuario cancela.
  Future<String?> elegirArchivoRespaldo() async {
    final resultado = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    return resultado?.files.single.path;
  }

  /// Lee y valida el ZIP elegido. Lanza [BackupSchemaException] si la
  /// versión de schema no coincide (CU-12, A1) o [BackupFormatException] si
  /// el archivo está corrupto (CU-12, A2).
  Future<BackupArchive> validar(String rutaZip) async {
    final bytes = await File(rutaZip).readAsBytes();
    final paquete = BackupArchiveBuilder.leer(bytes);
    if (paquete.manifest.schemaVersion != _dao.schemaVersion) {
      throw BackupSchemaException(
        versionRespaldo: paquete.manifest.schemaVersion,
        versionActual: _dao.schemaVersion,
      );
    }
    return paquete;
  }

  /// Restaura [paquete] (ya validado con [validar]): reemplaza todos los
  /// datos y las fotos, y registra la operación en el historial.
  Future<void> restaurar(BackupArchive paquete, String nombreArchivo) async {
    await _dao.restaurarDatos(paquete.datos);
    await _restaurarMedia(paquete.media);

    final bytes = BackupArchiveBuilder.construir(
      manifest: paquete.manifest,
      datos: paquete.datos,
      media: paquete.media,
    );
    await _dao.registrarRespaldo(
      tipo: TipoRespaldo.manual,
      archivo: nombreArchivo,
      tamanoBytes: bytes.length,
      resultado: 'ok',
    );
  }

  /// Lee las fotos referenciadas (negocio, compras, empleados) y las indexa
  /// por su ruta relativa al directorio de documentos de la app (RE-07).
  Future<Map<String, List<int>>> _recolectarMedia(String? logoPath) async {
    final docs = await getApplicationDocumentsDirectory();
    final media = <String, List<int>>{};

    Future<void> agregar(String? rutaAbsoluta) async {
      if (rutaAbsoluta == null || rutaAbsoluta.isEmpty) return;
      final archivo = File(rutaAbsoluta);
      if (!await archivo.exists()) return;
      final relativa = rutaAbsoluta.startsWith(docs.path)
          ? rutaAbsoluta.substring(docs.path.length + 1)
          : archivo.uri.pathSegments.last;
      media[relativa] = await archivo.readAsBytes();
    }

    await agregar(logoPath);
    for (final ruta in await _dao.rutasFotosCompras()) {
      await agregar(ruta);
    }
    for (final ruta in await _dao.rutasFotosEmpleados()) {
      await agregar(ruta);
    }
    return media;
  }

  /// Escribe las fotos del respaldo en el directorio de documentos de la
  /// app, recreando la misma estructura relativa con la que se guardaron.
  Future<void> _restaurarMedia(Map<String, List<int>> media) async {
    final docs = await getApplicationDocumentsDirectory();
    for (final entry in media.entries) {
      final destino = File('${docs.path}/${entry.key}');
      await destino.parent.create(recursive: true);
      await destino.writeAsBytes(entry.value, flush: true);
    }
  }
}
