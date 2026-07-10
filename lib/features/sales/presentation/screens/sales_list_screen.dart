import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/venta.dart';
import '../providers/sales_providers.dart';

/// Lista de ventas (RF-VEN): filtro por estado y rango de fechas, más
/// reciente primero. El FAB ofrece iniciar una venta rápida o detallada.
class SalesListScreen extends ConsumerWidget {
  const SalesListScreen({super.key});

  Future<void> _nuevaVenta(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Venta rápida'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.ventaRapida);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Venta detallada'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.ventaDetallada);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventasAsync = ref.watch(ventasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _nuevaVenta(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva venta'),
      ),
      body: Column(
        children: [
          const _VentasFiltroBar(),
          Expanded(
            child: ventasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No se pudieron cargar las ventas.'),
              ),
              data: (ventas) {
                if (ventas.isEmpty) {
                  return const Center(
                    child: Text('No hay ventas registradas.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  itemCount: ventas.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _VentaTile(venta: ventas[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VentasFiltroBar extends ConsumerWidget {
  const _VentasFiltroBar();

  Future<void> _elegirRango(BuildContext context, WidgetRef ref) async {
    final filtro = ref.read(ventasFiltroProvider);
    final ahora = DateTime.now();
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(ahora.year - 5),
      lastDate: ahora,
      initialDateRange: filtro.desde != null && filtro.hasta != null
          ? DateTimeRange(start: filtro.desde!, end: filtro.hasta!)
          : null,
    );
    if (rango == null) return;
    ref
        .read(ventasFiltroProvider.notifier)
        .actualizar(
          (f) => f.copyWith(
            desde: rango.start,
            hasta: DateTime(
              rango.end.year,
              rango.end.month,
              rango.end.day,
              23,
              59,
              59,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(ventasFiltroProvider);
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<EstadoVenta?>(
              initialValue: filtro.estado,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todas')),
                DropdownMenuItem(
                  value: EstadoVenta.completada,
                  child: Text('Completadas'),
                ),
                DropdownMenuItem(
                  value: EstadoVenta.anulada,
                  child: Text('Anuladas'),
                ),
              ],
              onChanged: (valor) => ref
                  .read(ventasFiltroProvider.notifier)
                  .actualizar((f) => f.copyWith(estado: valor)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (filtro.desde != null && filtro.hasta != null)
            InputChip(
              label: Text(
                '${formatoFecha.format(filtro.desde!)} - '
                '${formatoFecha.format(filtro.hasta!)}',
              ),
              onDeleted: () => ref
                  .read(ventasFiltroProvider.notifier)
                  .actualizar((f) => f.copyWith(desde: null, hasta: null)),
            )
          else
            IconButton(
              tooltip: 'Filtrar por fecha',
              icon: const Icon(Icons.date_range_outlined),
              onPressed: () => _elegirRango(context, ref),
            ),
        ],
      ),
    );
  }
}

class _VentaTile extends StatelessWidget {
  const _VentaTile({required this.venta});

  final Venta venta;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    final anulada = venta.estado == EstadoVenta.anulada;

    return Card(
      child: ListTile(
        onTap: () => context.push('/ventas/${venta.id}'),
        leading: CircleAvatar(
          backgroundColor: anulada
              ? scheme.errorContainer
              : scheme.primaryContainer,
          child: Icon(
            venta.tipo == TipoVenta.rapida
                ? Icons.point_of_sale
                : Icons.receipt_long_outlined,
            color: anulada
                ? scheme.onErrorContainer
                : scheme.onPrimaryContainer,
          ),
        ),
        title: Text(formatoFecha.format(venta.fecha.toLocal())),
        subtitle: Text('${venta.usuarioNombre}${anulada ? ' · ANULADA' : ''}'),
        trailing: Text(
          venta.total.format(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
