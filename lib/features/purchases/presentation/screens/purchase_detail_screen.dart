import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/compra.dart';
import '../providers/purchases_providers.dart';

/// Detalle de una compra (RF-COM): proveedor, factura, foto ampliable e
/// ítems con sus costos.
class PurchaseDetailScreen extends ConsumerWidget {
  const PurchaseDetailScreen({super.key, required this.compraId});

  final String compraId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compraAsync = ref.watch(compraProvider(compraId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de compra')),
      body: compraAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudo cargar la compra.')),
        data: (compra) {
          if (compra == null) {
            return const Center(child: Text('Compra no encontrada.'));
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
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (compra.estado == EstadoCompra.anulada)
          Card(
            color: scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Compra anulada',
                style: TextStyle(
                  color: scheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          Text(
            'Foto de factura',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () => _ampliarFoto(context, compra.fotoFacturaPath!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(compra.fotoFacturaPath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Productos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final item in compra.items)
          Card(
            child: ListTile(
              title: Text(item.productoNombre),
              subtitle: Text(
                '${item.cantidad.toStringAsFixed(2)} x ${item.costoUnitario.format()}',
              ),
              trailing: Text(
                item.subtotal.format(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleLarge),
              Text(
                compra.total.format(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
      builder: (_) =>
          Dialog(child: InteractiveViewer(child: Image.file(File(ruta)))),
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
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
