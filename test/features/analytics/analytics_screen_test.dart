import 'dart:async';

import 'package:app_gestion/core/theme/app_theme.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/core/widgets/widgets.dart';
import 'package:app_gestion/features/analytics/domain/entities/analytics_data.dart';
import 'package:app_gestion/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:app_gestion/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

enum _Modo { datos, vacio, carga, error }

/// Todos los flujos del análisis con datos de prueba (sin drift).
List<Override> _overrides(_Modo modo, {List<int>? consultas}) {
  Stream<T> flujo<T>(T datos, T vacio) {
    consultas?.add(1);
    return switch (modo) {
      _Modo.datos => Stream.value(datos),
      _Modo.vacio => Stream.value(vacio),
      _Modo.carga => StreamController<T>().stream,
      _Modo.error => Stream.error(StateError('boom')),
    };
  }

  const cero = Money.zero;
  return <Override>[
    resumenFinancieroProvider.overrideWith(
      (ref) => flujo(
        const ResumenFinanciero(
          ventas: Money(125000000),
          compras: Money(40000000),
          gastos: Money(15000000),
          sueldos: Money(20000000),
          ganancia: Money(30000000),
          dineroMovido: Money(200000000),
          valorInventario: Money(50000000),
        ),
        const ResumenFinanciero(
          ventas: cero,
          compras: cero,
          gastos: cero,
          sueldos: cero,
          ganancia: cero,
          dineroMovido: cero,
          valorInventario: cero,
        ),
      ),
    ),
    comparativaMensualProvider.overrideWith(
      (ref) => flujo(
        const ComparativaMensual(
          ventasActual: Money(1250000),
          ventasAnterior: Money(1000000),
          gastosActual: Money(300000),
          gastosAnterior: Money(400000),
          gananciaActual: Money(500000),
          gananciaAnterior: Money(0),
        ),
        const ComparativaMensual(
          ventasActual: cero,
          ventasAnterior: cero,
          gastosActual: cero,
          gastosAnterior: cero,
          gananciaActual: cero,
          gananciaAnterior: cero,
        ),
      ),
    ),
    serieMensualProvider.overrideWith(
      (ref) => flujo([
        PuntoMensual(
          mes: DateTime(2026, 7),
          ventas: const Money(4000000),
          compras: const Money(1000000),
          gastos: const Money(500000),
          sueldos: const Money(500000),
          ganancia: const Money(1200000),
        ),
        PuntoMensual(
          mes: DateTime(2026, 8),
          ventas: const Money(2000000),
          compras: const Money(1500000),
          gastos: const Money(900000),
          sueldos: const Money(500000),
          ganancia: const Money(-300000),
        ),
        PuntoMensual(
          mes: DateTime(2026, 9),
          ventas: const Money(4500000),
          compras: const Money(1000000),
          gastos: const Money(600000),
          sueldos: const Money(500000),
          ganancia: const Money(1500000),
        ),
      ], const <PuntoMensual>[]),
    ),
    gastosPorCategoriaProvider.overrideWith(
      (ref) => flujo(const [
        GastoPorCategoria(categoria: 'Alquiler', total: Money(180000)),
        GastoPorCategoria(categoria: 'Luz', total: Money(385000)),
      ], const <GastoPorCategoria>[]),
    ),
    rankingProductosProvider.overrideWith(
      (ref) => flujo(const [
        ProductoVentasRanking(
          id: 'a',
          nombre: 'Arroz selecto',
          unidades: 120.5,
          ganancia: Money(420000),
        ),
        ProductoVentasRanking(
          id: 'b',
          nombre: 'Salami',
          unidades: 3,
          ganancia: Money(90000),
        ),
      ], const <ProductoVentasRanking>[]),
    ),
    rankingEmpleadosProvider.overrideWith(
      (ref) => flujo([
        EmpleadoPagosRanking(
          id: 'e1',
          nombre: 'Ana Ventura',
          fechaIngreso: DateTime(2024, 6, 10, 12).toUtc(),
          totalPagado: const Money(9000000),
        ),
      ], const <EmpleadoPagosRanking>[]),
    ),
  ];
}

Future<ProviderContainer> _montar(
  WidgetTester tester,
  _Modo modo, {
  double textScale = 1.0,
  Size tamano = const Size(360, 8000),
  List<int>? consultas,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides(modo, consultas: consultas),
      child: MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const AnalyticsScreen(),
      ),
    ),
  );
  // Con cargas eternas hay indicadores animados: pumpAndSettle no termina.
  modo == _Modo.carga
      ? await tester.pump(const Duration(milliseconds: 300))
      : await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
}

