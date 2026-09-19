import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/fechas.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/rango_fecha.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/compra.dart';
import '../providers/purchases_providers.dart';

/// Lista de compras (RF-COM), más reciente primero y AGRUPADA POR DÍA con el
/// total comprado ese día (sin las anuladas). Filtros con texto: proveedor y
/// período (Hoy / Esta semana / Este mes / Personalizado).
class PurchasesListScreen extends ConsumerWidget {
  const PurchasesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comprasAsync = ref.watch(comprasProvider);
    final filtro = ref.watch(comprasFiltroProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push(AppRoutes.comprasNueva),
        icon: const Icon(Icons.add),
        label: const Text('Nueva compra'),
      ),
      body: Column(
        children: [
          const _ComprasFiltroBar(),
          Expanded(
            child: comprasAsync.when(
              loading: () => const LoadingView(),
              error: (error, stackTrace) => ErrorState(
                mensaje: 'No se pudieron cargar las compras.',
                error: error,
                stackTrace: stackTrace,
                onReintentar: () => ref.invalidate(comprasProvider),
              ),
              data: (compras) {
                if (compras.isEmpty) {
                  return filtro.activo
                      ? EmptyState(
                          icono: Icons.filter_alt_off_outlined,
                          titulo: 'Sin resultados para este filtro',
                          descripcion:
                              'No hay compras de ese proveedor en ese período.',
                          accionLabel: 'Quitar filtros',
                          onAccion: () => ref
                              .read(comprasFiltroProvider.notifier)
                              .actualizar((_) => const ComprasFiltro()),
                        )
                      : EmptyState(
                          icono: Icons.shopping_cart_outlined,
                          titulo: 'Aún no hay compras',
                          descripcion:
                              'Registra lo que compras a tus proveedores y el '
                              'inventario se repone solo.',
                          accionLabel: 'Nueva compra',
                          onAccion: () => context.push(AppRoutes.comprasNueva),
                        );
                }
                return _ListaCompras(compras: compras);
              },
            ),
          ),
        ],
      ),
    );
  }
}

Money _totalVigente(Iterable<Compra> compras) => compras
    .where((c) => c.estado == EstadoCompra.completada)
    .fold(Money.zero, (suma, c) => suma + c.total);

class _ListaCompras extends StatelessWidget {
  const _ListaCompras({required this.compras});

  final List<Compra> compras;

  @override
  Widget build(BuildContext context) {
    final grupos = agruparPorDia(compras, (c) => c.fecha, DateTime.now());
    final filas = <Widget>[
      for (final grupo in grupos) ...[
        EncabezadoDia(
          titulo: grupo.etiqueta,
          total: _totalVigente(grupo.elementos),
          etiquetaTotal: 'Comprado',
        ),
        for (final compra in grupo.elementos)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _CompraTile(compra: compra),
          ),
      ],
    ];
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl + 56,
      ),
      itemCount: filas.length,
      itemBuilder: (context, i) => filas[i],
    );
  }
}

class _ComprasFiltroBar extends ConsumerWidget {
  const _ComprasFiltroBar();

  Future<void> _elegirRango(
    BuildContext context,
    WidgetRef ref,
    RangoFecha rango,
  ) async {
    final controlador = ref.read(comprasFiltroProvider.notifier);
    if (rango != RangoFecha.personalizado) {
      controlador.actualizar(
        (f) => f.copyWith(rango: rango, desde: null, hasta: null),
      );
      return;
    }
    final filtro = ref.read(comprasFiltroProvider);
    final elegido = await elegirRangoDeFechas(
      context,
      desde: filtro.desde,
      hasta: filtro.hasta,
    );
    if (elegido == null) return;
    final limites = limitesDeDias(elegido.start, elegido.end);
    controlador.actualizar(
      (f) => f.copyWith(
        rango: RangoFecha.personalizado,
        desde: limites.desde,
        hasta: limites.hasta,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(comprasFiltroProvider);
    final proveedoresAsync = ref.watch(proveedoresProvider);
    final formatoDia = DateFormat('dd/MM');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          proveedoresAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (proveedores) => DropdownButtonFormField<String?>(
              initialValue: filtro.proveedorId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Proveedor'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos los proveedores'),
                ),
                for (final proveedor in proveedores)
                  DropdownMenuItem(
                    value: proveedor.id,
                    child: Text(proveedor.nombre),
                  ),
              ],
              onChanged: (valor) => ref
                  .read(comprasFiltroProvider.notifier)
                  .actualizar((f) => f.copyWith(proveedorId: valor)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FiltroFechaChip(
            rango: filtro.rango,
            textoPersonalizado: filtro.desde != null && filtro.hasta != null
                ? '${formatoDia.format(filtro.desde!.toLocal())} - '
                      '${formatoDia.format(filtro.hasta!.toLocal())}'
                : null,
            onElegir: (rango) => _elegirRango(context, ref, rango),
          ),
        ],
      ),
    );
  }
}

class _CompraTile extends StatelessWidget {
  const _CompraTile({required this.compra});

  final Compra compra;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final anulada = compra.estado == EstadoCompra.anulada;
    final detalle = [
      DateFormat('HH:mm').format(compra.fecha.toLocal()),
      if (compra.numeroFactura != null) 'Factura ${compra.numeroFactura}',
      if (compra.pagadaDeCaja) 'Pagada de caja',
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.push('/compras/${compra.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compra.proveedorNombre ?? 'Sin proveedor',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    Text(
                      detalle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 130),
                    child: MoneyText(
                      compra.total,
                      textAlign: TextAlign.right,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: anulada ? scheme.onSurfaceVariant : null,
                        decoration: anulada ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (anulada) const EtiquetaAnulada(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
