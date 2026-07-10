import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../sales/presentation/widgets/abrir_caja_dialog.dart';
import '../../domain/entities/caja_sesion.dart';
import '../providers/cash_register_providers.dart';

/// Pantalla de caja (RF-CAJ): estado de la sesión actual con sus movimientos
/// en vivo, acceso al cierre (solo Administrador) y al historial.
class CashRegisterScreen extends ConsumerWidget {
  const CashRegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesionAsync = ref.watch(sesionActualProvider);
    final usuario = ref.watch(authControllerProvider).value;
    final esAdmin = switch (usuario) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caja'),
        actions: [
          IconButton(
            tooltip: 'Historial de cierres',
            icon: const Icon(Icons.history),
            onPressed: () => context.push(AppRoutes.cajaHistorial),
          ),
        ],
      ),
      body: sesionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar el estado de caja.')),
        data: (sesion) {
          if (sesion == null) {
            return CajaCerradaView(
              onAbrir: () => mostrarDialogoAbrirCaja(context),
            );
          }
          return _SesionAbiertaView(sesion: sesion, esAdmin: esAdmin);
        },
      ),
    );
  }
}

class _SesionAbiertaView extends StatelessWidget {
  const _SesionAbiertaView({required this.sesion, required this.esAdmin});

  final CajaSesion sesion;
  final bool esAdmin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.point_of_sale_outlined,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Caja abierta',
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  sesion.montoActual.format(),
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Apertura: ${sesion.montoApertura.format()} · '
                  '${formatoFecha.format(sesion.fechaApertura.toLocal())}',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
                Text(
                  'Abierta por ${sesion.usuarioAperturaNombre}',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
        if (esAdmin) ...[
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.cajaCerrar),
            icon: const Icon(Icons.lock_outline),
            label: const Text('Cerrar caja'),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Movimientos del día',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (sesion.movimientos.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_outlined, color: scheme.outline),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text('Aún no hay movimientos en esta sesión.'),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: [
                for (final movimiento in sesion.movimientos)
                  ListTile(
                    leading: Icon(_iconoMovimiento(movimiento.tipo)),
                    title: Text(_tituloMovimiento(movimiento.tipo)),
                    subtitle: Text(
                      formatoFecha.format(movimiento.fecha.toLocal()),
                    ),
                    trailing: Text(
                      movimiento.monto.format(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: movimiento.monto.isNegative
                            ? scheme.error
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _iconoMovimiento(TipoCajaMovimiento tipo) => switch (tipo) {
    TipoCajaMovimiento.venta => Icons.point_of_sale,
    TipoCajaMovimiento.gasto => Icons.receipt_long_outlined,
    TipoCajaMovimiento.compra => Icons.shopping_cart_outlined,
    TipoCajaMovimiento.pagoEmpleado => Icons.people_outline,
    TipoCajaMovimiento.entradaManual => Icons.add_circle_outline,
    TipoCajaMovimiento.salidaManual => Icons.remove_circle_outline,
    TipoCajaMovimiento.retiroCierre => Icons.lock_outline,
  };

  String _tituloMovimiento(TipoCajaMovimiento tipo) => switch (tipo) {
    TipoCajaMovimiento.venta => 'Venta',
    TipoCajaMovimiento.gasto => 'Gasto',
    TipoCajaMovimiento.compra => 'Compra',
    TipoCajaMovimiento.pagoEmpleado => 'Pago a empleado',
    TipoCajaMovimiento.entradaManual => 'Entrada manual',
    TipoCajaMovimiento.salidaManual => 'Salida manual',
    TipoCajaMovimiento.retiroCierre => 'Retiro de cierre',
  };
}
