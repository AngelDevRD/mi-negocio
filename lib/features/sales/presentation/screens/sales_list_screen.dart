import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/rango_fecha.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/venta.dart';
import '../metodo_pago_texto.dart';
import '../providers/sales_providers.dart';

/// Historial de ventas (RF-VEN), más reciente primero y AGRUPADO POR DÍA, cada
/// día con su total (solo ventas completadas). Filtros con texto: estado
/// (Todas / Completadas / Anuladas) y período (Hoy / Esta semana / Este mes /
/// Personalizado). El FAB abre directamente el punto de venta.
///
/// El método de pago sale en cada fila (ícono + texto): viene en la misma
/// consulta de la lista, sin una consulta por venta.
class SalesListScreen extends ConsumerWidget {
  const SalesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventasAsync = ref.watch(ventasProvider);
    final filtro = ref.watch(ventasFiltroProvider);
    final usuarioActual = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.nombre,
      _ => null,
    };
    final sinVentas = ventasAsync.maybeWhen(
      data: (v) => v.isEmpty && !filtro.activo,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      // Con la lista vacía la acción principal es la del estado vacío: el FAB
      // se oculta para no duplicarla.
      floatingActionButton: sinVentas
          ? null
          : FloatingActionButton.extended(
              // Sin Hero: las pestañas del shell siguen montadas y sus FAB
              // compartirían la etiqueta por defecto al abrir una ruta encima.
              heroTag: null,
              onPressed: () => context.push(AppRoutes.ventaRapida),
              icon: const Icon(Icons.add),
              label: const Text('Nueva venta'),
            ),
      body: Column(
        children: [
          const _VentasFiltroBar(),
          Expanded(
            child: ventasAsync.when(
              loading: () => const LoadingView(),
              error: (error, stackTrace) => ErrorState(
                mensaje: 'No se pudieron cargar las ventas.',
                error: error,
                stackTrace: stackTrace,
                onReintentar: () => ref.invalidate(ventasProvider),
              ),
              data: (ventas) {
                if (ventas.isEmpty) {
                  return filtro.activo
                      ? EmptyState(
                          icono: Icons.filter_alt_off_outlined,
                          titulo: 'Sin resultados para este filtro',
                          descripcion:
                              'No hay ventas con ese estado en ese período.',
                          accionLabel: 'Quitar filtros',
                          onAccion: () => ref
                              .read(ventasFiltroProvider.notifier)
                              .actualizar((_) => const VentasFiltro()),
                        )
                      : EmptyState(
                          icono: Icons.receipt_long_outlined,
                          titulo: 'Aún no hay ventas',
                          descripcion:
                              'Cuando cobres tu primera venta aparecerá aquí, '
                              'con su hora y su total.',
                          accionLabel: 'Nueva venta',
                          onAccion: () => context.push(AppRoutes.ventaRapida),
                        );
                }
                return _ListaVentas(
                  ventas: ventas,
                  usuarioActual: usuarioActual,
                  // Con "Anuladas" el total vendido no aplica (sería cero).
                  mostrarTotales: filtro.estado != EstadoVenta.anulada,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Money _totalCompletadas(Iterable<Venta> ventas) => ventas
    .where((v) => v.estado == EstadoVenta.completada)
    .fold(Money.zero, (suma, v) => suma + v.total);

class _ListaVentas extends StatelessWidget {
  const _ListaVentas({
    required this.ventas,
    required this.usuarioActual,
    required this.mostrarTotales,
  });

  final List<Venta> ventas;
  final String? usuarioActual;
  final bool mostrarTotales;

  @override
  Widget build(BuildContext context) {
    final grupos = agruparPorDia(ventas, (v) => v.fecha, DateTime.now());
    final completadas = ventas
        .where((v) => v.estado == EstadoVenta.completada)
        .length;

    // Lista plana (resumen, encabezados y filas) para construir de forma
    // perezosa con ListView.builder.
    final filas = <Widget>[
      if (mostrarTotales)
        _ResumenVentas(cantidad: completadas, total: _totalCompletadas(ventas)),
      for (final grupo in grupos) ...[
        if (mostrarTotales)
          EncabezadoDia(
            titulo: grupo.etiqueta,
            total: _totalCompletadas(grupo.elementos),
          )
        else
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              grupo.etiqueta,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        for (final venta in grupo.elementos)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _VentaTile(venta: venta, usuarioActual: usuarioActual),
          ),
      ],
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl + 56,
      ),
      itemCount: filas.length,
      itemBuilder: (context, i) => filas[i],
    );
  }
}

/// Total vendido del período filtrado (ventas completadas).
class _ResumenVentas extends StatelessWidget {
  const _ResumenVentas({required this.cantidad, required this.total});

  final int cantidad;
  final Money total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total vendido', style: textTheme.labelLarge),
                  Text(
                    cantidad == 1
                        ? '1 venta completada'
                        : '$cantidad ventas completadas',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: MoneyText(
                total,
                textAlign: TextAlign.right,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VentasFiltroBar extends ConsumerWidget {
  const _VentasFiltroBar();

  Future<void> _elegirRango(
    BuildContext context,
    WidgetRef ref,
    RangoFecha rango,
  ) async {
    final controlador = ref.read(ventasFiltroProvider.notifier);
    if (rango != RangoFecha.personalizado) {
      controlador.actualizar(
        (f) => f.copyWith(rango: rango, desde: null, hasta: null),
      );
      return;
    }
    final filtro = ref.read(ventasFiltroProvider);
    final elegido = await elegirRangoDeFechas(
      context,
      desde: filtro.desde,
      hasta: filtro.hasta,
    );
    if (elegido == null) return;
    final limites = limitesDeDias(elegido.start, elegido.end);
    controlador.actualizar(
      (f) => f.copyWith(
        rango: RangoFecha.personalizado,
        desde: limites.desde,
        hasta: limites.hasta,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(ventasFiltroProvider);
    final controlador = ref.read(ventasFiltroProvider.notifier);
    final formatoDia = DateFormat('dd/MM');

    Widget chipEstado(String etiqueta, EstadoVenta? estado) => ChoiceChip(
      label: Text(etiqueta),
      selected: filtro.estado == estado,
      onSelected: (_) =>
          controlador.actualizar((f) => f.copyWith(estado: estado)),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      // Ancho completo: en pantallas anchas la Column del padre centraría el Wrap.
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            chipEstado('Todas', null),
            chipEstado('Completadas', EstadoVenta.completada),
            chipEstado('Anuladas', EstadoVenta.anulada),
            FiltroFechaChip(
              rango: filtro.rango,
              textoPersonalizado: filtro.desde != null && filtro.hasta != null
                  ? '${formatoDia.format(filtro.desde!.toLocal())} - '
                        '${formatoDia.format(filtro.hasta!.toLocal())}'
                  : null,
              onElegir: (rango) => _elegirRango(context, ref, rango),
            ),
          ],
        ),
      ),
    );
  }
}

class _VentaTile extends StatelessWidget {
  const _VentaTile({required this.venta, required this.usuarioActual});

  final Venta venta;
  final String? usuarioActual;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final anulada = venta.estado == EstadoVenta.anulada;
    final rapida = venta.tipo == TipoVenta.rapida;
    final nota = venta.nota?.trim();
    // El vendedor solo se nombra si NO es quien mira la lista: si todas las
    // filas dicen lo mismo es ruido; si vendió otra persona, es información.
    final vendedor = venta.usuarioNombre != usuarioActual
        ? venta.usuarioNombre
        : null;
    // Método de pago (viene en la misma consulta de la lista): ícono + texto.
    final ({String etiqueta, IconData icono})? metodo = venta.pagoMixto
        ? (etiqueta: 'Mixto', icono: Icons.shuffle)
        : (venta.metodoPago == null
              ? null
              : (
                  etiqueta: venta.metodoPago!.etiqueta,
                  icono: venta.metodoPago!.icono,
                ));
    final detalle = [
      if (vendedor != null) 'Vendió $vendedor',
      if (nota != null && nota.isNotEmpty) nota,
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.push('/ventas/${venta.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                rapida ? Icons.point_of_sale : Icons.receipt_long_outlined,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('HH:mm').format(venta.fecha.toLocal())}'
                      ' · ${rapida ? 'Venta rápida' : 'Venta detallada'}',
                      style: textTheme.titleSmall,
                    ),
                    if (metodo != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            metodo.icono,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              metodo.etiqueta,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (detalle.isNotEmpty)
                      Text(
                        detalle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: MoneyText(
                      venta.total,
                      textAlign: TextAlign.right,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: anulada ? scheme.onSurfaceVariant : null,
                        decoration: anulada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (anulada) const EtiquetaAnulada(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
