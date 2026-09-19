import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_states.dart';
import '../providers/cash_register_providers.dart';
import '../widgets/movimiento_caja_tile.dart';
import '../widgets/resumen_turno_view.dart';

/// Detalle de una sesión de caja (abierta o cerrada): apertura, cierre,
/// montos esperado/contado/diferencia, resumen del turno por método de pago y
/// movimientos del día.
class CashRegisterSessionDetailScreen extends ConsumerWidget {
  const CashRegisterSessionDetailScreen({super.key, required this.sesionId});

  final String sesionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesionAsync = ref.watch(sesionCajaProvider(sesionId));
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cierre')),
      body: sesionAsync.when(
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorState(
          mensaje: 'No se pudo cargar la sesión.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () => ref.invalidate(sesionCajaProvider(sesionId)),
        ),
        data: (sesion) {
          if (sesion == null) {
            return const EmptyState(
              icono: Icons.lock_outline,
              titulo: 'Sesión no encontrada',
            );
          }
          final scheme = Theme.of(context).colorScheme;
          final diferencia = sesion.diferencia;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _DetalleFila(
                etiqueta: 'Apertura',
                valor:
                    '${sesion.montoApertura.format()} · '
                    '${formatoFecha.format(sesion.fechaApertura.toLocal())} · '
                    '${sesion.usuarioAperturaNombre}',
              ),
              if (sesion.fechaCierre != null)
                _DetalleFila(
                  etiqueta: 'Cierre',
                  valor:
                      '${formatoFecha.format(sesion.fechaCierre!.toLocal())} · '
                      '${sesion.usuarioCierreNombre ?? '—'}',
                ),
              if (sesion.montoEsperado != null)
                _DetalleFila(
                  etiqueta: 'Esperado',
                  valor: sesion.montoEsperado!.format(),
                ),
              if (sesion.montoContado != null)
                _DetalleFila(
                  etiqueta: 'Contado',
                  valor: sesion.montoContado!.format(),
                ),
              if (diferencia != null)
                _DetalleFila(
                  etiqueta: 'Diferencia',
                  valor:
                      '${diferencia.format()} · '
                      '${diferencia.isZero ? 'Sin diferencia' : (diferencia.isNegative ? 'Faltante' : 'Sobrante')}',
                  color: diferencia.isZero
                      ? null
                      : (diferencia.isNegative
                            ? scheme.error
                            : scheme.tertiary),
                ),
              if (sesion.montoDejadoSiguiente != null)
                _DetalleFila(
                  etiqueta: 'Dejado para mañana',
                  valor: sesion.montoDejadoSiguiente!.format(),
                ),
              const SizedBox(height: AppSpacing.md),
              ResumenTurnoSeccion(sesionId: sesion.id),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Movimientos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (sesion.movimientos.isEmpty)
                const EmptyState(
                  compacto: true,
                  icono: Icons.receipt_long_outlined,
                  titulo: 'Esta sesión no tiene movimientos',
                )
              else
                MovimientosCajaCard(
                  movimientos: sesion.movimientos,
                  fechaCompleta: true,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DetalleFila extends StatelessWidget {
  const _DetalleFila({required this.etiqueta, required this.valor, this.color});

  final String etiqueta;
  final String valor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              etiqueta,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
