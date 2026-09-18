import 'dart:async';
import 'dart:io';

import 'package:app_gestion/core/database/app_database.dart' hide Usuario;
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/router/app_router.dart';
import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/auth/domain/entities/usuario.dart';
import 'package:app_gestion/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_gestion/features/cash_register/data/datasources/cash_register_local_datasource.dart';
import 'package:app_gestion/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:app_gestion/features/expenses/data/datasources/expenses_local_datasource.dart';
import 'package:app_gestion/features/expenses/data/repositories/expenses_repository_impl.dart';
import 'package:app_gestion/features/license/domain/entities/licencia.dart';
import 'package:app_gestion/features/license/presentation/providers/license_providers.dart';
import 'package:app_gestion/features/products/data/datasources/products_local_datasource.dart';
import 'package:app_gestion/features/products/data/repositories/products_repository_impl.dart';
import 'package:app_gestion/features/purchases/data/datasources/purchases_local_datasource.dart';
import 'package:app_gestion/features/purchases/data/repositories/purchases_repository_impl.dart';
import 'package:app_gestion/features/purchases/domain/entities/compra.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:app_gestion/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Tamaños de pantalla
// ---------------------------------------------------------------------------

/// Tamaño lógico de la pantalla simulada (devicePixelRatio fijo en 2).
enum TamanoPantalla {
  telefono('telefono', 390, 844),
  tablet('tablet', 800, 1280),
  escritorio('escritorio', 1280, 800);

  const TamanoPantalla(this.carpeta, this.ancho, this.alto);

  /// Subcarpeta de build/visual/ donde se guardan las capturas.
  final String carpeta;
  final double ancho;
  final double alto;
}

// ---------------------------------------------------------------------------
// Fuentes reales
// ---------------------------------------------------------------------------

/// Raíz del SDK de Flutter: `FLUTTER_ROOT` si está definida; si no, se
/// infiere subiendo desde el ejecutable actual hasta encontrar la carpeta de
/// fuentes de Material.
String _raizFlutter() {
  final entorno = Platform.environment['FLUTTER_ROOT'];
  if (entorno != null && entorno.isNotEmpty) return entorno;

  var dir = File(Platform.resolvedExecutable).parent;
  while (true) {
    if (Directory(_carpetaFuentes(dir.path)).existsSync()) return dir.path;
    final padre = dir.parent;
    if (padre.path == dir.path) {
      throw StateError(
        'No se encontró el SDK de Flutter (FLUTTER_ROOT no está definida y '
        'no se pudo inferir desde ${Platform.resolvedExecutable}).',
      );
    }
    dir = padre;
  }
}

String _carpetaFuentes(String raiz) =>
    '$raiz${Platform.pathSeparator}bin${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}'
    'material_fonts';

Future<ByteData> _leerFuente(String carpeta, String archivo) async {
  final bytes = await File(
    '$carpeta${Platform.pathSeparator}$archivo',
  ).readAsBytes();
  return ByteData.sublistView(bytes);
}

/// Carga Roboto (regular, medium, bold) y MaterialIcons desde el SDK. Sin
/// esto flutter_test dibuja cuadros en vez de texto e íconos. Llamar una vez
/// en `setUpAll`.
Future<void> cargarFuentesReales() async {
  final carpeta = _carpetaFuentes(_raizFlutter());

  final roboto = FontLoader('Roboto')
    ..addFont(_leerFuente(carpeta, 'roboto-regular.ttf'))
    ..addFont(_leerFuente(carpeta, 'roboto-medium.ttf'))
    ..addFont(_leerFuente(carpeta, 'roboto-bold.ttf'));
  await roboto.load();

  final iconos = FontLoader('MaterialIcons')
    ..addFont(_leerFuente(carpeta, 'materialicons-regular.otf'));
  await iconos.load();
}

// ---------------------------------------------------------------------------
// Base de datos demo
// ---------------------------------------------------------------------------

