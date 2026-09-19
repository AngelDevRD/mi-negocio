import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/analytics_data.dart';
import '../providers/analytics_providers.dart';

/// Centro de análisis financiero (RF-ANL, solo Administrador).
///
/// El período (mes, trimestre, año, todo) lo define el DAO de análisis
/// (agregados "desde"), por eso no usa el filtro de fechas de las listas.
/// Cada gráfica trae su leyenda con TEXTO y una tabla con las cifras: nada
/// depende solo del color.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titulo = Theme.of(context).textTheme.titleMedium;
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
          Text('Ventas vs gastos por mes', style: titulo),
          const SizedBox(height: AppSpacing.sm),
          const _VentasGastosChart(),
          const SizedBox(height: AppSpacing.lg),
          Text('Ganancia mensual', style: titulo),
          const SizedBox(height: AppSpacing.sm),
          const _GananciaMensualChart(),
          const SizedBox(height: AppSpacing.lg),
          Text('Detalle por mes', style: titulo),
          const SizedBox(height: AppSpacing.sm),
          const _DetalleMensual(),
          const SizedBox(height: AppSpacing.lg),
          Text('Gastos por categoría', style: titulo),
          const SizedBox(height: AppSpacing.sm),
          const _GastosPorCategoriaChart(),
          const SizedBox(height: AppSpacing.lg),
          Text('Productos', style: titulo),
          const SizedBox(height: AppSpacing.sm),
          const _RankingProductos(),
          const SizedBox(height: AppSpacing.lg),
          Text('Empleados', style: titulo),
          const SizedBox(height: AppSpacing.sm),
          const _RankingEmpleados(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estados compartidos
// ---------------------------------------------------------------------------

/// Carga de una sección (alto fijo para que la pantalla no salte).
class _CargandoSeccion extends StatelessWidget {
  const _CargandoSeccion();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 120, child: LoadingView());
}

/// Sin datos en una sección: dice por qué y qué hacer.
class _SinDatos extends StatelessWidget {
  const _SinDatos({this.titulo = 'Aún no hay datos para este período'});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: EmptyState(
        compacto: true,
        icono: Icons.insights_outlined,
        titulo: titulo,
        descripcion:
            'Aparecerán cuando registres ventas, compras o gastos. Prueba con '
            'un período más largo.',
      ),
    );
  }
}

Widget _errorSeccion(
  String mensaje,
  Object error,
  StackTrace stackTrace,
  VoidCallback reintentar,
) => Card(
  child: ErrorState(
    compacto: true,
    mensaje: mensaje,
    error: error,
    stackTrace: stackTrace,
    onReintentar: reintentar,
  ),
);

/// Etiqueta corta "ene", "feb"... para los ejes de las gráficas.
String _etiquetaMes(DateTime mes) =>
    DateFormat('MMM', 'es').format(mes).replaceAll('.', '');

/// "enero 2026" para la tabla de detalle.
String _nombreMes(DateTime mes) => DateFormat('MMMM yyyy', 'es').format(mes);

// ---------------------------------------------------------------------------
// Período
// ---------------------------------------------------------------------------

class _RangoSelector extends ConsumerWidget {
  const _RangoSelector();

