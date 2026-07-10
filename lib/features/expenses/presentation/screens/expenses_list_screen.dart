import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../domain/entities/gasto.dart';
import '../providers/expenses_providers.dart';

/// Lista de gastos (RF-GAS-03): filtro por mes y categoría, con el total
/// del período.
class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastosAsync = ref.watch(gastosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.gastosNuevo),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),
      body: Column(
        children: [
          const _GastosFiltroBar(),
          Expanded(
            child: gastosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No se pudieron cargar los gastos.'),
              ),
              data: (gastos) {
                if (gastos.isEmpty) {
                  return const Center(
                    child: Text('No hay gastos registrados en este período.'),
                  );
                }
                final total = gastos.fold<Money>(
                  Money.zero,
                  (suma, gasto) => suma + gasto.monto,
                );
                return Column(
                  children: [
                    _TotalPeriodo(total: total),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.xl,
                        ),
                        itemCount: gastos.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) =>
                            _GastoTile(gasto: gastos[i]),
                      ),
                    ),
                  ],
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
    final formatoMes = DateFormat('MM/yyyy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Mes anterior',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref
                .read(gastosFiltroProvider.notifier)
                .actualizar(
                  (f) => f.copyWith(
                    mes: DateTime.utc(f.mes.year, f.mes.month - 1),
                  ),
                ),
          ),
          Expanded(
            child: Text(
              formatoMes.format(filtro.mes),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Mes siguiente',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref
                .read(gastosFiltroProvider.notifier)
                .actualizar(
                  (f) => f.copyWith(
                    mes: DateTime.utc(f.mes.year, f.mes.month + 1),
                  ),
                ),
          ),
          const SizedBox(width: AppSpacing.sm),
          DropdownButton<String?>(
            value: filtro.categoria,
            hint: const Text('Categoría'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              for (final categoria in categoriasGastoPredefinidas)
                DropdownMenuItem(value: categoria, child: Text(categoria)),
            ],
            onChanged: (valor) => ref
                .read(gastosFiltroProvider.notifier)
                .actualizar((f) => f.copyWith(categoria: valor)),
          ),
        ],
      ),
    );
  }
}

class _TotalPeriodo extends StatelessWidget {
  const _TotalPeriodo({required this.total});

  final Money total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        color: scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total del período',
                style: TextStyle(color: scheme.onSecondaryContainer),
              ),
              Text(
                total.format(),
                style: TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
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
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            Icons.receipt_long_outlined,
            color: scheme.onPrimaryContainer,
          ),
        ),
        title: Text(gasto.concepto),
        subtitle: Text(
          '${gasto.categoria} · ${formatoFecha.format(gasto.fecha.toLocal())}'
          '${gasto.saleDeCaja ? ' · Salió de caja' : ''}',
        ),
        trailing: Text(
          gasto.monto.format(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
