import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../providers/cash_register_providers.dart';

/// Historial de sesiones de caja cerradas (RF-CAJ), con sus diferencias
/// resaltadas (sobrante/faltante).
class CashRegisterHistoryScreen extends ConsumerWidget {
  const CashRegisterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historialAsync = ref.watch(historialCajaProvider);
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de caja')),
      body: historialAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar el historial.')),
        data: (sesiones) {
          if (sesiones.isEmpty) {
            return const Center(child: Text('Aún no hay cierres de caja.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sesiones.length,
            itemBuilder: (context, index) {
              final sesion = sesiones[index];
              final diferencia = sesion.diferencia ?? Money.zero;
              final scheme = Theme.of(context).colorScheme;
              final colorDiferencia = diferencia.isZero
                  ? scheme.onSurface
                  : (diferencia.isNegative ? scheme.error : scheme.tertiary);

              return Card(
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
                  trailing: Text(
                    diferencia.format(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorDiferencia,
                    ),
                  ),
                  onTap: () =>
                      context.push('${AppRoutes.cajaHistorial}/${sesion.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