/// Recorre TODA la pantalla (la lista es perezosa) para construir todo.
Future<void> _recorrer(WidgetTester tester) async {
  final lista = find.byType(Scrollable).first;
  for (var i = 0; i < 30; i++) {
    await tester.drag(lista, const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('cargando: cada sección muestra su indicador', (tester) async {
    await _montar(tester, _Modo.carga);

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Período'), findsOneWidget);
  });

  testWidgets('error: mensaje humano por sección y "Reintentar" vuelve a '
      'consultar', (tester) async {
    final consultas = <int>[];
    await _montar(tester, _Modo.error, consultas: consultas);

    expect(find.text('No se pudo cargar el resumen.'), findsOneWidget);
    expect(find.text('No se pudo cargar la comparativa.'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    final antes = consultas.length;

    await tester.tap(find.text('Reintentar').first);
    await tester.pumpAndSettle();

    expect(consultas.length, greaterThan(antes));
  });

  testWidgets('sin movimientos: cada gráfica dice por qué está vacía', (
    tester,
  ) async {
    await _montar(tester, _Modo.vacio);

    expect(find.text('Aún no hay datos para este período'), findsWidgets);
    expect(find.text('Aún no hay productos vendidos'), findsOneWidget);
    expect(find.text('Aún no hay empleados'), findsOneWidget);
    expect(find.textContaining('Aparecerán cuando registres'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  group('con datos', () {
    testWidgets('resumen: montos completos con MoneyText (sin recortar)', (
      tester,
    ) async {
      await _montar(tester, _Modo.datos);

      expect(find.text('RD\$ 1,250,000.00'), findsOneWidget); // ventas
      expect(find.text('RD\$ 300,000.00'), findsOneWidget); // ganancia neta
      expect(find.byType(MoneyText), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('comparativa: flecha + signo + porcentaje (no solo color)', (
      tester,
    ) async {
      await _montar(tester, _Modo.datos);

      expect(find.text('+25.0%'), findsOneWidget); // ventas
      expect(find.byIcon(Icons.arrow_upward), findsWidgets);
      expect(find.text('-25.0%'), findsOneWidget); // gastos bajaron
      expect(find.byIcon(Icons.arrow_downward), findsWidgets);
      // Ganancia con mes anterior en 0: no hay base para comparar.
      expect(find.text('Sin comparación'), findsOneWidget);
    });

    testWidgets('gráficas: leyenda con TEXTO y cifras mes por mes', (
      tester,
    ) async {
      await _montar(tester, _Modo.datos);

      expect(find.text('Ventas vs gastos por mes'), findsOneWidget);
      // Leyenda de la gráfica de líneas (además de las tarjetas y filas).
      expect(find.text('Ventas'), findsWidgets);
      expect(find.text('Gastos'), findsWidgets);
      expect(
        find.textContaining('Barras rojas: meses con pérdida'),
        findsOneWidget,
      );
      // Detalle por mes: las cifras que la barra no puede dar.
      expect(find.text('julio 2026'), findsOneWidget);
      expect(find.text('agosto 2026'), findsOneWidget);
      expect(find.text('septiembre 2026'), findsOneWidget);
      expect(find.text('RD\$ -3,000.00'), findsOneWidget); // pérdida de agosto
      expect(find.text('RD\$ 15,000.00'), findsOneWidget); // ganancia sept.
    });

    testWidgets('gastos por categoría: nombre y monto de cada porción', (
      tester,
    ) async {
      await _montar(tester, _Modo.datos);

      expect(find.text('Alquiler'), findsOneWidget);
      expect(find.text('RD\$ 1,800.00'), findsOneWidget);
      expect(find.text('Luz'), findsOneWidget);
      expect(find.text('RD\$ 3,850.00'), findsOneWidget);
    });

    testWidgets('rankings: productos y empleados con fecha local', (
      tester,
    ) async {
      await _montar(tester, _Modo.datos);

      expect(find.text('Más vendido'), findsOneWidget);
      expect(find.text('120.5'), findsOneWidget);
      expect(find.text('Menos vendido'), findsOneWidget);
      expect(find.text('Más rentable'), findsOneWidget);
      expect(find.text('RD\$ 4,200.00'), findsOneWidget);
      expect(find.text('Ana Ventura'), findsNWidgets(2));
      expect(find.text('10/06/2024'), findsOneWidget);
      expect(find.text('RD\$ 90,000.00'), findsOneWidget);
    });
  });

  group('período', () {
    testWidgets('cuatro opciones con texto; elegir una cambia el rango', (
      tester,
    ) async {
      final c = await _montar(tester, _Modo.datos);

      for (final t in [
        'Este mes',
        'Últimos 3 meses',
        'Últimos 12 meses',
        'Todo',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(c.read(rangoAnalisisProvider), RangoAnalisis.mes);

      await tester.tap(find.text('Todo'));
      await tester.pumpAndSettle();

      expect(c.read(rangoAnalisisProvider), RangoAnalisis.todo);
    });
  });

  group('sin desbordes', () {
    for (final (nombre, tamano, escala) in [
      ('teléfono 360 px', const Size(360, 800), 1.0),
      ('teléfono 360 px con texto 1.3x', const Size(360, 800), 1.3),
      ('teléfono angosto 320 px con texto 1.3x', const Size(320, 700), 1.3),
      ('escritorio', const Size(1200, 800), 1.0),
    ]) {
      testWidgets(nombre, (tester) async {
        await _montar(tester, _Modo.datos, tamano: tamano, textScale: escala);
        await _recorrer(tester);

        // Un overflow de layout sale como excepción de Flutter.
        expect(tester.takeException(), isNull);
      });
    }
  });
}
