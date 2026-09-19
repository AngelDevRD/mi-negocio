import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/gasto.dart';
import '../categoria_gasto_icono.dart';
import '../providers/expenses_providers.dart';

/// Lista de gastos (RF-GAS-03) de un MES, con el total del mes arriba. Filtros:
/// el mes (flechas con nombre del mes) y la categoría (chips con texto).
class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastosProvider);
    final filtro = ref.watch(gastosFiltroProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(AppRoutes.gastosNuevo),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),
      body: Column(
        children: [
          const _GastosFiltroBar(),
          Expanded(
            child: gastosAsync.when(
              loading: () => const LoadingView(),
              error: (error, stackTrace) => ErrorState(
                mensaje: 'No se pudieron cargar los gastos.',
                error: error,
                stackTrace: stackTrace,
                onReintentar: () => ref.invalidate(gastosProvider),
              ),
              data: (gastos) {
                if (gastos.isEmpty) {
                  return filtro.categoria != null
                      ? EmptyState(
                          icono: Icons.filter_alt_off_outlined,
                          titulo: 'Sin resultados para este filtro',
                          descripcion:
                              'No hay gastos de ${filtro.categoria} en '
                              '${nombreDelMes(filtro.mes)}.',
                          accionLabel: 'Quitar filtro',
                          onAccion: () => ref
                              .read(gastosFiltroProvider.notifier)
                              .actualizar((f) => f.copyWith(categoria: null)),
                        )
                      : EmptyState(
                          icono: Icons.receipt_long_outlined,
                          titulo: 'Sin gastos en ${nombreDelMes(filtro.mes)}',
                          descripcion:
                              'Registra la luz, el agua, el alquiler y lo '
                              'demás que pagas para saber cuánto gasta tu '
                              'colmado.',
                          accionLabel: 'Nuevo gasto',
                          onAccion: () => context.push(AppRoutes.gastosNuevo),
                        );
                }
                final total = gastos.fold<Money>(
                  Money.zero,
                  (suma, gasto) => suma + gasto.monto,
                );
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl + 56,
                  ),
                  itemCount: gastos.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _TotalMes(total: total, cantidad: gastos.length),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _GastoTile(gasto: gastos[i - 1]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GastosFiltroBar extends ConsumerWidget {
  const _GastosFiltroBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(gastosFiltroProvider);
    final controlador = ref.read(gastosFiltroProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mes anterior',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => controlador.actualizar(
                  (f) => f.copyWith(mes: DateTime(f.mes.year, f.mes.month - 1)),
                ),
              ),
              Expanded(
                child: Text(
                  nombreDelMes(filtro.mes),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Mes siguiente',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => controlador.actualizar(
                  (f) => f.copyWith(mes: DateTime(f.mes.year, f.mes.month + 1)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  label: const Text('Todas'),
                  selected: filtro.categoria == null,
                  onSelected: (_) => controlador.actualizar(
                    (f) => f.copyWith(categoria: null),
                  ),
                ),
                for (final categoria in categoriasGastoPredefinidas)
                  ChoiceChip(
                    avatar: Icon(iconoCategoriaGasto(categoria), size: 18),
                    label: Text(categoria),
                    selected: filtro.categoria == categoria,
                    onSelected: (_) => controlador.actualizar(
                      (f) => f.copyWith(categoria: categoria),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalMes extends StatelessWidget {
  const _TotalMes({required this.total, required this.cantidad});

  final Money total;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                  Text('Total del mes', style: textTheme.labelLarge),
                  Text(
                    cantidad == 1 ? '1 gasto' : '$cantidad gastos',
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

class _GastoTile extends StatelessWidget {
  const _GastoTile({required this.gasto});

  final Gasto gasto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final estiloSecundario = textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Icon(
              iconoCategoriaGasto(gasto.categoria),
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gasto.concepto,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                  Text(
                    '${gasto.categoria} · '
                    '${DateFormat('dd/MM/yyyy').format(gasto.fecha.toLocal())}',
                    style: estiloSecundario,
                  ),
                  if (gasto.saleDeCaja)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.point_of_sale,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text('Salió de caja', style: estiloSecundario),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: MoneyText(
                gasto.monto,
                textAlign: TextAlign.right,
                style: textTheme.titleMedium?.copyWith(
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
