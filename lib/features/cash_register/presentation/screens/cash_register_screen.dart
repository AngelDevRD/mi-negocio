import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../sales/presentation/widgets/abrir_caja_dialog.dart';
import '../../domain/entities/caja_sesion.dart';
import '../providers/cash_register_providers.dart';
import '../widgets/movimiento_caja_dialog.dart';
import '../widgets/movimiento_caja_tile.dart';
import 'cash_register_history_screen.dart';

/// Pestaña Caja (RF-CAJ). Dos pestañas con TEXTO dentro: "Hoy" (la sesión
/// abierta, sus acciones y sus movimientos) e "Historial" (los cierres).
///
/// Pestañas en vez de un ícono de reloj en la barra: un ícono sin texto no dice
/// que ahí están los cierres anteriores, y es el mismo contenido de Caja (no un
/// módulo aparte), así que una segunda pestaña queda a un toque. `/caja/historial`
/// sigue existiendo como pantalla propia.
class CashRegisterScreen extends StatelessWidget {
  const CashRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Caja'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hoy'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_CajaHoy(), CashRegisterHistoryList()],
        ),
      ),
    );
  }
}

class _CajaHoy extends ConsumerWidget {
  const _CajaHoy();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesionAsync = ref.watch(sesionActualProvider);
    final esAdmin = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };

    return sesionAsync.when(
      loading: () => const LoadingView(),
      error: (error, stackTrace) => ErrorState(
        mensaje: 'No se pudo cargar el estado de caja.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () => ref.invalidate(sesionActualProvider),
      ),
      data: (sesion) {
        if (sesion == null) {
          return EmptyState(
            icono: Icons.lock_outline,
            titulo: 'La caja está cerrada',
            descripcion:
                'Ábrela para registrar ventas y movimientos de '
                'efectivo.',
            accionLabel: 'Abrir caja',
            accionPrimaria: true,
            // El mismo flujo de apertura del POS (RN-01), sin duplicarlo.
            onAccion: () => mostrarDialogoAbrirCaja(context),
          );
        }
        return _SesionAbierta(sesion: sesion, esAdmin: esAdmin);
      },
    );
  }
}

class _SesionAbierta extends StatelessWidget {
  const _SesionAbierta({required this.sesion, required this.esAdmin});

  final CajaSesion sesion;
  final bool esAdmin;

  Future<void> _registrar(BuildContext context, {required bool entrada}) async {
    final registrado = await mostrarDialogoMovimientoCaja(
      context,
      entrada: entrada,
      efectivoEnCaja: sesion.montoActual,
    );
    if (registrado == true && context.mounted) {
      AppSnackbar.exito(
        context,
        entrada ? 'Entrada registrada.' : 'Salida registrada.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _TarjetaCaja(sesion: sesion),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => _registrar(context, entrada: true),
                icon: const Icon(Icons.add),
                label: const Text('Entrada'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => _registrar(context, entrada: false),
                icon: const Icon(Icons.remove),
                label: const Text('Salida'),
              ),
            ),
          ],
        ),
        if (esAdmin) ...[
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => context.push(AppRoutes.cajaCerrar),
            icon: const Icon(Icons.lock_outline),
            label: const Text('Cerrar caja'),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Movimientos del día', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (sesion.movimientos.isEmpty)
          const EmptyState(
            compacto: true,
            icono: Icons.receipt_long_outlined,
            titulo: 'Aún no hay movimientos en esta sesión',
          )
        else
          MovimientosCajaCard(movimientos: sesion.movimientos),
      ],
    );
  }
}

/// Estado de la caja: fondo neutro; el acento va solo en la etiqueta "Caja
/// abierta" (con ícono y texto), no en toda la tarjeta.
class _TarjetaCaja extends StatelessWidget {
  const _TarjetaCaja({required this.sesion});

  final CajaSesion sesion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final exito = context.appColors.exito;
    final apertura = sesion.fechaApertura.toLocal();

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open_outlined, size: 18, color: exito),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Caja abierta',
                  style: textTheme.labelLarge?.copyWith(
                    color: exito,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Efectivo en caja',
              style: textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            MoneyText(
              sesion.montoActual,
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(
                  'Apertura ',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                MoneyText(sesion.montoApertura, style: textTheme.bodyMedium),
                Flexible(
                  child: Text(
                    ' · ${_hora(apertura)}',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Abierta por ${sesion.usuarioAperturaNombre}',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hora local; con el día si el turno viene de otro día.
  String _hora(DateTime apertura) {
    final ahora = DateTime.now();
    final esHoy =
        apertura.year == ahora.year &&
        apertura.month == ahora.month &&
        apertura.day == ahora.day;
    return esHoy
        ? DateFormat('HH:mm').format(apertura)
        : DateFormat('dd/MM/yyyy HH:mm').format(apertura);
  }
}