/// Base en memoria con los usuarios ya creados (para montar la app con sesión
/// activa de cualquiera de los dos roles).
class BaseDemo {
  BaseDemo({required this.db, required this.admin, required this.cajero});

  final AppDatabase db;
  final Usuario admin;
  final Usuario cajero;

  Usuario usuarioDe(RolUsuario rol) =>
      rol == RolUsuario.administrador ? admin : cajero;
}

/// Crea la base en memoria de un colmado dominicano.
///
/// El negocio y los dos usuarios se insertan directo (hashear contraseñas
/// con PBKDF2 tarda segundos y aquí la sesión se inyecta, no se inicia). Todo
/// lo demás (categorías, productos, caja, ventas, compras, gastos) se siembra
/// con los repositorios reales, así stock, caja y auditoría quedan coherentes.
///
/// Con [vacia] = true solo se crean negocio y usuarios (para revisar los
/// estados vacíos). Con [cajaCerrada] = true se siembra todo y al final se
/// cierra la caja (las ventas exigen caja abierta).
Future<BaseDemo> crearBaseDemo({
  bool vacia = false,
  bool cajaCerrada = false,
}) async {
  // Cada escenario crea su propia base (la anterior ya se cerró): el aviso de
  // drift por "varias bases" es ruido aquí.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  final negocioId = generateUuidV4();
  await db
      .into(db.negocios)
      .insert(
        NegociosCompanion.insert(
          id: Value(negocioId),
          nombre: 'Colmado Doña Carmen',
          identificacion: const Value('131-45678-9'),
          direccion: const Value('Calle Duarte #45, Santiago'),
          telefono: const Value('809-555-0142'),
        ),
      );

  Usuario crearUsuarioFila(String nombre, String username, RolUsuario rol) {
    return Usuario(
      id: generateUuidV4(),
      negocioId: negocioId,
      nombre: nombre,
      username: username,
      rol: rol,
      activo: true,
    );
  }

  final admin = crearUsuarioFila(
    'Carmen Rodríguez',
    'carmen',
    RolUsuario.administrador,
  );
  final cajero = crearUsuarioFila('Luis Peña', 'luis', RolUsuario.cajero);
  for (final u in [admin, cajero]) {
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(u.id),
            negocioId: negocioId,
            nombre: u.nombre,
            username: u.username,
            passwordHash: 'hash-demo',
            salt: 'salt-demo',
            rol: u.rol,
          ),
        );
  }

  if (!vacia) await _sembrarMovimientos(db, admin.id);
  if (cajaCerrada && !vacia) {
    final caja = CashRegisterRepositoryImpl(CashRegisterLocalDatasource(db));
    await caja.cerrarCaja(
      montoContado: const Money(861400),
      montoDejarSiguiente: const Money(500000),
      usuarioId: admin.id,
    );
  }

  return BaseDemo(db: db, admin: admin, cajero: cajero);
}

