import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../metodo_pago_texto.dart';
import '../providers/sales_providers.dart';

/// Texto del diálogo de anulación según cómo se cobró la venta: solo lo cobrado
/// en efectivo tiene movimiento de caja que revertir.
String mensajeAnulacion(MetodoPago metodo) {
  const cierre =
      'La venta quedará marcada como anulada y no podrá deshacerse. '
      '¿Deseas continuar?';
  if (metodo == MetodoPago.efectivo) {
    return 'Esta acción revertirá el stock de los productos y el movimiento '
        'de caja asociado. $cierre';
  }
  if (metodo == MetodoPago.credito) {
    return 'Esta acción revertirá el stock de los productos y la deuda del '
        'cliente. Esta venta fue a crédito (fiado): no afecta el efectivo de '
        'la caja. $cierre';
  }
  return 'Esta acción revertirá el stock de los productos. Esta venta se '
      'cobró con ${metodo.etiqueta.toLowerCase()}: no afecta el efectivo de '
      'la caja. $cierre';
}

/// Detalle de una venta (RF-VEN): ítems, total, ganancia (solo admin) y
/// anulación (RF-VEN/RN-10, solo Administrador).
class SaleDetailScreen extends ConsumerStatefulWidget {
  const SaleDetailScreen({super.key, required this.ventaId});

  final String ventaId;

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  bool _guardando = false;

  Future<void> _anular(
    BuildContext context,
    WidgetRef ref,
    String usuarioId,
    MetodoPago metodo,
  ) async {
    final confirmar = await mostrarConfirmacion(
      context,
      titulo: 'Anular venta',
      mensaje: mensajeAnulacion(metodo),
      confirmarLabel: 'Anular',
      destructivo: true,
    );
    if (!confirmar) return;

    setState(() => _guardando = true);
    final resultado = await ref
        .read(salesRepositoryProvider)
        .anularVenta(widget.ventaId, usuarioId: usuarioId);
    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) => ref.invalidate(ventaProvider(widget.ventaId)),
      fail: (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(f.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ventaAsync = ref.watch(ventaProvider(widget.ventaId));
    final usuario = ref.watch(authControllerProvider).value;
    final esAdmin = switch (usuario) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de venta')),
      body: ventaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar la venta.')),
        data: (venta) {
          if (venta == null) {
            return const Center(child: Text('Venta no encontrada.'));
          }
          final anulada = venta.estado == EstadoVenta.anulada;
          final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (anulada)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.block,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Venta anulada',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (anulada) const SizedBox(height: AppSpacing.md),
              _DetalleFila(
                etiqueta: 'Tipo',
                valor: venta.tipo == TipoVenta.rapida
                    ? 'Venta rápida'
                    : 'Venta detallada',
              ),
              _DetalleFila(
                etiqueta: 'Método de pago',
                valor: [
                  (venta.metodoPago ?? MetodoPago.efectivo).etiqueta,
                  if (venta.clienteNombre != null) venta.clienteNombre!,
                ].join(' · '),
              ),
              _DetalleFila(
                etiqueta: 'Fecha',
                valor: formatoFecha.format(venta.fecha.toLocal()),
              ),
              _DetalleFila(
                etiqueta: 'Atendido por',
                valor: venta.usuarioNombre,
              ),
              if (venta.nota != null && venta.nota!.trim().isNotEmpty)
                _DetalleFila(etiqueta: 'Nota', valor: venta.nota!),
              const Divider(height: AppSpacing.lg * 2),
              Text('Productos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              for (final item in venta.items)
                Card(
                  child: ListTile(
                    title: Text(item.productoNombre),
                    subtitle: Text(
                      '${item.cantidad.toStringAsFixed(2)} x '
                      '${item.precioUnitario.format()}',
                    ),
                    trailing: Text(
                      item.subtotal.format(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const Divider(height: AppSpacing.lg * 2),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      venta.total.format(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (esAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ganancia'),
                      Text(
                        venta.ganancia.format(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              if (esAdmin && !anulada && usuarioId != null) ...[
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: _guardando
                      ? null
                      : () => _anular(
                          context,
                          ref,
                          usuarioId,
                          venta.metodoPago ?? MetodoPago.efectivo,
                        ),
                  icon: _guardando
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      : Icon(
                          Icons.block,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  label: Text(
                    'Anular venta',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DetalleFila extends StatelessWidget {
  const _DetalleFila({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