  String _etiqueta(RangoAnalisis rango) => switch (rango) {
    RangoAnalisis.mes => 'Este mes',
    RangoAnalisis.trimestre => 'Últimos 3 meses',
    RangoAnalisis.anio => 'Últimos 12 meses',
    RangoAnalisis.todo => 'Todo',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rango = ref.watch(rangoAnalisisProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Período', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final opcion in RangoAnalisis.values)
              ChoiceChip(
                label: Text(_etiqueta(opcion)),
                selected: opcion == rango,
                onSelected: (_) => ref
                    .read(rangoAnalisisProvider.notifier)
                    .seleccionar(opcion),
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Resumen
// ---------------------------------------------------------------------------

class _ResumenCards extends ConsumerWidget {
  const _ResumenCards();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = ref.watch(resumenFinancieroProvider);
    return resumen.when(
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudo cargar el resumen.',
        error,
        stackTrace,
        () => ref.invalidate(resumenFinancieroProvider),
      ),
      data: (r) {
        final tarjetas = [
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
        ];
        // Dos columnas, alto según el contenido (con texto grande las
        // tarjetas crecen en vez de desbordarse).
        return LayoutBuilder(
          builder: (context, c) {
            final ancho = (c.maxWidth - AppSpacing.sm) / 2;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final t in tarjetas) SizedBox(width: ancho, child: t),
              ],
            );
          },
        );
      },
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
      margin: EdgeInsets.zero,
      color: destacado ? scheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            MoneyText(
              valor,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Comparativa
// ---------------------------------------------------------------------------

class _ComparativaCard extends ConsumerWidget {
  const _ComparativaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparativa = ref.watch(comparativaMensualProvider);
    return comparativa.when(
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudo cargar la comparativa.',
        error,
        stackTrace,
        () => ref.invalidate(comparativaMensualProvider),
      ),
      data: (c) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
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
              const Divider(height: AppSpacing.md),
              _ComparativaFila(
                etiqueta: 'Gastos',
                actual: c.gastosActual,
                anterior: c.gastosAnterior,
                variacion: c.variacionGastos,
              ),
              const Divider(height: AppSpacing.md),
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
    final textTheme = Theme.of(context).textTheme;
    final positivo = (variacion ?? 0) >= 0;
    final color = positivo ? context.appColors.exito : scheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(etiqueta, style: textTheme.titleSmall)),
            if (variacion != null)
              // Flecha + signo + porcentaje: no solo color.
              EtiquetaEstado(
                icono: positivo ? Icons.arrow_upward : Icons.arrow_downward,
                texto:
                    '${positivo ? '+' : ''}${variacion!.toStringAsFixed(1)}%',
                color: color,
              )
            else
              Text('Sin comparación', style: textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Flexible(child: MoneyText(anterior, style: textTheme.bodyMedium)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(Icons.arrow_forward, size: 16),
            ),
            Flexible(
              child: MoneyText(
                actual,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gráficas mensuales
// ---------------------------------------------------------------------------

/// Leyenda con TEXTO: muestra una muestra del trazo (continuo o punteado) y
/// el nombre de la serie.
class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.items});

  final List<({String texto, Color color, bool punteado})> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 10,
                child: CustomPaint(
                  painter: _MuestraTrazo(item.color, item.punteado),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(item.texto, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
      ],
    );
  }
}

class _MuestraTrazo extends CustomPainter {
  _MuestraTrazo(this.color, this.punteado);

  final Color color;
  final bool punteado;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!punteado) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    for (var x = 0.0; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, y), Offset(x + 5, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MuestraTrazo old) =>
      old.color != color || old.punteado != punteado;
}

FlTitlesData _titulosMeses(List<PuntoMensual> puntos) => FlTitlesData(
  topTitles: const AxisTitles(),
  rightTitles: const AxisTitles(),
  bottomTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 32,
      getTitlesWidget: (value, meta) {
        final i = value.toInt();
        if (i < 0 || i >= puntos.length) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(_etiquetaMes(puntos[i].mes)),
        );
      },
    ),
  ),
  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
);

class _VentasGastosChart extends ConsumerWidget {
  const _VentasGastosChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serie = ref.watch(serieMensualProvider);
    final scheme = Theme.of(context).colorScheme;
    return serie.when(
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudo cargar la serie mensual.',
        error,
        stackTrace,
        () => ref.invalidate(serieMensualProvider),
      ),
      data: (puntos) {
        if (puntos.isEmpty) return const _SinDatos();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Leyenda(
              items: [
                (texto: 'Ventas', color: scheme.primary, punteado: false),
                (texto: 'Gastos', color: scheme.error, punteado: true),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  titlesData: _titulosMeses(puntos),
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      color: scheme.primary,
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (var i = 0; i < puntos.length; i++)
                          FlSpot(i.toDouble(), puntos[i].ventas.cents / 100),
                      ],
                    ),
                    LineChartBarData(
                      color: scheme.error,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                      spots: [
                        for (var i = 0; i < puntos.length; i++)
                          FlSpot(i.toDouble(), puntos[i].gastos.cents / 100),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudo cargar la ganancia mensual.',
        error,
        stackTrace,
        () => ref.invalidate(serieMensualProvider),
      ),
      data: (puntos) {
        if (puntos.isEmpty) return const _SinDatos();
        final hayPerdidas = puntos.any((p) => p.ganancia.isNegative);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hayPerdidas
                  ? 'Barras rojas: meses con pérdida. Las cifras están en '
                        '"Detalle por mes".'
                  : 'Ganancia neta de cada mes. Las cifras están en '
                        '"Detalle por mes".',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  titlesData: _titulosMeses(puntos),
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
            ),
          ],
        );
      },
    );
  }
}

/// Las mismas cifras de las gráficas, en texto: mes por mes con montos
/// completos (un monto en una barra no se puede leer con precisión).
class _DetalleMensual extends ConsumerWidget {
  const _DetalleMensual();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serie = ref.watch(serieMensualProvider);
    return serie.when(
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudo cargar el detalle mensual.',
        error,
        stackTrace,
        () => ref.invalidate(serieMensualProvider),
      ),
      data: (puntos) {
        if (puntos.isEmpty) return const _SinDatos();
        // Más reciente primero.
        final ordenados = puntos.reversed.toList();
        return Column(
          children: [
            for (final p in ordenados)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _DetalleMes(punto: p),
              ),
          ],
        );
      },
    );
  }
}

