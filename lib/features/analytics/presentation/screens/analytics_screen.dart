import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/analytics_data.dart';
import '../providers/analytics_providers.dart';

/// Centro de análisis financiero (RF-ANL, solo Administrador).
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis financiero')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _RangoSelector(),
          const SizedBox(height: AppSpacing.md),
          const _ResumenCards(),
          const SizedBox(height: AppSpacing.lg),
          const _ComparativaCard(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Ventas vs gastos por mes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _VentasGastosChart(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Ganancia mensual',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _GananciaMensualChart(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Gastos por categoría',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _GastosPorCategoriaChart(),
          const SizedBox(height: AppSpacing.lg),
          Text('Productos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          const _RankingProductos(),
          const SizedBox(height: AppSpacing.lg),
          Text('Empleados', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          const _RankingEmpleados(),
        ],
      ),
    );
  }
}

class _RangoSelector extends ConsumerWidget {
  const _RangoSelector();

  String _etiqueta(RangoAnalisis rango) => switch (rango) {
    RangoAnalisis.mes => 'Mes',
    RangoAnalisis.trimestre => 'Trimestre',
    RangoAnalisis.anio => 'Año',
    RangoAnalisis.todo => 'Todo',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rango = ref.watch(rangoAnalisisProvider);
    return SegmentedButton<RangoAnalisis>(
      segments: [
        for (final opcion in RangoAnalisis.values)
          ButtonSegment(value: opcion, label: Text(_etiqueta(opcion))),
      ],
      selected: {rango},
      onSelectionChanged: (seleccion) =>
          ref.read(rangoAnalisisProvider.notifier).seleccionar(seleccion.first),
    );
  }
}

