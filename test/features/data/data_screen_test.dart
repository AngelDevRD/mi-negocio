import 'dart:async';

import 'package:app_gestion/core/database/app_database.dart'
    show Negocio, Respaldo;
import 'package:app_gestion/core/database/enums.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/backup/data/datasources/backup_dao.dart';
import 'package:app_gestion/features/backup/data/services/backup_archive_builder.dart';
import 'package:app_gestion/features/backup/data/services/backup_file_service.dart';
import 'package:app_gestion/features/backup/domain/entities/backup_manifest.dart';
import 'package:app_gestion/features/backup/presentation/providers/backup_providers.dart';
import 'package:app_gestion/features/data/presentation/screens/data_screen.dart';
import 'package:app_gestion/features/exports/data/services/export_file_service.dart';
import 'package:app_gestion/features/exports/domain/entities/export_models.dart';
import 'package:app_gestion/features/exports/presentation/providers/export_providers.dart';
import 'package:app_gestion/features/import/data/datasources/ai_mapping_remote_datasource.dart';
import 'package:app_gestion/features/import/data/services/excel_import_reader.dart';
import 'package:app_gestion/features/import/domain/entities/import_target.dart';
import 'package:app_gestion/features/import/domain/repositories/import_repository.dart';
import 'package:app_gestion/features/import/presentation/providers/import_providers.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_plus/share_plus.dart';

class _LicenciaFija extends LicenseController {
  _LicenciaFija(this.tipo);

  final TipoLicencia tipo;

  @override
  Future<LicenseCheck> build() async => LicenciaActiva(
    Licencia(
      tipo: tipo,
      estado: EstadoLicencia.activa,
      deviceId: 'dispositivo',
      fechaActivacion: DateTime(2026),
      ultimaValidacion: DateTime(2026),
    ),
  );
}

class _AuthFalso extends AuthController {
  int cierresDeSesion = 0;

  @override
  Future<EstadoSesion> build() async => const SesionActiva(
    Usuario(
      id: 'u1',
      negocioId: 'n1',
      nombre: 'Ana Admin',
      username: 'ana',
      rol: RolUsuario.administrador,
      activo: true,
    ),
  );

  @override
  Future<void> logout() async {
    cierresDeSesion++;
  }
}

/// Respaldo en memoria (sin disco, sin selector de archivos).
class _ServicioRespaldoFalso implements BackupFileService {
  Completer<void>? bloqueo;
  Object? errorAlExportar;
  Object? errorAlValidar;
  String? rutaElegida = 'C:/tmp/respaldo.zip';

  int exportados = 0;
  int restaurados = 0;

  final paquete = BackupArchive(
    manifest: BackupManifest(
      schemaVersion: 3,
      appVersion: '1.0.0',
      fechaCreacion: DateTime(2026, 9, 1, 10, 30).toUtc(),
      negocioId: 'n1',
      negocioNombre: 'Colmado Doña Carmen',
    ),
    datos: const {},
    media: const {},
  );

  @override
  Future<XFile> exportar() async {
    exportados++;
    await bloqueo?.future;
    if (errorAlExportar != null) throw errorAlExportar!;
    return XFile('C:/tmp/respaldo_1.zip', name: 'respaldo_1.zip');
  }

  @override
  Future<void> compartir(XFile archivo) async {}

  @override
  Future<String?> elegirArchivoRespaldo() async => rutaElegida;

  @override
  Future<BackupArchive> validar(String rutaZip) async {
    if (errorAlValidar != null) throw errorAlValidar!;
    return paquete;
  }

