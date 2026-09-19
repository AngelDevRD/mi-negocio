import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/compra.dart';
import '../providers/purchases_providers.dart';

/// Detalle de una compra (RF-COM): proveedor, factura, fecha local, foto
/// ampliable, productos con cantidad y costo, y el total.
///
/// Limitaciones de datos (se muestran como están, sin consultas extra):
/// el ítem de compra no trae la unidad del producto (solo la cantidad) y el
/// repositorio no ofrece anular una compra, así que no hay botón de anular.
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

class _PurchaseDetail extends StatelessWidget {
  const _PurchaseDetail({required this.compra});

  final Compra compra;

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    final textTheme = Theme.of(context).textTheme;
    final anulada = compra.estado == EstadoCompra.anulada;

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
                  Row(
                    children: [
                      Text(
                        '${formatoCantidad(item.cantidad)} × ',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Flexible(
                        child: MoneyText(
                          item.costoUnitario,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
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
