import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/compra.dart';
import '../providers/purchases_providers.dart';

/// Lista de compras (RF-COM): filtro por proveedor y rango de fechas, más
/// reciente primero.
class PurchasesListScreen extends ConsumerWidget {
  const PurchasesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comprasAsync = ref.watch(comprasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.comprasNueva),
        icon: const Icon(Icons.add),
        label: const Text('Nueva compra'),
      ),
      body: Column(
        children: [
          const _ComprasFiltroBar(),
          Expanded(
            child: comprasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No se pudieron cargar las compras.'),
              ),
              data: (compras) {
                if (compras.isEmpty) {
                  return const Center(
                    child: Text('No hay compras registradas.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  itemCount: compras.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _CompraTile(compra: compras[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComprasFiltroBar extends ConsumerWidget {
  const _ComprasFiltroBar();

  Future<void> _elegirRango(BuildContext context, WidgetRef ref) async {
    final filtro = ref.read(comprasFiltroProvider);
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
        .read(comprasFiltroProvider.notifier)
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
    final filtro = ref.watch(comprasFiltroProvider);
    final proveedoresAsync = ref.watch(proveedoresProvider);
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
            child: proveedoresAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (proveedores) => DropdownButtonFormField<String?>(
                initialValue: filtro.proveedorId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Proveedor'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todos los proveedores'),
                  ),
                  for (final proveedor in proveedores)
                    DropdownMenuItem(
                      value: proveedor.id,
                      child: Text(proveedor.nombre),
                    ),
                ],
                onChanged: (valor) => ref
                    .read(comprasFiltroProvider.notifier)
                    .actualizar((f) => f.copyWith(proveedorId: valor)),
              ),
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
                  .read(comprasFiltroProvider.notifier)
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

class _CompraTile extends StatelessWidget {
  const _CompraTile({required this.compra});

  final Compra compra;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    final anulada = compra.estado == EstadoCompra.anulada;

    return Card(
      child: ListTile(
        onTap: () => context.push('/compras/${compra.id}'),
        leading: CircleAvatar(
          backgroundColor: anulada
              ? scheme.errorContainer
              : scheme.primaryContainer,
          child: Icon(
            Icons.shopping_cart_outlined,
            color: anulada
                ? scheme.onErrorContainer
                : scheme.onPrimaryContainer,
          ),
        ),
        title: Text(compra.proveedorNombre ?? 'Sin proveedor'),
        subtitle: Text(
          '${formatoFecha.format(compra.fecha.toLocal())}'
          '${compra.numeroFactura != null ? ' · Factura ${compra.numeroFactura}' : ''}'
          '${anulada ? ' · ANULADA' : ''}',
        ),
        trailing: Text(
          compra.total.format(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