  @override
  Future<void> restaurar(BackupArchive paquete, String nombreArchivo) async {
    restaurados++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DaoFalso implements BackupDao {
  @override
  Future<Negocio?> obtenerNegocio() async => Negocio(
    id: 'n1',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    nombre: 'Colmado Doña Carmen',
    moneda: 'DOP',
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExportFalso implements ExportFileService {
  Completer<void>? bloqueo;
  Object? errorAlGenerar;
  Object? errorAlCompartir;

  int generados = 0;
  int compartidos = 0;
  FormatoExport? ultimoFormato;
  DateTime? ultimoDesde;
  DateTime? ultimoHasta;

  Future<XFile> _generar(String nombre) async {
    generados++;
    await bloqueo?.future;
    if (errorAlGenerar != null) throw errorAlGenerar!;
    return XFile('C:/tmp/$nombre', name: nombre);
  }

  @override
  Future<XFile> generarVentas({
    required DateTime desde,
    required DateTime hasta,
    required FormatoExport formato,
  }) {
    ultimoDesde = desde;
    ultimoHasta = hasta;
    ultimoFormato = formato;
    return _generar('ventas.xlsx');
  }

  @override
  Future<void> compartir(XFile archivo, {String? subject}) async {
    compartidos++;
    if (errorAlCompartir != null) throw errorAlCompartir!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ImportFalso implements ImportRepository {
  Completer<void>? bloqueo;
  ImportResultado resultado = const ImportResultado(
    insertados: 1,
    errores: ['Fila 3: falta el nombre del producto.'],
  );
  int importados = 0;

  @override
  Result<List<HojaImportada>> leerExcel(List<int> bytes) => const Result.ok([
    HojaImportada(
      nombre: 'Hoja1',
      encabezados: ['Nombre', 'Precio'],
      filas: [
        ['Arroz selecto', '35'],
        ['Habichuelas', '60'],
      ],
    ),
  ]);

  @override
  Map<String, Object?> transformarFila(
    List<String> fila,
    List<String> encabezados,
    Map<String, ColumnMapping> mapeo,
  ) => {'nombre': fila[0]};

  @override
  Future<Result<AiMappingResponse>> sugerirMapeo({
    required ImportTargetType targetType,
    required List<String> headers,
    required List<List<String>> sampleRows,
  }) async => const Result.ok(AiMappingResponse(ok: true));

  @override
  Future<Result<ImportResultado>> importar({
    required ImportTargetType targetType,
    required List<String> encabezados,
    required List<List<String>> filas,
    required Map<String, ColumnMapping> mapeo,
    required String usuarioId,
  }) async {
    importados++;
    await bloqueo?.future;
    return Result.ok(resultado);
  }
}

Respaldo _respaldo(String archivo, DateTime fecha, {String resultado = 'ok'}) =>
    Respaldo(
      id: archivo,
      createdAt: fecha,
      updatedAt: fecha,
      fecha: fecha.toUtc(),
      archivo: archivo,
      tamanoBytes: 2 * 1024 * 1024,
      tipo: TipoRespaldo.manual,
      resultado: resultado,
    );

class _Entorno {
  _Entorno({
    this.licencia = TipoLicencia.local,
    Stream<List<Respaldo>>? historial,
  }) : historial = historial ?? Stream.value(const []);

  final TipoLicencia licencia;
  final Stream<List<Respaldo>> historial;
  final List<SesionCajaResumen> sesionesCaja = const [];

  final respaldo = _ServicioRespaldoFalso();
  final exportador = _ExportFalso();
  final importador = _ImportFalso();
  final auth = _AuthFalso();

  late ProviderContainer contenedor;
}

Future<_Entorno> _montar(
  WidgetTester tester, {
  _Entorno? entorno,
  bool asentar = true,
}) async {
  final e = entorno ?? _Entorno();
  tester.view.physicalSize = const Size(420, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/datos',
    routes: [
      GoRoute(path: '/datos', builder: (_, _) => const DataScreen()),
      GoRoute(
        path: '/splash',
        builder: (_, _) => const Scaffold(body: Text('splash')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        licenseControllerProvider.overrideWith(() => _LicenciaFija(e.licencia)),
        authControllerProvider.overrideWith(() => e.auth),
        backupFileServiceProvider.overrideWithValue(e.respaldo),
        backupDaoProvider.overrideWithValue(_DaoFalso()),
        historialRespaldosProvider.overrideWith((ref) => e.historial),
        exportFileServiceProvider.overrideWithValue(e.exportador),
        sesionesCajaCerradasProvider.overrideWith(
          (ref) async => e.sesionesCaja,
        ),
        importRepositoryProvider.overrideWithValue(e.importador),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  e.contenedor = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await e.contenedor.read(licenseControllerProvider.future);
  await e.contenedor.read(authControllerProvider.future);
  asentar ? await tester.pumpAndSettle() : await tester.pump();
  return e;
}

/// El BOTÓN con [texto] (hay títulos de sección con el mismo texto).
Finder _boton(String texto) => find
    .ancestor(
      of: find.text(texto),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    )
    .first;

Future<void> _tocarBoton(WidgetTester tester, String texto) async {
  await tester.ensureVisible(_boton(texto));
  await tester.tap(_boton(texto));
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  group('pantalla única', () {
    testWidgets('muestra las tres secciones: Respaldo, Exportar e Importar', (
      tester,
    ) async {
      await _montar(tester);

      expect(find.text('Datos'), findsOneWidget); // barra superior
      expect(find.text('Respaldo'), findsOneWidget);
      expect(find.text('Exportar'), findsOneWidget);
      expect(find.text('Importar'), findsOneWidget);
    });

    testWidgets('plan Demo: bloqueada con explicación (sin secciones)', (
      tester,
    ) async {
      await _montar(tester, entorno: _Entorno(licencia: TipoLicencia.demo));

      expect(
        find.text('Datos no está disponible en el plan Demo'),
        findsOneWidget,
      );
      expect(find.text('Crear respaldo'), findsNothing);
    });
  });

  group('Respaldo', () {
    testWidgets('sin respaldos: avisa que aún no hay ninguno', (tester) async {
      await _montar(tester);

      expect(find.text('Aún no has creado ningún respaldo'), findsOneWidget);
      expect(find.text('Todavía no hay respaldos'), findsOneWidget);
    });

    testWidgets('con respaldos: fecha del último (local) y tamaño', (
      tester,
    ) async {
      await _montar(
        tester,
        entorno: _Entorno(
          historial: Stream.value([
            _respaldo('respaldo_2.zip', DateTime(2026, 9, 15, 9, 5)),
            _respaldo('respaldo_1.zip', DateTime(2026, 9, 1, 8, 0)),
          ]),
        ),
      );

      expect(
        find.text('Último respaldo: 15/09/2026 09:05 · 2.0 MB'),
        findsOneWidget,
      );
      expect(find.text('respaldo_1.zip'), findsOneWidget);
      expect(find.text('respaldo_2.zip'), findsOneWidget);
    });

    testWidgets('un respaldo fallido sale marcado con texto', (tester) async {
      await _montar(
        tester,
        entorno: _Entorno(
          historial: Stream.value([
            _respaldo('malo.zip', DateTime(2026, 9, 15, 9, 5), resultado: 'x'),
          ]),
        ),
      );

      expect(find.textContaining('Falló'), findsOneWidget);
      // Sin ninguno correcto, el "último respaldo" avisa.
      expect(find.text('Aún no has creado ningún respaldo'), findsOneWidget);
    });

    testWidgets('historial con error: mensaje humano y "Reintentar"', (
      tester,
    ) async {
      await _montar(
        tester,
        entorno: _Entorno(historial: Stream.error(StateError('boom'))),
      );

      expect(
        find.text('No se pudo cargar el historial de respaldos.'),
        findsOneWidget,
      );
      expect(find.textContaining('boom'), findsNothing);
      expect(find.text('Reintentar'), findsWidgets);
    });

    testWidgets('crear: doble toque = UN respaldo; avisa con el archivo', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.respaldo.bloqueo = Completer<void>();

      await _tocarBoton(tester, 'Crear respaldo');
      await tester.pump();
      // Ya está en curso: los botones se deshabilitan y hay progreso.
      expect(find.text('Creando el respaldo...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final crear = find.widgetWithIcon(FilledButton, Icons.backup_outlined);
      expect(tester.widget<FilledButton>(crear).onPressed, isNull);
      await tester.tap(crear, warnIfMissed: false);
      await tester.pump();
      expect(e.respaldo.exportados, 1);

      e.respaldo.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(e.respaldo.exportados, 1);
      expect(find.text('Respaldo creado: respaldo_1.zip'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('crear con fallo: snackbar sin el error técnico', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.respaldo.errorAlExportar = StateError('disco lleno');

      await _tocarBoton(tester, 'Crear respaldo');
      await tester.pumpAndSettle();

      expect(find.text('No se pudo crear el respaldo.'), findsOneWidget);
      expect(find.textContaining('disco lleno'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('restaurar: pide confirmación DESTRUCTIVA que explica que '
        'reemplaza los datos; cancelar no restaura', (tester) async {
      final e = await _montar(tester);

      await _tocarBoton(tester, 'Restaurar desde archivo');
      await tester.pumpAndSettle();

      expect(find.text('¿Restaurar este respaldo?'), findsOneWidget);
      expect(find.textContaining('REEMPLAZA todos los datos'), findsOneWidget);
      expect(find.textContaining('No se puede deshacer'), findsOneWidget);
      expect(find.textContaining('Colmado Doña Carmen'), findsWidgets);
      final continuar = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continuar'),
      );
      final scheme = Theme.of(
        tester.element(find.byType(AlertDialog)),
      ).colorScheme;
      expect(continuar.style?.backgroundColor?.resolve({}), scheme.error);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(e.respaldo.restaurados, 0);
      expect(find.text('Confirma con el nombre del negocio'), findsNothing);
      // Los botones vuelven a estar disponibles.
      expect(find.text('Leyendo el respaldo...'), findsNothing);
    });

    testWidgets('restaurar: tras continuar hay que escribir el nombre del '
        'negocio; solo entonces restaura y cierra la sesión', (tester) async {
      final e = await _montar(tester);

      await _tocarBoton(tester, 'Restaurar desde archivo');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirma con el nombre del negocio'), findsOneWidget);
      FilledButton restaurar() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Restaurar'),
      );
      expect(restaurar().onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'otro negocio');
      await tester.pump();
      expect(restaurar().onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Colmado Doña Carmen');
      await tester.pump();
      expect(restaurar().onPressed, isNotNull);
      await tester.tap(find.widgetWithText(FilledButton, 'Restaurar'));
      await tester.pumpAndSettle();

      expect(e.respaldo.restaurados, 1);
      expect(find.text('Respaldo restaurado'), findsOneWidget);
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();

      expect(e.auth.cierresDeSesion, 1);
      expect(find.text('splash'), findsOneWidget);
    });

    testWidgets('un respaldo inválido: snackbar con el mensaje y nada se '
        'restaura', (tester) async {
      final e = await _montar(tester);
      e.respaldo.errorAlValidar = const BackupFormatException.invalido();

      await _tocarBoton(tester, 'Restaurar desde archivo');
      await tester.pumpAndSettle();

      expect(
        find.text('El respaldo no es válido o está dañado.'),
        findsOneWidget,
      );
      expect(find.text('¿Restaurar este respaldo?'), findsNothing);
      expect(e.respaldo.restaurados, 0);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('cancelar el selector de archivo no hace nada', (tester) async {
      final e = await _montar(tester);
      e.respaldo.rutaElegida = null;

      await _tocarBoton(tester, 'Restaurar desde archivo');
      await tester.pumpAndSettle();

      expect(find.text('¿Restaurar este respaldo?'), findsNothing);
      expect(e.respaldo.restaurados, 0);
    });
  });

  group('Exportar', () {
    testWidgets('por defecto: Ventas, Excel y período "Este mes"', (
      tester,
    ) async {
      await _montar(tester);

      expect(find.text('Ventas por rango'), findsOneWidget);
      expect(find.text('Este mes'), findsOneWidget); // FiltroFechaChip
      expect(find.byTooltip('Filtrar por fecha'), findsOneWidget);
      expect(find.text('Excel'), findsOneWidget);
    });

    testWidgets('genera, comparte y avisa; deja el archivo con su ruta', (
      tester,
    ) async {
      final e = await _montar(tester);

      await _tocarBoton(tester, 'Generar y compartir');
      await tester.pumpAndSettle();

      expect(e.exportador.generados, 1);
      expect(e.exportador.compartidos, 1);
      expect(e.exportador.ultimoFormato, FormatoExport.excel);
      expect(find.text('Reporte listo: ventas.xlsx'), findsOneWidget);
      expect(find.text('Último archivo'), findsOneWidget);
      expect(find.text('C:/tmp/ventas.xlsx'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));

      await tester.tap(find.byTooltip('Compartir de nuevo'));
      await tester.pumpAndSettle();
      expect(e.exportador.compartidos, 2);
      expect(e.exportador.generados, 1);
    });

    testWidgets('doble toque = UN solo reporte (botón "Generando...")', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.exportador.bloqueo = Completer<void>();

      await _tocarBoton(tester, 'Generar y compartir');
      await tester.pump();
      expect(find.text('Generando...'), findsOneWidget);
      expect(
        tester.widget<ButtonStyleButton>(_boton('Generando...')).onPressed,
        isNull,
      );
      await tester.tap(find.text('Generando...'), warnIfMissed: false);
      await tester.pump();
      expect(e.exportador.generados, 1);

      e.exportador.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(e.exportador.generados, 1);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('el período elegido llega al reporte ("Hoy")', (tester) async {
      final e = await _montar(tester);

      await tester.tap(find.text('Este mes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hoy').last);
      await tester.pumpAndSettle();
      expect(find.text('Hoy'), findsOneWidget);

      await _tocarBoton(tester, 'Generar y compartir');
      await tester.pumpAndSettle();

      final desde = e.exportador.ultimoDesde!.toLocal();
      final hoy = DateTime.now();
      expect(
        (desde.year, desde.month, desde.day),
        (hoy.year, hoy.month, hoy.day),
      );
      expect((desde.hour, desde.minute), (0, 0));
      expect(
        e.exportador.ultimoHasta!.isAfter(e.exportador.ultimoDesde!),
        isTrue,
      );
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('falla al generar: snackbar humano, sin archivo recordado', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.exportador.errorAlGenerar = StateError('sin memoria');

      await _tocarBoton(tester, 'Generar y compartir');
      await tester.pumpAndSettle();

      expect(find.text('No se pudo generar el reporte.'), findsOneWidget);
      expect(find.textContaining('sin memoria'), findsNothing);
      expect(find.text('Último archivo'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('falla al compartir: dice dónde quedó el archivo', (
      tester,
    ) async {
      final e = await _montar(tester);
      e.exportador.errorAlCompartir = StateError('sin app');

      await _tocarBoton(tester, 'Generar y compartir');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('se generó, pero no se pudo compartir'),
        findsOneWidget,
      );
      expect(find.textContaining('C:/tmp/ventas.xlsx'), findsWidgets);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('cierre de caja sin cajas cerradas: estado vacío y aviso', (
      tester,
    ) async {
      await _montar(tester);

      await tester.tap(find.byType(DropdownButtonFormField<TipoReporte>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cierre de caja').last);
      await tester.pumpAndSettle();

      expect(find.text('Aún no hay cajas cerradas'), findsOneWidget);
      // No usa período de fechas.
      expect(find.byTooltip('Filtrar por fecha'), findsNothing);

      await _tocarBoton(tester, 'Generar y compartir');
      await tester.pumpAndSettle();
      expect(find.text('Selecciona una sesión de caja.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('Importar', () {
    testWidgets('sin archivo: muestra las columnas que reconoce la app '
        '(plantilla) y NO ofrece importar', (tester) async {
      await _montar(tester);

      expect(find.text('Tipo de datos'), findsOneWidget);
      expect(find.text('Nombre del producto *'), findsOneWidget);
      expect(find.text('Elegir archivo Excel'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Importar'), findsNothing);
    });

    testWidgets('cambiar el tipo cambia las columnas reconocidas', (
      tester,
    ) async {
      await _montar(tester);
      final gastos = camposImportacion[ImportTargetType.gastos]!;
      final requerido = gastos.firstWhere((c) => c.requerido).etiqueta;

      await tester.ensureVisible(find.text('Tipo de datos'));
      await tester.tap(find.text('Productos').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gastos').last);
      await tester.pumpAndSettle();

      expect(find.text('Nombre del producto *'), findsNothing);
      expect(find.text('$requerido *'), findsOneWidget);
    });

    Future<_Entorno> conArchivo(WidgetTester tester) async {
      final e = await _montar(tester);
      e.contenedor.read(importControllerProvider.notifier).cargarArchivo([1]);
      await tester.pumpAndSettle();
      return e;
    }

    testWidgets('con archivo: vista previa y botón Importar', (tester) async {
      await conArchivo(tester);

      expect(find.text('4. Vista previa'), findsOneWidget);
      expect(find.text('Arroz selecto'), findsOneWidget);
      expect(find.text('Habichuelas'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Importar'), findsOneWidget);
    });

    testWidgets('importar pide confirmación con el número de filas; cancelar '
        'no importa', (tester) async {
      final e = await conArchivo(tester);

      await _tocarBoton(tester, 'Importar');
      await tester.pumpAndSettle();
      // El título de la sección y el botón también dicen "Importar".
      expect(find.text('¿Importar 2 filas?'), findsOneWidget);
      expect(find.textContaining('no reemplaza nada'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(e.importador.importados, 0);
    });

    testWidgets('confirmar: guard contra doble toque, resultado y errores '
        'fila por fila legibles', (tester) async {
      final e = await conArchivo(tester);
      e.importador.bloqueo = Completer<void>();

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Importar'));
      await tester.tap(find.widgetWithText(FilledButton, 'Importar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Importar').last);
      await tester.pump();
      await tester.pump();

      expect(e.importador.importados, 1);
      expect(find.text('Importando...'), findsOneWidget);
      final enCurso = find.widgetWithIcon(
        FilledButton,
        Icons.save_alt_outlined,
      );
      expect(enCurso, findsNothing); // el ícono cambió por el progreso
      expect(
        tester
            .widget<FilledButton>(
              find.ancestor(
                of: find.text('Importando...'),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );

      e.importador.bloqueo!.complete();
      await tester.pumpAndSettle();

      expect(e.importador.importados, 1);
      expect(find.text('1 fila importada'), findsOneWidget);
      expect(find.text('1 fila no se importó'), findsOneWidget);
      expect(
        find.text('• Fila 3: falta el nombre del producto.'),
        findsOneWidget,
      );
      expect(find.text('1 fila importada (1 con errores).'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('muchos errores: lista los primeros y resume el resto', (
      tester,
    ) async {
      final e = await conArchivo(tester);
      e.importador.resultado = ImportResultado(
        insertados: 0,
        errores: [for (var i = 0; i < 25; i++) 'Fila ${i + 2}: dato inválido.'],
      );

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Importar'));
      await tester.tap(find.widgetWithText(FilledButton, 'Importar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Importar').last);
      await tester.pumpAndSettle();

      expect(find.text('25 filas no se importaron'), findsOneWidget);
      expect(find.text('• Fila 2: dato inválido.'), findsOneWidget);
      expect(find.text('y 5 más.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });
  });
}