Future<void> _sembrarMovimientos(AppDatabase db, String usuarioId) async {
  final productos = ProductsRepositoryImpl(ProductsLocalDatasource(db));
  final compras = PurchasesRepositoryImpl(PurchasesLocalDatasource(db));
  final ventas = SalesRepositoryImpl(
    SalesLocalDatasource(db),
    SettingsLocalDatasource(db),
  );
  final gastos = ExpensesRepositoryImpl(ExpensesLocalDatasource(db));

  Future<String> categoria(String nombre) async =>
      (await productos.crearCategoria(nombre)).valueOrNull!.id;

  final granos = await categoria('Granos');
  final embutidos = await categoria('Embutidos');
  final bebidas = await categoria('Bebidas');
  final aceites = await categoria('Aceites');
  final limpieza = await categoria('Limpieza');
  final basicos = await categoria('Básicos');

  Future<({String id, String nombre, Money precio})> producto(
    String nombre,
    String categoriaId,
    String unidad,
    double compra,
    double venta,
    double stock,
    double minimo,
  ) async {
    final creado = (await productos.crearProducto(
      nombre: nombre,
      categoriaId: categoriaId,
      unidad: unidad,
      precioCompra: Money.fromPesos(compra),
      precioVenta: Money.fromPesos(venta),
      stockInicial: stock,
      stockMinimo: minimo,
      usuarioId: usuarioId,
    )).valueOrNull!;
    return (id: creado.id, nombre: nombre, precio: Money.fromPesos(venta));
  }

  final arroz = await producto(
    'Arroz selecto',
    granos,
    'libra',
    28,
    35,
    120,
    20,
  );
  final habichuelas = await producto(
    'Habichuelas rojas',
    granos,
    'libra',
    45,
    60,
    60,
    15,
  );
  final salami = await producto(
    'Salami Induveca',
    embutidos,
    'libra',
    160,
    210,
    12,
    5,
  );
  final aceite = await producto(
    'Aceite vegetal 1 L',
    aceites,
    'unidad',
    130,
    165,
    24,
    6,
  );
  final refresco = await producto(
    'Refresco 2 L',
    bebidas,
    'unidad',
    75,
    100,
    36,
    12,
  );
  final agua = await producto(
    'Agua 500 ml',
    bebidas,
    'unidad',
    12,
    20,
    96,
    24,
  );
  final cerveza = await producto(
    'Cerveza Presidente grande',
    bebidas,
    'unidad',
    110,
    150,
    48,
    12,
  );
  final huevos = await producto('Huevos', basicos, 'unidad', 6, 9, 180, 30);
  final pan = await producto('Pan de agua', basicos, 'unidad', 5, 8, 40, 10);
  await producto('Jabón de cuaba', limpieza, 'unidad', 12, 20, 30, 10);
  // Con stock bajo (stock <= mínimo): aparecen en "Inventario bajo".
  await producto('Café molido 1 lb', granos, 'unidad', 95, 125, 3, 8);
  await producto('Detergente en polvo 1 kg', limpieza, 'unidad', 60, 85, 2, 6);

  // Caja abierta con fondo inicial.
  await ventas.abrirCaja(
    montoApertura: const Money(500000),
    usuarioId: usuarioId,
  );

  ItemVentaInput item(
    ({String id, String nombre, Money precio}) p,
    double cantidad,
  ) => ItemVentaInput(
    productoId: p.id,
    productoNombre: p.nombre,
    cantidad: cantidad,
    precioUnitario: p.precio,
  );

  Future<String> vender(
    List<ItemVentaInput> items, {
    TipoVenta tipo = TipoVenta.rapida,
    String? nota,
  }) async => (await ventas.registrarVenta(
    tipo: tipo,
    items: items,
    nota: nota,
    usuarioId: usuarioId,
  )).valueOrNull!;

  // Ventas de hoy.
  await vender([item(arroz, 5), item(habichuelas, 3)]);
  await vender([item(refresco, 2), item(pan, 4)]);
  await vender([item(salami, 1.5), item(huevos, 12)], tipo: TipoVenta.detallada);
  await vender([item(cerveza, 6)], nota: 'Pedido para fiesta');

  // Ventas de días anteriores: el repositorio siempre guarda "ahora", así que
  // se retrocede la fecha después de registrarlas.
  final ahora = DateTime.now();
  Future<void> venderHaceDias(int dias, List<ItemVentaInput> items) async {
    final id = await vender(items);
    await (db.update(db.ventas)..where((t) => t.id.equals(id))).write(
      VentasCompanion(fecha: Value(ahora.subtract(Duration(days: dias)).toUtc())),
    );
  }

  await venderHaceDias(1, [item(aceite, 2), item(arroz, 10)]);
  await venderHaceDias(2, [item(agua, 12), item(refresco, 3)]);
  await venderHaceDias(4, [item(salami, 2), item(pan, 8)]);

  // Compras de reposición.
  final proveedor = (await compras.crearProveedor(
    nombre: 'Distribuidora Caribe',
    telefono: '809-555-0190',
  )).valueOrNull!;
  await compras.registrarCompra(
    proveedorId: proveedor.id,
    numeroFactura: 'F-1042',
    items: [
      ItemCompraInput(
        productoId: arroz.id,
        productoNombre: arroz.nombre,
        cantidad: 50,
        costoUnitario: Money.fromPesos(28),
      ),
      ItemCompraInput(
        productoId: aceite.id,
        productoNombre: aceite.nombre,
        cantidad: 12,
        costoUnitario: Money.fromPesos(130),
      ),
    ],
    pagadaDeCaja: false,
    usuarioId: usuarioId,
  );
  await compras.registrarCompra(
    proveedorId: proveedor.id,
    items: [
      ItemCompraInput(
        productoId: refresco.id,
        productoNombre: refresco.nombre,
        cantidad: 24,
        costoUnitario: Money.fromPesos(75),
      ),
    ],
    pagadaDeCaja: false,
    usuarioId: usuarioId,
  );

  // Gastos del mes.
  Future<void> gasto(String categoria, String concepto, double monto) async {
    await gastos.registrarGasto(
      categoria: categoria,
      concepto: concepto,
      fecha: DateTime.now().toUtc(),
      monto: Money.fromPesos(monto),
      saleDeCaja: false,
      usuarioId: usuarioId,
    );
  }

  await gasto('Servicios', 'Factura de luz', 3850);
  await gasto('Transporte', 'Flete de mercancía', 950);
  await gasto('Mantenimiento', 'Reparación de nevera', 1800);
}

