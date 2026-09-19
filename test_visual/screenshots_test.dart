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

        // Filtro de fecha con texto: el menú y una semana filtrada.
        await sesion.tocarTexto('Todas las fechas');
        await sesion.capturar('admin_ventas_filtro_fecha');
        await sesion.tocarTexto('Esta semana');
        await sesion.capturar('admin_ventas_semana');
        await sesion.tocarTexto('Esta semana');
        await sesion.tocarTexto('Todas las fechas');

        // Más abajo: los días anteriores, cada uno con su total.
        await sesion.mostrarTexto('Ayer');
        await sesion.capturar('admin_ventas_ayer');

        await sesion.ir('/caja');
        await sesion.capturar('admin_caja');

        // Salida manual de efectivo: motivo rápido en chip.
        await sesion.tocarTexto('Salida');
        await sesion.escribir('Monto', '150');
        await sesion.tocarTexto('Delivery');
        await sesion.capturar('admin_caja_salida_dialogo');
        await sesion.tocarTexto('Cancelar');

        await sesion.ir('/productos');
        await sesion.capturar('admin_productos');

        // Filtro "Stock bajo" y detalle único del producto (admin).
        await sesion.tocarTexto('Stock bajo');
        await sesion.capturar('admin_productos_stock_bajo');
        await sesion.tocarTexto('Todos');
        await sesion.tocarTexto('Arroz selecto');
        await sesion.capturar('admin_producto_detalle');
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

        // Caja del cajero: Entrada y Salida, sin Cerrar caja.
        await sesion.ir('/caja');
        await sesion.capturar('cajero_caja');

        // Detalle de producto del cajero: sin costo, margen ni "Ajustar stock".
        await sesion.ir('/productos');
        await sesion.tocarTexto('Arroz selecto');
        await sesion.capturar('cajero_producto_detalle');
      },
    );
  });

  testWidgets('teléfono · administrador · caja cerrada', (tester) async {
    final base = (await tester.runAsync(
      () => crearBaseDemo(cajaCerrada: true),
    ))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · caja cerrada',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.capturar('caja_cerrada_inicio');

        // Pestaña Caja cerrada, historial y detalle de un cierre con su resumen.
        await sesion.ir('/caja');
        await sesion.capturar('caja_cerrada');
        await sesion.tocarTexto('Historial');
        await sesion.capturar('caja_historial');
        await sesion.tocarTextoQueContiene('Cerrada por');
        await sesion.capturar('caja_cierre_detalle');
        await sesion.mostrarTexto('Efectivo esperado');
        await sesion.capturar('caja_cierre_detalle_resumen');
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

        await sesion.ir('/ventas');
        await sesion.capturar('admin_ventas');

        await sesion.ir('/clientes');
        await sesion.capturar('admin_clientes');

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

  testWidgets('teléfono · administrador · punto de venta', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · punto de venta',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.ir('/ventas/rapida', apilar: true);
        await sesion.capturar('pos_vacio');

        // Un solo producto: su tarjeta queda marcada ("En carrito").
        await _agregarAlCarrito(sesion, ['Arroz selecto']);
        await sesion.capturar('pos_producto_marcado');

        await _agregarAlCarrito(sesion, [
          'Habichuelas rojas',
          'Aceite vegetal 1 L',
        ]);
        await sesion.capturar('pos_telefono');

        // Cobro: total RD$ 260 -> chips Exacto/500/1000/2000; con el 500 el
        // cambio (RD$ 240) es el dato principal.
        await sesion.tocarTexto('Cobrar');
        await sesion.capturar('pos_cobro');
        await sesion.tocarTexto('500');
        await sesion.capturar('pos_cobro_cambio');
        await sesion.tocarTexto('Cancelar');

        await sesion.tocarTexto('3 artículos');
        await sesion.capturar('pos_hoja_carrito');
      },
    );
  });

  testWidgets('escritorio · administrador · punto de venta', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'escritorio · administrador · punto de venta',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.escritorio,
      cuerpo: (sesion) async {
        await sesion.ir('/ventas/rapida', apilar: true);
        await sesion.capturar('pos_vacio');

        await _agregarAlCarrito(sesion);
        await sesion.capturar('pos_escritorio');
      },
    );
  });

  testWidgets('teléfono · administrador · punto de venta · texto 1.6', (
    tester,
  ) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · punto de venta · texto 1.6',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      textScale: 1.6,
      cuerpo: (sesion) async {
        await sesion.ir('/ventas/rapida', apilar: true);
        // Con texto 1.6 solo caben ~3 filas: se eligen productos visibles (el
        // scroll automático tomaría el Scrollable de la pantalla de abajo).
        await _agregarAlCarrito(sesion, [
          'Aceite vegetal 1 L',
          'Agua 500 ml',
          'Arroz selecto',
        ]);
        await sesion.capturar('pos_texto_grande');

        await sesion.tocarTexto('Cobrar');
        await sesion.capturar('pos_texto_grande_cobro');
        await sesion.tocarTexto('Cancelar');

        await sesion.tocarTexto('3 artículos');
        await sesion.capturar('pos_texto_grande_hoja');
      },
    );
  });

  testWidgets('teléfono · administrador · ajustes y venta sin stock', (
    tester,
  ) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · ajustes y venta sin stock',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.ir('/mas');
        await sesion.capturar('admin_mas_ajustes');

        await sesion.ir('/ajustes', apilar: true);
        await sesion.capturar('ajustes');

        // Se desactiva "Permitir vender sin stock" (se guarda al instante).
        await sesion.tocarTexto('Permitir vender sin stock');
        await sesion.capturar('ajustes_desactivado');

        // El detergente tiene 2 unidades: la tercera agregada ya no cabe.
        await sesion.ir('/ventas/rapida', apilar: true);
        for (var i = 0; i < 3; i++) {
          await sesion.tocarTexto('Detergente en polvo 1 kg');
          await sesion.tocarTexto('Agregar');
        }
        await sesion.capturar('pos_stock_bloqueado');
        await sesion.tocarTexto('Entendido');
      },
    );
  });

  testWidgets('teléfono · administrador · método de pago', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · método de pago',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.ir('/ventas/rapida', apilar: true);
        await _agregarAlCarrito(sesion, [
          'Huevos',
          'Pan de agua',
          'Jabón de cuaba',
        ]);

        // Cobro con tarjeta: sin monto recibido, chips ni cambio.
        await sesion.tocarTexto('Cobrar');
        await sesion.capturar('pos_cobro_efectivo');
        await sesion.tocarTexto('Tarjeta');
        await sesion.capturar('pos_cobro_tarjeta');
        await sesion.tocarTexto('Confirmar pago');

        // La venta queda registrada con tarjeta: se ve en su detalle.
        await sesion.ir('/ventas');
        await sesion.tocarTexto('RD\$ 37.00');
        await sesion.capturar('venta_detalle_tarjeta');
      },
    );
  });

  testWidgets('teléfono · administrador · clientes y fiado', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · clientes y fiado',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        // Inicio con el indicador "Por cobrar (fiado)".
        await sesion.capturar('inicio_por_cobrar');

        await sesion.ir('/clientes');
        await sesion.capturar('clientes_lista');
        await sesion.tocarTexto('Todos');
        await sesion.capturar('clientes_lista_todos');

        await sesion.tocarTexto('Rosa Martínez');
        await sesion.capturar('cliente_detalle');
        await sesion.tocarTexto('Registrar abono');
        await sesion.capturar('cliente_abono');
        await sesion.tocarTexto('Cancelar');

        // Cobro fiado: selector de cliente y cliente con límite elegido.
        await sesion.ir('/ventas/rapida', apilar: true);
        await _agregarAlCarrito(sesion, ['Huevos', 'Pan de agua']);
        await sesion.tocarTexto('Cobrar');
        await sesion.tocarTexto('Fiado');
        await sesion.tocarTexto('Elegir cliente');
        await sesion.capturar('pos_cobro_fiado_selector');
        await sesion.tocarTexto('Carmen Suárez');
        await sesion.capturar('pos_cobro_fiado');
        await sesion.tocarTexto('Cancelar');
      },
    );
  });

  testWidgets('teléfono · administrador · compras y gastos', (tester) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · compras y gastos',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        await sesion.ir('/compras', apilar: true);
        await sesion.capturar('admin_compras');
        await sesion.tocarTextoQueContiene('Factura F-1042');
        await sesion.capturar('admin_compra_detalle');
        await sesion.tocarTexto('Anular compra');
        await sesion.capturar('admin_compra_anular_dialogo');
        await sesion.tocarTexto('Cancelar');

        // Formulario de compra: vacío y con un producto (total siempre visible).
        await sesion.ir('/compras/nueva', apilar: true);
        await sesion.capturar('admin_compra_formulario_vacio');
        await sesion.tocarTexto('Agregar producto');
        await sesion.tocarTexto('Arroz selecto');
        await sesion.tocarTexto('Agregar');
        await sesion.capturar('admin_compra_formulario');

        await sesion.ir('/gastos', apilar: true);
        await sesion.capturar('admin_gastos');
      },
    );
  });

  testWidgets('teléfono · administrador · empleados, usuarios y categorías', (
    tester,
  ) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · empleados, usuarios y categorías',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        // Empleados: lista de Ventas, lista de Delivery (con un inactivo),
        // detalle con antigüedad y pestaña de pagos.
        await sesion.ir('/empleados', apilar: true);
        await sesion.capturar('admin_empleados_lista');
        await sesion.tocarTexto('Delivery');
        await sesion.capturar('admin_empleados_delivery');
        await sesion.tocarTexto('Ventas');
        await sesion.tocarTexto('Ana Ventura');
        await sesion.capturar('admin_empleado_detalle');
        await sesion.tocarTexto('Pagos');
        await sesion.capturar('admin_empleado_pagos');
        await sesion.tocarTexto('Registrar pago');
        await sesion.capturar('admin_empleado_pago_formulario');
        await sesion.atras();
        await sesion.atras();

        // Formulario de empleado: salir con cambios pide confirmar.
        await sesion.ir('/empleados/nuevo', apilar: true);
        await sesion.escribir('Nombre', 'Juan Reyes');
        await sesion.capturar('admin_empleado_formulario');
        await sesion.atras();
        await sesion.capturar('admin_empleado_descartar');
        await sesion.tocarTexto('Descartar');

        // Usuarios: roles y estados, nuevo cajero y desactivar al único admin.
        await sesion.ir('/usuarios', apilar: true);
        await sesion.capturar('admin_usuarios');
        await sesion.tocarTexto('Nuevo cajero');
        await sesion.escribir('Nombre', 'Carlos Cajero');
        await sesion.escribir('Usuario', 'carlos');
        await sesion.escribir('Contraseña', 'clave123');
        await sesion.tocarTooltip('Mostrar contraseña');
        await sesion.capturar('admin_usuarios_nuevo_cajero');
        await sesion.tocarTexto('Cancelar');
        await sesion.tocarTooltip('Acciones de Carmen Rodríguez');
        await sesion.tocarTexto('Desactivar');
        await sesion.capturar('admin_usuarios_desactivar_confirmar');
        await sesion.tocarTexto('Desactivar');
        await sesion.capturar('admin_usuarios_unico_admin');

        // Categorías: lista y confirmación destructiva de eliminar.
        await sesion.ir('/productos/categorias', apilar: true);
        await sesion.capturar('admin_categorias');
        await sesion.tocarTooltip('Acciones de Limpieza');
        await sesion.tocarTexto('Eliminar');
        await sesion.capturar('admin_categorias_eliminar');
        await sesion.tocarTexto('Cancelar');
      },
    );
  });

  testWidgets('teléfono · administrador · formulario de producto y ajuste', (
    tester,
  ) async {
    final base = (await tester.runAsync(crearBaseDemo))!;
    await escenarioVisual(
      tester,
      nombre: 'teléfono · administrador · formulario de producto y ajuste',
      base: base,
      rol: RolUsuario.administrador,
      tamano: TamanoPantalla.telefono,
      cuerpo: (sesion) async {
        // Formulario de producto (admin): unidad con sugerencias y margen
        // en vivo; luego un precio por debajo del costo.
        await sesion.ir('/productos/nuevo', apilar: true);
        await sesion.capturar('admin_producto_formulario_vacio');
        await sesion.escribir('Nombre', 'Yuca');
        await sesion.tocarTexto('libra');
        await sesion.escribir('Precio de compra', '20');
        await sesion.escribir('Precio de venta', '35');
        await sesion.capturar('admin_producto_formulario_margen');
        await sesion.escribir('Precio de venta', '15');
        await sesion.capturar('admin_producto_formulario_bajo_costo');
        await sesion.atras();
        await sesion.tocarTexto('Descartar');

        // Ajuste de stock: salida con "quedará Y", motivo con chips.
        await sesion.ir('/productos');
        await sesion.tocarTexto('Arroz selecto');
        await sesion.tocarTexto('Ajustar stock');
        await sesion.capturar('admin_ajuste_stock');
        await sesion.tocarTexto('Salida');
        await sesion.escribir('Cantidad', '8.5');
        await sesion.tocarTexto('Merma');
        await sesion.capturar('admin_ajuste_stock_salida');
        await sesion.escribir('Cantidad', '500');
        await sesion.capturar('admin_ajuste_stock_negativo');
      },
    );
  });

  // Al final a propósito: un desmontaje abortado deja observers huérfanos que
  // no deben contaminar a otros escenarios.
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

        await sesion.ir('/caja/cerrar', apilar: true);
        await sesion.capturar('admin_cierre_caja');
        await sesion.mostrarTexto('Efectivo esperado');
        await sesion.capturar('admin_cierre_caja_resumen');
      },
    );
  });
}

/// Agrega productos al carrito del POS (por defecto tres; toca la tarjeta y confirma la
/// cantidad por defecto del diálogo).
Future<void> _agregarAlCarrito(
  SesionVisual sesion, [
  List<String> productos = const [
    'Arroz selecto',
    'Habichuelas rojas',
    'Aceite vegetal 1 L',
  ],
]) async {
  for (final producto in productos) {
    await sesion.tocarTexto(producto);
    await sesion.tocarTexto('Agregar');
  }
}
