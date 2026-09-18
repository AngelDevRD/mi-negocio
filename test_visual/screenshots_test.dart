// Capturas visuales de la app real (QA visual repetible).
//
// Renderiza la app con flutter_test (fuentes reales, base demo de un colmado
// dominicano, sesión inyectada) y guarda PNGs en build/visual/<tamaño>/.
// Está FUERA de test/ para que `flutter test` normal no lo ejecute.
//
// Uso:
//   flutter test test_visual --update-goldens
//
// genera/actualiza todas las capturas en build/visual/ (que está en
// .gitignore: los PNG no se versionan). Sin --update-goldens el test compara
// contra las capturas existentes y falla si difieren.
//
// Además escribe build/visual/errores.txt con los errores de Flutter que
// ocurrieron al renderizar cada escenario (overflows, asserts de debug...):
// no hacen fallar las capturas, pero conviene revisarlos.
//
// Para agregar una captura: en el escenario que corresponda, navega con
// `sesion.ir('/ruta')` y llama a `sesion.capturar('nombre')`.

import 'package:app_gestion/core/database/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/visual_harness.dart';

void main() {
  setUpAll(() async {
    prepararInforme();
    await cargarFuentesReales();
  });

  testWidgets('teléfono · administrador', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.capturar('admin_inicio');

        await sesion.ir('/ventas');
        await sesion.capturar('admin_ventas');

        await sesion.ir('/caja');
        await sesion.capturar('admin_caja');

        await sesion.ir('/productos');
        await sesion.capturar('admin_productos');

        await sesion.ir('/mas');
        await sesion.capturar('admin_mas');

        await sesion.tocarTexto('Cerrar sesión');
        await sesion.capturar('admin_cerrar_sesion_dialogo');
        await sesion.tocarTexto('Cancelar');
      },
    );
  });

  testWidgets('teléfono · cajero', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · cajero',
      base: base,
      rol: RolUsuario.cajero,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.ir('/mas');
        await sesion.capturar('cajero_mas');
      },
    );
  });

  testWidgets('teléfono · administrador · base vacía', (tester) async {
    final base = (await tester.runAsync(() => crearBaseDemo(vacia: true)))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · base vacía',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.capturar('vacio_inicio');

        await sesion.ir('/productos');
        await sesion.capturar('vacio_productos');

        await sesion.ir('/ventas');
        await sesion.capturar('vacio_ventas');
      },
    );
  });

  testWidgets('tablet · administrador', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'tablet · administrador',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.tablet,
      cuerpo: (sesion) async {
        await sesion.capturar('admin_inicio');

        await sesion.ir('/productos');
        await sesion.capturar('admin_productos');
      },
    );
  });

  testWidgets('escritorio · administrador', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'escritorio · administrador',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.escritorio,
      cuerpo: (sesion) async {
        await sesion.capturar('admin_inicio');

        await sesion.ir('/productos');
        await sesion.capturar('admin_productos');

        await sesion.ir('/mas');
        await sesion.capturar('admin_mas');
      },
    );
  });

  testWidgets('teléfono · administrador · texto grande 1.6', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · texto grande 1.6',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      textScale: 1.6,
      cuerpo: (sesion) async {
        await sesion.capturar('texto_grande_inicio');
      },
    );
  });

  // Al final a propósito: las pantallas de venta rápida/detallada hacen
  // ref.read en dispose() (aserción de Riverpod 3) y su desmontaje deja
  // observers huérfanos que no deben contaminar a otros escenarios.
  testWidgets('teléfono · administrador · pantallas apiladas', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · pantallas apiladas',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        // Con varias pestañas ya visitadas (cada una con su FAB), abrir una
        // pantalla por encima del shell dispara el error de Hero de FABs
        // duplicados: queda en errores.txt.
        await sesion.ir('/ventas');
        await sesion.ir('/productos');
        await sesion.ir('/productos/nuevo', apilar: true);
        await sesion.capturar('admin_producto_nuevo');

        await sesion.ir('/ventas/rapida', apilar: true);
        await sesion.capturar('admin_venta_rapida');

        await sesion.ir('/caja/cerrar', apilar: true);
        await sesion.capturar('admin_cierre_caja');
      },
    );
  });
}