// ---------------------------------------------------------------------------
// Montaje de la app real
// ---------------------------------------------------------------------------

class _LicenciaActiva extends LicenseController {
  @override
  Future<LicenseCheck> build() async => LicenciaActiva(
    Licencia(
      tipo: TipoLicencia.local,
      estado: EstadoLicencia.activa,
      deviceId: 'dispositivo-demo',
      fechaActivacion: DateTime.now().subtract(const Duration(days: 30)),
      ultimaValidacion: DateTime.now(),
      fechaVencimiento: DateTime.now().add(const Duration(days: 300)),
    ),
  );
}

class _SesionActiva extends AuthController {
  _SesionActiva(this._usuario);

  final Usuario _usuario;

  @override
  Future<EstadoSesion> build() async => SesionActiva(_usuario);
}

/// Estilo de botón con `fontFamily: 'Roboto'` en su `textStyle`.
///
/// El tema de la app define el `textStyle` de los botones sin familia de
/// fuente: en un teléfono real se usa la del sistema, pero flutter_test cae en
/// su fuente de prueba (bloques). Solo para las capturas se fija Roboto.
ButtonStyle? _estiloConRoboto(ButtonStyle? estilo) {
  final texto = estilo?.textStyle;
  if (estilo == null || texto == null) return estilo;
  return estilo.copyWith(
    textStyle: WidgetStateProperty.resolveWith(
      (estados) => texto.resolve(estados)?.copyWith(fontFamily: 'Roboto'),
    ),
  );
}

/// Tema real de la app ([AppTheme.light]) más Roboto en los botones.
ThemeData _temaVisual() {
  final base = AppTheme.light();
  return base.copyWith(
    filledButtonTheme: FilledButtonThemeData(
      style: _estiloConRoboto(base.filledButtonTheme.style),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _estiloConRoboto(base.outlinedButtonTheme.style),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _estiloConRoboto(base.textButtonTheme.style),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _estiloConRoboto(base.elevatedButtonTheme.style),
    ),
  );
}