class _DetalleMes extends StatelessWidget {
  const _DetalleMes({required this.punto});

  final PuntoMensual punto;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_nombreMes(punto.mes), style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                _DatoMonto('Ventas', punto.ventas),
                _DatoMonto('Gastos', punto.gastos),
                _DatoMonto('Ganancia', punto.ganancia, destacado: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatoMonto extends StatelessWidget {
  const _DatoMonto(this.etiqueta, this.monto, {this.destacado = false});

  final String etiqueta;
  final Money monto;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: textTheme.bodySmall),
          MoneyText(
            monto,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: destacado ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gastos por categoría
// ---------------------------------------------------------------------------

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
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudieron cargar los gastos por categoría.',
        error,
        stackTrace,
        () => ref.invalidate(gastosPorCategoriaProvider),
      ),
      data: (lista) {
        if (lista.isEmpty) return const _SinDatos();
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
            // Leyenda con nombre y monto de cada porción (el color solo
            // identifica; el dato está en el texto).
            for (var i = 0; i < lista.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: _colores[i % _colores.length],
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(lista[i].categoria)),
                    const SizedBox(width: AppSpacing.sm),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: MoneyText(
                        lista[i].total,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Rankings
// ---------------------------------------------------------------------------

/// Fila de un ranking: ícono, título, nombre y valor (que puede ser un
/// monto o un texto); crece con el texto en vez de desbordarse.
class _FilaRanking extends StatelessWidget {
  const _FilaRanking({
    required this.icono,
    required this.titulo,
    required this.nombre,
    required this.valor,
  });

  final IconData icono;
  final String titulo;
  final String nombre;
  final Widget valor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icono, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: textTheme.bodyLarge),
                Text(
                  nombre,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: valor,
          ),
        ],
      ),
    );
  }
}

class _RankingProductos extends ConsumerWidget {
  const _RankingProductos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(rankingProductosProvider);
    final negrita = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return productos.when(
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudo cargar el ranking de productos.',
        error,
        stackTrace,
        () => ref.invalidate(rankingProductosProvider),
      ),
      data: (lista) {
        if (lista.isEmpty) {
          return const _SinDatos(titulo: 'Aún no hay productos vendidos');
        }
        final porUnidades = [...lista]
          ..sort((a, b) => b.unidades.compareTo(a.unidades));
        final porGanancia = [...lista]
          ..sort((a, b) => b.ganancia.compareTo(a.ganancia));
        final masVendido = porUnidades.first;
        final menosVendido = porUnidades.last;
        final masRentable = porGanancia.first;
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _FilaRanking(
                icono: Icons.trending_up,
                titulo: 'Más vendido',
                nombre: masVendido.nombre,
                valor: Text(
                  formatoCantidad(masVendido.unidades),
                  textAlign: TextAlign.right,
                  style: negrita,
                ),
              ),
              _FilaRanking(
                icono: Icons.trending_down,
                titulo: 'Menos vendido',
                nombre: menosVendido.nombre,
                valor: Text(
                  formatoCantidad(menosVendido.unidades),
                  textAlign: TextAlign.right,
                  style: negrita,
                ),
              ),
              _FilaRanking(
                icono: Icons.savings_outlined,
                titulo: 'Más rentable',
                nombre: masRentable.nombre,
                valor: MoneyText(
                  masRentable.ganancia,
                  textAlign: TextAlign.right,
                  style: negrita,
                ),
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
    final negrita = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return empleados.when(
      loading: () => const _CargandoSeccion(),
      error: (error, stackTrace) => _errorSeccion(
        'No se pudo cargar el ranking de empleados.',
        error,
        stackTrace,
        () => ref.invalidate(rankingEmpleadosProvider),
      ),
      data: (lista) {
        if (lista.isEmpty) {
          return const _SinDatos(titulo: 'Aún no hay empleados');
        }
        final masAntiguo = lista.first;
        final porPagos = [...lista]
          ..sort((a, b) => b.totalPagado.compareTo(a.totalPagado));
        final masPagado = porPagos.first;
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _FilaRanking(
                icono: Icons.badge_outlined,
                titulo: 'Mayor antigüedad',
                nombre: masAntiguo.nombre,
                valor: Text(
                  formatoFecha.format(masAntiguo.fechaIngreso.toLocal()),
                  textAlign: TextAlign.right,
                  style: negrita,
                ),
              ),
              _FilaRanking(
                icono: Icons.payments_outlined,
                titulo: 'Mayor total pagado',
                nombre: masPagado.nombre,
                valor: MoneyText(
                  masPagado.totalPagado,
                  textAlign: TextAlign.right,
                  style: negrita,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
