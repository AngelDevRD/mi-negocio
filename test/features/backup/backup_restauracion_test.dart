import 'dart:convert';
import 'dart:io';

import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/features/backup/data/datasources/backup_dao.dart';
import 'package:app_gestion/features/backup/data/services/backup_archive_builder.dart';
import 'package:app_gestion/features/backup/data/services/backup_file_service.dart';
import 'package:app_gestion/features/backup/domain/entities/backup_manifest.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app_gestion/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../customers/fiado_fixture.dart';

const _mensajeInvalido = 'El respaldo no es válido o está dañado.';

BackupManifest _manifest(int version) => BackupManifest(
  schemaVersion: version,
  appVersion: '1.0.0',
  fechaCreacion: DateTime.utc(2026, 1, 1),
  negocioId: 'n',
  negocioNombre: 'Colmado',
);

/// ZIP con manifest válido (versión actual) y UNA entrada con [nombre].
List<int> _zipConEntrada(String nombre, {int version = 3}) {
  final archive = Archive();
  final manifest = utf8.encode(jsonEncode(_manifest(version).toJson()));
  archive.addFile(ArchiveFile('manifest.json', manifest.length, manifest));
  archive.addFile(ArchiveFile(nombre, 3, [1, 2, 3]));
  return ZipEncoder().encode(archive)!;
}