/// Equivalente a `AppGestion` para las capturas: mismo router real y mismo
/// tema, sin el chequeo de actualizaciones ni el motor de sync (red).
class _AppVisual extends ConsumerWidget {
  const _AppVisual();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'App Gestión Negocios',
      debugShowCheckedModeBanner: false,
      theme: _temaVisual(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

/// Deja avanzar las consultas de drift (asíncronas reales) y las animaciones
/// hasta que la pantalla queda estable. No se usa `pumpAndSettle` porque hay
/// indicadores de carga y cursores que animan indefinidamente.
Future<void> estabilizar(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// App real montada con base, licencia y sesión inyectadas.
class SesionVisual {
  SesionVisual._(
    this._tester,
    this._base,
    this._container,
    this.tamano,
    this.nombre,
    this._errores,
    this._manejadorOriginal,
  );

  final WidgetTester _tester;
  final BaseDemo _base;
  final ProviderContainer _container;
  final TamanoPantalla tamano;

  /// Nombre del escenario, para el informe de errores.
  final String nombre;

  /// Errores de Flutter ocurridos durante el escenario (texto -> veces).
  final Map<String, int> _errores;

  /// Manejador de errores previo: flutter_test exige restaurarlo ANTES de que
  /// termine el cuerpo del test (los tearDown corren después de esa revisión).
  final void Function(FlutterErrorDetails)? _manejadorOriginal;

  /// Navega a [ruta]. Con [apilar] la abre por encima de la pantalla actual
  /// (como al tocar un botón, con flecha de volver); sin él reemplaza la
  /// ubicación (como al tocar una pestaña).
  Future<void> ir(String ruta, {bool apilar = false}) async {
    final router = _container.read(appRouterProvider);
    if (apilar) {
      unawaited(router.push(ruta));
    } else {
      router.go(ruta);
    }
    await estabilizar(_tester);
  }

  /// Toca el primer widget con [texto] (haciendo scroll hasta él si está
  /// fuera de pantalla: las listas construyen sus ítems de forma perezosa) y
  /// espera a que se estabilice.
  Future<void> tocarTexto(String texto) async {
    final buscado = find.text(texto);
    if (buscado.evaluate().isEmpty) {
      await _tester.scrollUntilVisible(
        buscado,
        300,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await _tester.tap(buscado.first);
    await estabilizar(_tester);
  }

  /// Guarda `build/visual/TAMAÑO/NOMBRE.png` (con `--update-goldens`).
  Future<void> capturar(String nombre) async {
    await estabilizar(_tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../build/visual/${tamano.carpeta}/$nombre.png'),
    );
  }

  /// Desmonta la app y cierra la base DENTRO del test: drift deja timers
  /// pendientes mientras hay streams activos, y flutter_test los detecta al
  /// terminar el cuerpo del test (antes que cualquier tearDown). Además vuelca
  /// al informe los errores de Flutter que ocurrieron durante el escenario.
  Future<void> cerrar() async {
    // Sin foco, el cursor parpadeante (Timer.periodic) se cancela.
    FocusManager.instance.primaryFocus?.unfocus();
    await _tester.pump();
    // Se libera el contenedor ANTES de desmontar: algunas pantallas de la app
    // lanzan una aserción en dispose() (ref.read en dispose, no permitido en
    // Riverpod 3) que aborta el desmontaje del árbol y dejaría sin cancelar
    // los timers de los providers (p.ej. el del cambio de día).
    _container.dispose();
    await _tester.pumpWidget(const SizedBox.shrink());
    await _tester.pump(const Duration(seconds: 1));
    // drift programa timers al cancelar sus streams: si close() se esperara
    // dentro de runAsync (tiempo real), esos timers (falsos) nunca
    // dispararían y se colgaría. Se inicia el cierre en la zona del test, se
    // avanza el reloj falso y solo entonces se espera, con un tope.
    final cierre = _base.db.close();
    for (var i = 0; i < 5; i++) {
      await _tester.pump(const Duration(seconds: 1));
    }
    await _tester.runAsync(
      () => cierre.timeout(const Duration(seconds: 5), onTimeout: () {}),
    );
    // Restablecer la vista con el manejador propio aún activo: si quedó algún
    // observer huérfano por un desmontaje abortado, el error se registra en
    // el informe en vez de hacer fallar el test.
    _tester.view.reset();
    _tester.platformDispatcher.clearAllTestValues();
    await _tester.pump();
    FlutterError.onError = _manejadorOriginal;
    _escribirInforme(nombre, _errores);
  }
}

const _rutaInforme = 'build/visual/errores.txt';

/// Vacía el informe de errores. Llamar una vez en `setUpAll`.
void prepararInforme() {
  final archivo = File(_rutaInforme);
  archivo.parent.createSync(recursive: true);
  archivo.writeAsStringSync(
    'Errores de Flutter ocurridos al renderizar la app (no hacen fallar las '
    'capturas; overflows, asserts de debug, etc.).\n',
  );
}

void _escribirInforme(String escenario, Map<String, int> errores) {
  final texto = StringBuffer('\n## $escenario\n');
  if (errores.isEmpty) {
    texto.writeln('(sin errores)');
  } else {
    errores.forEach((mensaje, veces) => texto.writeln('- ($veces x) $mensaje'));
  }
  File(_rutaInforme).writeAsStringSync(texto.toString(), mode: FileMode.append);
}

String _resumir(FlutterErrorDetails detalles) {
  final primera = detalles.exceptionAsString().trim().split('\n').first;
  return '[${detalles.library ?? 'flutter'}] $primera';
}

/// Monta la app REAL (router y tema reales) con [base], sesión
/// activa del [rol] dado, en el [tamano] pedido. [textScale] simula el
/// tamaño de texto del sistema (accesibilidad).
Future<SesionVisual> montarApp(
  WidgetTester tester, {
  required String nombre,
  required BaseDemo base,
  required RolUsuario rol,
  required TamanoPantalla tamano,
  double textScale = 1.0,
}) async {
  // Los errores de Flutter (overflows, asserts de debug de la app) no deben
  // abortar la captura: se recolectan y se vuelcan a build/visual/errores.txt.
  final errores = <String, int>{};
  final manejadorOriginal = FlutterError.onError;
  FlutterError.onError = (detalles) {
    errores.update(_resumir(detalles), (v) => v + 1, ifAbsent: () => 1);
  };

  tester.view.physicalSize = Size(tamano.ancho * 2, tamano.alto * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  if (textScale != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
  }

  final usuario = base.usuarioDe(rol);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(base.db),
        licenseControllerProvider.overrideWith(_LicenciaActiva.new),
        authControllerProvider.overrideWith(() => _SesionActiva(usuario)),
      ],
      child: const _AppVisual(),
    ),
  );
  await estabilizar(tester);

  final container = ProviderScope.containerOf(
    tester.element(find.byType(_AppVisual)),
  );
  return SesionVisual._(
    tester,
    base,
    container,
    tamano,
    nombre,
    errores,
    manejadorOriginal,
  );
}

/// Monta la app, ejecuta [cuerpo] y SIEMPRE desmonta y cierra la base, aunque
/// el cuerpo falle (una base abierta cuelga los escenarios siguientes).
Future<void> escenarioVisual(
  WidgetTester tester, {
  required String nombre,
  required BaseDemo base,
  required RolUsuario rol,
  required TamanoPantalla tamano,
  double textScale = 1.0,
  required Future<void> Function(SesionVisual sesion) cuerpo,
}) async {
  final sesion = await montarApp(
    tester,
    nombre: nombre,
    base: base,
    rol: rol,
    tamano: tamano,
    textScale: textScale,
  );
  try {
    await cuerpo(sesion);
  } finally {
    await sesion.cerrar();
  }
}
