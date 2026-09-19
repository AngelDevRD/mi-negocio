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
  BackupFileService(
    this._dao, {
    Future<Directory> Function()? directorioDocumentos,
  }) : _directorioDocumentos =
           directorioDocumentos ?? getApplicationDocumentsDirectory;

  final BackupDao _dao;

  /// Carpeta de documentos de la app (donde viven las fotos). Se inyecta en
  /// los tests; en la app es la de `path_provider`.
  final Future<Directory> Function() _directorioDocumentos;

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

  /// Lee y valida el ZIP elegido. Lanza [BackupSchemaException] si el
  /// respaldo es de una versión de schema MAYOR que la de esta instalación
  /// (CU-12, A1) o [BackupFormatException] si el archivo está corrupto o
  /// manipulado (CU-12, A2).
  ///
  /// REGLA DE VERSIONES: se acepta un respaldo de versión MENOR o igual.
  /// Restaurar una versión antigua es válido mientras las migraciones solo
  /// AÑADAN tablas (v2: `venta_pagos`; v3: `clientes` y `movimientos_cliente`):
  /// las tablas nuevas quedan vacías y las ventas viejas, sin `venta_pagos`,
  /// se leen como efectivo. Si una migración futura cambia o elimina COLUMNAS,
  /// esta regla debe revisarse (un respaldo viejo ya no encajaría tal cual).
  Future<BackupArchive> validar(String rutaZip) async {
    final bytes = await File(rutaZip).readAsBytes();
    final paquete = BackupArchiveBuilder.leer(bytes);
    final version = paquete.manifest.schemaVersion;
    if (version < 1) throw const BackupFormatException.invalido();
    if (version > _dao.schemaVersion) {
      throw BackupSchemaException(
        versionRespaldo: version,
        versionActual: _dao.schemaVersion,
      );
    }
    if (!_dao.datosCompatibles(paquete.datos)) {
      throw const BackupFormatException.invalido();
    }
    return paquete;
  }

  /// Restaura [paquete] (ya validado con [validar]): reemplaza todos los
  /// datos y las fotos, y registra la operación en el historial.
  ///
  /// Se valida TODO (rutas de las fotos y columnas de los datos) ANTES de
  /// escribir ningún archivo o tocar la base; no se confía en que [validar]
  /// ya lo hiciera.
  Future<void> restaurar(BackupArchive paquete, String nombreArchivo) async {
    final docs = await _directorioDocumentos();
    final fotos = _planificarMedia(docs, paquete.media);
    if (!_dao.datosCompatibles(paquete.datos)) {
      throw const BackupFormatException.invalido();
    }

    await _dao.restaurarDatos(paquete.datos);
    for (final foto in fotos) {
      await foto.destino.parent.create(recursive: true);
      await foto.destino.writeAsBytes(foto.bytes, flush: true);
    }

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
    final docs = await _directorioDocumentos();
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

  /// Calcula el destino de cada foto dentro de [docs] (misma estructura
  /// relativa con la que se guardaron) y exige que TODAS queden dentro de esa
  /// carpeta. Lanza [BackupFormatException] sin haber escrito nada si alguna
  /// ruta es absoluta, contiene `..` o se sale de [docs].
  List<({File destino, List<int> bytes})> _planificarMedia(
    Directory docs,
    Map<String, List<int>> media,
  ) {
    final base = Directory(docs.path).absolute.uri;
    return [
      for (final entry in media.entries)
        (() {
          final relativa = BackupArchiveBuilder.rutaRelativaSegura(entry.key);
          // Segunda barrera: aunque la ruta ya es segura, se resuelve como URI
          // y se comprueba que siga bajo la carpeta de documentos.
          final resuelta = base.resolveUri(
            Uri(pathSegments: relativa.split('/')),
          );
          if (!resuelta.path.startsWith(base.path)) {
            throw const BackupFormatException.invalido();
          }
          return (destino: File('${docs.path}/$relativa'), bytes: entry.value);
        })(),
    ];
  }
}