void main() {
  late Directory tmp;
  late Directory docs;
  late AppDatabase destino;
  late BackupFileService servicio;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('respaldo_test_');
    docs = Directory('${tmp.path}${Platform.pathSeparator}docs')..createSync();
    destino = AppDatabase.forTesting(NativeDatabase.memory());
    servicio = BackupFileService(
      BackupDao(destino),
      directorioDocumentos: () async => docs,
    );
  });

  tearDown(() async {
    await destino.close();
    tmp.deleteSync(recursive: true);
  });

  String escribirZip(List<int> bytes) {
    final ruta = '${tmp.path}/respaldo.zip';
    File(ruta).writeAsBytesSync(bytes);
    return ruta;
  }

  /// Archivos que existen en [tmp] fuera de la carpeta de documentos.
  List<String> archivosFuera() => [
    for (final e in tmp.listSync(recursive: true))
      if (e is File &&
          !e.path.startsWith(docs.path) &&
          !e.path.endsWith('respaldo.zip'))
        e.path,
  ];

  group('S1: respaldos de versiones ANTERIORES', () {
    /// Respaldo real hecho en la versión actual, con datos de negocio, caja y
    /// una venta (con su `venta_pagos`); [quitar] son las tablas que esa
    /// versión antigua todavía no tenía.
    Future<({Map<String, List<Map<String, Object?>>> datos, String ventaId})>
    origen(Set<String> quitar) async {
      final f = await FiadoFixture.crear();
      addTearDown(f.cerrar);
      await f.abrirCaja();
      final ventaId = (await f.vender()).valueOrNull!;
      final datos = await BackupDao(f.db).volcarDatos();
      datos.removeWhere((tabla, _) => quitar.contains(tabla));
      return (datos: datos, ventaId: ventaId);
    }

    List<int> zip(Map<String, List<Map<String, Object?>>> datos, int version) =>
        BackupArchiveBuilder.construir(
          manifest: _manifest(version),
          datos: datos,
          media: const {},
        );

    test('un respaldo v1 (sin venta_pagos ni fiado) se restaura en v3, '
        'conserva sus datos y deja vacías las tablas nuevas', () async {
      final v1 = await origen({
        'venta_pagos',
        'clientes',
        'movimientos_cliente',
      });
      // El destino tiene datos en las tablas nuevas: la restauración es una
      // foto fiel, así que deben desaparecer.
      await destino
          .into(destino.clientes)
          .insert(ClientesCompanion.insert(nombre: 'Cliente que sobra'));

      final paquete = await servicio.validar(
        escribirZip(zip(v1.datos, 1)),
      ); // no lanza
      await servicio.restaurar(paquete, 'respaldo.zip');

      // Datos del respaldo conservados.
      expect(await destino.select(destino.negocios).get(), hasLength(1));
      expect(await destino.select(destino.usuarios).get(), hasLength(1));
      expect(await destino.select(destino.productos).get(), hasLength(1));
      expect(await destino.select(destino.ventas).get(), hasLength(1));
      expect(await destino.select(destino.cajaSesiones).get(), hasLength(1));
      expect(await destino.select(destino.cajaMovimientos).get(), hasLength(1));
      // Tablas que la v1 no tenía: vacías.
      expect(await destino.select(destino.ventaPagos).get(), isEmpty);
      expect(await destino.select(destino.clientes).get(), isEmpty);
      expect(await destino.select(destino.movimientosCliente).get(), isEmpty);
    });

    test('las ventas de un respaldo v1 se leen como EFECTIVO', () async {
      final v1 = await origen({
        'venta_pagos',
        'clientes',
        'movimientos_cliente',
      });
      final paquete = await servicio.validar(escribirZip(zip(v1.datos, 1)));
      await servicio.restaurar(paquete, 'respaldo.zip');

      final ventas = SalesRepositoryImpl(
        SalesLocalDatasource(destino),
        SettingsLocalDatasource(destino),
      );

      final detalle = (await ventas.obtenerVenta(v1.ventaId))!;
      expect(detalle.metodoPago, MetodoPago.efectivo);
      final lista = await ventas.watchVentas().first;
      expect(lista.single.metodoPago, MetodoPago.efectivo);
    });

    test('un respaldo v2 (sin fiado) también se restaura', () async {
      final v2 = await origen({'clientes', 'movimientos_cliente'});

      final paquete = await servicio.validar(escribirZip(zip(v2.datos, 2)));
      await servicio.restaurar(paquete, 'respaldo.zip');

      expect(await destino.select(destino.ventaPagos).get(), hasLength(1));
      expect(await destino.select(destino.clientes).get(), isEmpty);
    });

    test('un respaldo de la versión actual se restaura', () async {
      final actual = await origen({});

      final paquete = await servicio.validar(escribirZip(zip(actual.datos, 3)));
      await servicio.restaurar(paquete, 'respaldo.zip');

      expect(await destino.select(destino.ventaPagos).get(), hasLength(1));
    });

    test(
      'un respaldo de una versión MAYOR se rechaza sin tocar la base',
      () async {
        final futuro = await origen({});
        await destino
            .into(destino.negocios)
            .insert(NegociosCompanion.insert(nombre: 'Original'));

        await expectLater(
          servicio.validar(escribirZip(zip(futuro.datos, 4))),
          throwsA(
            isA<BackupSchemaException>()
                .having((e) => e.versionRespaldo, 'versionRespaldo', 4)
                .having((e) => e.versionActual, 'versionActual', 3),
          ),
        );

        final negocios = await destino.select(destino.negocios).get();
        expect(negocios.single.nombre, 'Original');
      },
    );

    test('una versión inválida (0 o negativa) es un respaldo dañado', () async {
      final datos = await origen({});

      await expectLater(
        servicio.validar(escribirZip(zip(datos.datos, 0))),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });

  group('S2: zip slip', () {
    const evidentes = <String, String>{
      'salida con ../ directo': 'media/../x.txt',
      'salida con ../../': 'media/../../x.txt',
      'oculta tras un directorio': 'media/facturas/../../x.txt',
      'entrada fuera de media': '../x.txt',
      'ruta absoluta POSIX': '/etc/x.txt',
      'ruta absoluta bajo media': 'media//etc/x.txt',
      'ruta de Windows con ..\\': r'media/..\..\x.txt',
      'unidad de Windows': 'media/C:/Windows/x.txt',
      'ruta absoluta de Windows': r'C:\Windows\x.txt',
    };

    for (final e in evidentes.entries) {
      test('${e.key} (${e.value}) rechaza el respaldo completo, sin escribir '
          'archivos ni tocar la base', () async {
        await destino
            .into(destino.negocios)
            .insert(NegociosCompanion.insert(nombre: 'Original'));

        await expectLater(
          () async {
            final paquete = await servicio.validar(
              escribirZip(_zipConEntrada(e.value)),
            );
            await servicio.restaurar(paquete, 'respaldo.zip');
          }(),
          throwsA(
            isA<BackupFormatException>().having(
              (x) => x.mensaje,
              'mensaje',
              _mensajeInvalido,
            ),
          ),
        );

        expect(archivosFuera(), isEmpty);
        expect(docs.listSync(), isEmpty);
        final negocios = await destino.select(destino.negocios).get();
        expect(negocios.single.nombre, 'Original');
      });
    }

    test('restaurar TAMBIÉN se defiende si el paquete llega ya armado (no '
        'confía solo en validar)', () async {
      await destino
          .into(destino.negocios)
          .insert(NegociosCompanion.insert(nombre: 'Original'));
      final paquete = BackupArchive(
        manifest: _manifest(3),
        datos: const {},
        media: {
          'facturas/buena.jpg': [1, 2, 3],
          '../mala.txt': [9],
        },
      );

      await expectLater(
        servicio.restaurar(paquete, 'respaldo.zip'),
        throwsA(isA<BackupFormatException>()),
      );

      // Ni la foto buena se escribió: se valida TODO antes de escribir.
      expect(docs.listSync(recursive: true), isEmpty);
      expect(archivosFuera(), isEmpty);
      final negocios = await destino.select(destino.negocios).get();
      expect(negocios.single.nombre, 'Original');
    });

    test('un respaldo normal sigue restaurando sus fotos', () async {
      final f = await FiadoFixture.crear();
      addTearDown(f.cerrar);
      final datos = await BackupDao(f.db).volcarDatos();
      final bytes = BackupArchiveBuilder.construir(
        manifest: _manifest(3),
        datos: datos,
        media: {
          'facturas/a.jpg': [1, 2, 3],
          'logo.png': [4, 5],
        },
      );

      final paquete = await servicio.validar(escribirZip(bytes));
      await servicio.restaurar(paquete, 'respaldo.zip');

      expect(File('${docs.path}/facturas/a.jpg').readAsBytesSync(), [1, 2, 3]);
      expect(File('${docs.path}/logo.png').readAsBytesSync(), [4, 5]);
      expect(archivosFuera(), isEmpty);
    });
  });

  group('columnas del respaldo', () {
    test('un nombre de columna manipulado (inyección SQL) se rechaza antes de '
        'tocar la base', () async {
      await destino
          .into(destino.negocios)
          .insert(NegociosCompanion.insert(nombre: 'Original'));
      final paquete = BackupArchive(
        manifest: _manifest(3),
        datos: {
          'negocios': [
            {'id': 'x', 'nombre) VALUES (1); DROP TABLE usuarios; --': 'y'},
          ],
        },
        media: const {},
      );

      await expectLater(
        servicio.restaurar(paquete, 'respaldo.zip'),
        throwsA(isA<BackupFormatException>()),
      );

      final negocios = await destino.select(destino.negocios).get();
      expect(negocios.single.nombre, 'Original');
    });
  });
}
