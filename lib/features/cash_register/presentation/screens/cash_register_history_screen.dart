import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/money_text.dart';
import '../providers/cash_register_providers.dart';

/// Historial de sesiones de caja cerradas (RF-CAJ) como pantalla propia
/// (`/caja/historial`). El contenido es [CashRegisterHistoryList], el mismo que
/// muestra la pestaña "Historial" de Caja.
class CashRegisterHistoryScreen extends StatelessWidget {
  const CashRegisterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de caja')),
      body: const CashRegisterHistoryList(),
    );
  }
}

/// Lista de cierres, con la diferencia de cada uno rotulada con texto
/// (Sin diferencia / Faltante / Sobrante), no solo con color.
class CashRegisterHistoryList extends ConsumerWidget {
  const CashRegisterHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialCajaProvider);
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return historialAsync.when(
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorState(
        mensaje: 'No se pudo cargar el historial.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () => ref.invalidate(historialCajaProvider),
      ),
      data: (sesiones) {
        if (sesiones.isEmpty) {
          return const EmptyState(
            icono: Icons.history,
            titulo: 'Aún no hay cierres de caja',
            descripcion:
                'Cuando cierres la caja, el resumen de cada turno aparecerá '
                'aquí.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: sesiones.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final sesion = sesiones[index];
            final diferencia = sesion.diferencia ?? Money.zero;
            final scheme = Theme.of(context).colorScheme;
            final color = diferencia.isZero
                ? scheme.onSurfaceVariant
                : (diferencia.isNegative ? scheme.error : scheme.tertiary);
            final etiqueta = diferencia.isZero
                ? 'Sin diferencia'
                : (diferencia.isNegative ? 'Faltante' : 'Sobrante');

            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(
                  sesion.fechaCierre != null
                      ? formatoFecha.format(sesion.fechaCierre!.toLocal())
                      : '—',
                ),
                subtitle: Text(
                  'Apertura: ${formatoFecha.format(sesion.fechaApertura.toLocal())} · '
                  'Cerrada por ${sesion.usuarioCierreNombre ?? '—'}',
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      etiqueta,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!diferencia.isZero)
                      MoneyText(
                        diferencia,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                  ],
                ),
                onTap: () =>
                    context.push('${AppRoutes.cajaHistorial}/${sesion.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