class _ResumenCards extends ConsumerWidget {
  const _ResumenCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenFinancieroProvider);
    return resumen.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('No se pudo cargar el resumen.'),
      data: (r) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.8,
        children: [
          _ResumenCard(titulo: 'Ventas', valor: r.ventas),
          _ResumenCard(titulo: 'Compras', valor: r.compras),
          _ResumenCard(titulo: 'Gastos', valor: r.gastos),
          _ResumenCard(titulo: 'Sueldos', valor: r.sueldos),
          _ResumenCard(
            titulo: 'Ganancia neta',
            valor: r.ganancia,
            destacado: true,
          ),
          _ResumenCard(titulo: 'Dinero movido', valor: r.dineroMovido),
          _ResumenCard(titulo: 'Valor de inventario', valor: r.valorInventario),
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard({
    required this.titulo,
    required this.valor,
    this.destacado = false,
  });

  final String titulo;
  final Money valor;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: destacado ? scheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              valor.format(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparativaCard extends ConsumerWidget {
  const _ComparativaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparativa = ref.watch(comparativaMensualProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: comparativa.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Text('No se pudo cargar la comparativa.'),
          data: (c) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes actual vs mes anterior',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ComparativaFila(
                etiqueta: 'Ventas',
                actual: c.ventasActual,
                anterior: c.ventasAnterior,
                variacion: c.variacionVentas,
              ),
              _ComparativaFila(
                etiqueta: 'Gastos',
                actual: c.gastosActual,
                anterior: c.gastosAnterior,
                variacion: c.variacionGastos,
              ),
              _ComparativaFila(
                etiqueta: 'Ganancia',
                actual: c.gananciaActual,
                anterior: c.gananciaAnterior,
                variacion: c.variacionGanancia,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparativaFila extends StatelessWidget {
  const _ComparativaFila({
    required this.etiqueta,
    required this.actual,
    required this.anterior,
    required this.variacion,
  });

  final String etiqueta;
  final Money actual;
  final Money anterior;
  final double? variacion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final positivo = (variacion ?? 0) >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${anterior.format()}  →  ${actual.format()}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (variacion != null)
            Text(
              '${positivo ? '+' : ''}${variacion!.toStringAsFixed(1)}%',
              style: TextStyle(
                color: positivo ? scheme.primary : scheme.error,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const Text('—'),
        ],
      ),
    );
  }
}

/// Etiqueta corta "ene", "feb"... para los ejes de las gráficas.
String _etiquetaMes(DateTime mes) =>
    DateFormat('MMM', 'es').format(mes).replaceAll('.', '');

class _VentasGastosChart extends ConsumerWidget {
  const _VentasGastosChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serie = ref.watch(serieMensualProvider);
    final scheme = Theme.of(context).colorScheme;
    return serie.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Text('No se pudo cargar la serie mensual.'),
      data: (puntos) {
        if (puntos.isEmpty) {
          return const _SinDatos();
        }
        return SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= puntos.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(_etiquetaMes(puntos[i].mes)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: false,
                  color: scheme.primary,
                  dotData: const FlDotData(show: false),
                  spots: [
                    for (var i = 0; i < puntos.length; i++)
                      FlSpot(i.toDouble(), puntos[i].ventas.cents / 100),
                  ],
                ),
                LineChartBarData(
                  isCurved: false,
                  color: scheme.error,
                  dotData: const FlDotData(show: false),
                  spots: [
                    for (var i = 0; i < puntos.length; i++)
                      FlSpot(i.toDouble(), puntos[i].gastos.cents / 100),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GananciaMensualChart extends ConsumerWidget {
  const _GananciaMensualChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serie = ref.watch(serieMensualProvider);
    final scheme = Theme.of(context).colorScheme;
    return serie.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Text('No se pudo cargar la ganancia mensual.'),
      data: (puntos) {
        if (puntos.isEmpty) {
          return const _SinDatos();
        }
        return SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= puntos.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(_etiquetaMes(puntos[i].mes)),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < puntos.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: puntos[i].ganancia.cents / 100,
                        color: puntos[i].ganancia.isNegative
                            ? scheme.error
                            : scheme.primary,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GastosPorCategoriaChart extends ConsumerWidget {
  const _GastosPorCategoriaChart();

  static const _colores = [
    Colors.teal,
    Colors.orange,
    Colors.indigo,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.amber,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(gastosPorCategoriaProvider);
    return categorias.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) =>
          const Text('No se pudo cargar los gastos por categoría.'),
      data: (lista) {
        if (lista.isEmpty) {
          return const _SinDatos();
        }
        final total = lista.fold<int>(0, (acc, g) => acc + g.total.cents);
        return Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    for (var i = 0; i < lista.length; i++)
                      PieChartSectionData(
                        value: lista[i].total.cents.toDouble(),
                        color: _colores[i % _colores.length],
                        title: total == 0
                            ? '0%'
                            : '${(lista[i].total.cents * 100 / total).round()}%',
                        radius: 60,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (var i = 0; i < lista.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: _colores[i % _colores.length],
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('${lista[i].categoria}: ${lista[i].total.format()}'),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RankingProductos extends ConsumerWidget {
  const _RankingProductos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(rankingProductosProvider);
    return productos.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('No se pudo cargar el ranking de productos.'),
      data: (lista) {
        if (lista.isEmpty) {
          return const _SinDatos();
        }
        final porUnidades = [...lista]
          ..sort((a, b) => b.unidades.compareTo(a.unidades));
        final porGanancia = [...lista]
          ..sort((a, b) => b.ganancia.compareTo(a.ganancia));
        final masVendido = porUnidades.first;
        final menosVendido = porUnidades.last;
        final masRentable = porGanancia.first;
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Más vendido'),
                subtitle: Text(masVendido.nombre),
                trailing: Text(masVendido.unidades.toStringAsFixed(2)),
              ),
              ListTile(
                leading: const Icon(Icons.trending_down),
                title: const Text('Menos vendido'),
                subtitle: Text(menosVendido.nombre),
                trailing: Text(menosVendido.unidades.toStringAsFixed(2)),
              ),
              ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Más rentable'),
                subtitle: Text(masRentable.nombre),
                trailing: Text(masRentable.ganancia.format()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RankingEmpleados extends ConsumerWidget {
  const _RankingEmpleados();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empleados = ref.watch(rankingEmpleadosProvider);
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return empleados.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('No se pudo cargar el ranking de empleados.'),
      data: (lista) {
        if (lista.isEmpty) {
          return const _SinDatos();
        }
        final masAntiguo = lista.first;
        final porPagos = [...lista]
          ..sort((a, b) => b.totalPagado.compareTo(a.totalPagado));
        final masPagado = porPagos.first;
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Mayor antigüedad'),
                subtitle: Text(masAntiguo.nombre),
                trailing: Text(formatoFecha.format(masAntiguo.fechaIngreso)),
              ),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Mayor total pagado'),
                subtitle: Text(masPagado.nombre),
                trailing: Text(masPagado.totalPagado.format()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SinDatos extends StatelessWidget {
  const _SinDatos();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.outline),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(child: Text('Aún no hay datos para este rango.')),
          ],
        ),
      ),
    );
  }
}
