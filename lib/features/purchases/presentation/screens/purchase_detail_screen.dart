import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/compra.dart';
import '../providers/purchases_providers.dart';

/// Detalle de una compra (RF-COM): proveedor, factura, fecha local, foto
/// ampliable, productos con cantidad, unidad y costo, y el total. El
/// Administrador puede anularla (RN-10) si está completada.
class PurchaseDetailScreen extends ConsumerWidget {
  const PurchaseDetailScreen({super.key, required this.compraId});

  final String compraId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compraAsync = ref.watch(compraProvider(compraId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de compra')),
      body: compraAsync.when(
        loading: () => const LoadingView(),
        error: (error, stackTrace) => ErrorState(
          mensaje: 'No se pudo cargar la compra.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () => ref.invalidate(compraProvider(compraId)),
        ),
        data: (compra) {
          if (compra == null) {
            return const EmptyState(
              icono: Icons.shopping_cart_outlined,
              titulo: 'Compra no encontrada',
            );
          }
          return _PurchaseDetail(compra: compra);
        },
      ),
    );
  }
}

/// Texto de la confirmación de anular [compra]: dice lo que va a pasar con el
/// stock (por producto, con su unidad y avisando de los que quedarían en
/// negativo), con la caja y con el costo. Pública para poder probarla.
String mensajeAnulacionCompra(Compra compra) {
  final negativos = <String>[];
  final lineas = StringBuffer(
    'Se anulará esta compra de ${compra.total.format()}. Esto pasará:\n\n'
    '• Stock: se descuenta lo que entró con la compra.\n',
  );
  for (final item in compra.items) {
    final quedaria = item.stockActual - item.cantidad;
    lineas.writeln(
      '   – ${item.productoNombre}: '
      '-${formatoCantidadUnidad(item.cantidad, item.unidad)} '
      '(hay ${formatoCantidadUnidad(item.stockActual, item.unidad)}, '
      'quedaría ${formatoCantidadUnidad(quedaria, item.unidad)})',
    );
    if (quedaria < 0) negativos.add(item.productoNombre);
  }
  if (negativos.isNotEmpty) {
    lineas.writeln(
      '\n⚠ Quedaría con stock NEGATIVO: ${negativos.join(', ')}. '
      'Ya se vendió parte de lo que entró; revisa el inventario después.',
    );
  }
  lineas.writeln();
  lineas.writeln(switch (compra.cajaDelPagoAbierta) {
    _ when !compra.pagadaDeCaja =>
      '• Caja: no cambia (la compra no se pagó de caja).',
    true => '• Caja: se devuelven ${compra.total.format()} a la caja abierta.',
    false =>
      '• Caja: la caja de esta compra ya se cerró, así que NO se registra '
          'ningún movimiento. Si el proveedor te devolvió dinero, regístralo '
          'como una entrada de efectivo.',
    null =>
      '• Caja: no se encontró el pago de caja de esta compra; no se '
          'registra ningún movimiento.',
  });
  lineas.writeln(
    '• Costo: si esta compra cambió el costo de un producto y nadie lo cambió '
    'después, vuelve al costo anterior.',
  );
  lineas.write('\nEsta acción no se puede deshacer.');
  return lineas.toString();
}

class _PurchaseDetail extends ConsumerStatefulWidget {
  const _PurchaseDetail({required this.compra});

  final Compra compra;

  @override
  ConsumerState<_PurchaseDetail> createState() => _PurchaseDetailState();
}

class _PurchaseDetailState extends ConsumerState<_PurchaseDetail> {
  bool _procesando = false;

  Future<void> _anular() async {
    // El guard va ANTES del diálogo: dos toques seguidos no abren dos.
    if (_procesando) return;
    _procesando = true;
    final compra = widget.compra;

    final confirmada = await mostrarConfirmacion(
      context,
      titulo: '¿Anular esta compra?',
      mensaje: mensajeAnulacionCompra(compra),
      confirmarLabel: 'Anular compra',
      destructivo: true,
    );
    if (!mounted) return;
    if (!confirmada) {
      setState(() => _procesando = false);
      return;
    }
    final usuarioId = switch (ref.read(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) {
      setState(() => _procesando = false);
      AppSnackbar.error(context, 'No hay una sesión activa.');
      return;
    }

    setState(() {});
    final resultado = await ref
        .read(purchasesRepositoryProvider)
        .anularCompra(compra.id, usuarioId: usuarioId);
    if (!mounted) return;
    setState(() => _procesando = false);
    switch (resultado) {
      case Fail(:final failure):
        AppSnackbar.error(context, failure.message);
      case Ok(:final value):
        ref.invalidate(compraProvider(compra.id));
        AppSnackbar.exito(context, 'Compra anulada.');
        final avisos = [
          if (value.cajaYaCerrada)
            'La caja de esta compra ya se cerró. Si el proveedor te devolvió '
                'dinero, regístralo como una entrada de efectivo.',
          if (value.costoConservado.isNotEmpty)
            'El costo de ${value.costoConservado.join(', ')} se dejó como '
                'está porque cambió después de esta compra.',
        ];
        if (avisos.isNotEmpty) {
          await showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              scrollable: true,
              title: const Text('Compra anulada'),
              content: Text(avisos.join('\n\n')),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final compra = widget.compra;
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    final textTheme = Theme.of(context).textTheme;
    final anulada = compra.estado == EstadoCompra.anulada;
    final esAdmin = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (anulada) ...[
                  const EtiquetaAnulada(),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _DetalleFila(
                  etiqueta: 'Proveedor',
                  valor: compra.proveedorNombre ?? 'Sin proveedor',
                ),
                _DetalleFila(
                  etiqueta: 'Número de factura',
                  valor: compra.numeroFactura ?? '—',
                ),
                _DetalleFila(
                  etiqueta: 'Fecha',
                  valor: formatoFecha.format(compra.fecha.toLocal()),
                ),
                _DetalleFila(
                  etiqueta: 'Registrada por',
                  valor: compra.usuarioNombre,
                ),
                _DetalleFila(
                  etiqueta: 'Pagada de caja',
                  valor: compra.pagadaDeCaja ? 'Sí' : 'No',
                ),
              ],
            ),
          ),
        ),
        if (compra.fotoFacturaPath != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Foto de factura', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _ampliarFoto(context, compra.fotoFacturaPath!),
            child: Semantics(
              button: true,
              label: 'Ampliar foto de la factura',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.file(
                  File(compra.fotoFacturaPath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 120,
                    child: EmptyState(
                      compacto: true,
                      icono: Icons.broken_image_outlined,
                      titulo: 'No se pudo abrir la foto',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Productos', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final item in compra.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ItemTile(item: item),
          ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(child: Text('Total', style: textTheme.titleLarge)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: MoneyText(
                  compra.total,
                  textAlign: TextAlign.right,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: anulada ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Anular: solo el Administrador y solo una compra completada (RN-10).
        if (esAdmin && !anulada) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: _procesando ? null : _anular,
            icon: const Icon(Icons.block_outlined),
            label: const Text('Anular compra'),
          ),
        ],
      ],
    );
  }

  void _ampliarFoto(BuildContext context, String ruta) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(
            File(ruta),
            errorBuilder: (_, _, _) => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('No se pudo abrir la foto.'),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final CompraItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productoNombre, style: textTheme.titleSmall),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${formatoCantidadUnidad(item.cantidad, item.unidad)} × ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      MoneyText(
                        item.costoUnitario,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
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
                item.subtotal,
                textAlign: TextAlign.right,
                style: textTheme.titleSmall?.copyWith(
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
            width: 140,
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
