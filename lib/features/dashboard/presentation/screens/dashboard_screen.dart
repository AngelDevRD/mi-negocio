import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../domain/entities/dashboard_data.dart';
import '../providers/dashboard_providers.dart';

/// Pantalla principal post-login (RF-DASH). Vista diferenciada por rol:
/// la ganancia del mes solo se muestra al Administrador (RN-15).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final usuario = switch (auth.value) {
      SesionActiva(:final usuario) => usuario,
      _ => null,
    };
    final esAdmin = usuario?.esAdministrador ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Productos',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => context.push(AppRoutes.productos),
          ),
          IconButton(
            tooltip: 'Inventario',
            icon: const Icon(Icons.warehouse_outlined),
            onPressed: () => context.push(AppRoutes.inventario),
          ),
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (valor) {
              if (valor == 'logout') {
                ref.read(authControllerProvider.notifier).logout();
              } else {
                context.push(valor);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AppRoutes.gastos,
                child: ListTile(
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('Gastos'),
                ),
              ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.empleados,
                  child: ListTile(
                    leading: Icon(Icons.badge_outlined),
                    title: Text('Empleados'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.usuarios,
                  child: ListTile(
                    leading: Icon(Icons.people_outline),
                    title: Text('Gestionar usuarios'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.analisis,
                  child: ListTile(
                    leading: Icon(Icons.bar_chart_outlined),
                    title: Text('Análisis financiero'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.auditoria,
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('Auditoría'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.exportaciones,
                  child: ListTile(
                    leading: Icon(Icons.ios_share_outlined),
                    title: Text('Exportaciones'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.importar,
                  child: ListTile(
                    leading: Icon(Icons.file_upload_outlined),
                    title: Text('Importar datos'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.respaldo,
                  child: ListTile(
                    leading: Icon(Icons.backup_outlined),
                    title: Text('Respaldo'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.perfil,
                  child: ListTile(
                    leading: Icon(Icons.storefront_outlined),
                    title: Text('Perfil y suscripción'),
                  ),
                ),
              if (esAdmin)
                const PopupMenuItem(
                  value: AppRoutes.asistente,
                  child: ListTile(
                    leading: Icon(Icons.smart_toy_outlined),
                    title: Text('Asistente IA'),
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (usuario != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Hola, ${usuario.nombre}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          if (esAdmin) const _VencimientoBanner(),
          const _CajaActualCard(),
          const SizedBox(height: AppSpacing.md),
          _AccesosRapidos(
            onVender: () => context.push(AppRoutes.ventas),
            onComprar: () => context.push(AppRoutes.compras),
            onCaja: () => context.push(AppRoutes.caja),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                titulo: 'Ventas de hoy',
                icono: Icons.point_of_sale,
                valor: ref.watch(ventasDelDiaProvider),
              ),
              _StatCard(
                titulo: 'Ventas del mes',
                icono: Icons.trending_up,
                valor: ref.watch(ventasDelMesProvider),
              ),
              _StatCard(
                titulo: 'Compras del mes',
                icono: Icons.shopping_cart_outlined,
                valor: ref.watch(comprasDelMesProvider),
              ),
              _StatCard(
                titulo: 'Gastos del mes',
                icono: Icons.receipt_long_outlined,
                valor: ref.watch(gastosDelMesProvider),
              ),
              if (esAdmin)
                _StatCard(
                  titulo: 'Ganancia del mes',
                  icono: Icons.savings_outlined,
                  valor: ref.watch(gananciaDelMesProvider),
                  destacado: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Inventario bajo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _ProductosBajoStock(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Últimos movimientos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _MovimientosRecientes(),
        ],
      ),
    );
  }
}

/// Alerta de vencimiento próximo de la suscripción (F18), solo Administrador.
class _VencimientoBanner extends ConsumerWidget {
  const _VencimientoBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final check = ref.watch(licenseControllerProvider).value;
    final licencia = switch (check) {
      LicenciaActiva(:final licencia) => licencia,
      LicenciaBloqueada(:final licencia) => licencia,
      _ => null,
    };
    if (licencia == null) return const SizedBox.shrink();

    final dias = licencia.diasParaVencer(DateTime.now().toUtc());
    if (dias == null || dias > diasAlertaRenovacion) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final mensaje = dias <= 0
        ? 'Tu suscripción venció. Renueva desde Perfil para evitar '
              'interrupciones.'
        : 'Tu suscripción vence en $dias ${dias == 1 ? 'día' : 'días'}. '
              'Renueva desde Perfil.';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        color: scheme.errorContainer,
        child: ListTile(
          leading: Icon(
            Icons.warning_amber_outlined,
            color: scheme.onErrorContainer,
          ),
          title: Text(
            mensaje,
            style: TextStyle(color: scheme.onErrorContainer),
          ),
          trailing: Icon(Icons.chevron_right, color: scheme.onErrorContainer),
          onTap: () => context.push(AppRoutes.perfil),
        ),
      ),
    );
  }
}

class _CajaActualCard extends ConsumerWidget {
  const _CajaActualCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caja = ref.watch(cajaActualProvider);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: caja.when(
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Text(
            'No se pudo cargar el estado de caja',
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
          data: (sesion) {
            if (sesion == null) {
              return Row(
                children: [
                  Icon(Icons.lock_outline, color: scheme.onPrimaryContainer),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Caja cerrada',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Icon(
                  Icons.point_of_sale_outlined,
                  color: scheme.onPrimaryContainer,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Caja abierta',
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        sesion.montoActual.format(),
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccesosRapidos extends StatelessWidget {
  const _AccesosRapidos({
    required this.onVender,
    required this.onComprar,
    required this.onCaja,
  });

  final VoidCallback onVender;
  final VoidCallback onComprar;
  final VoidCallback onCaja;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onVender,
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Vender'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onComprar,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Comprar'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onCaja,
            icon: const Icon(Icons.point_of_sale_outlined),
            label: const Text('Caja'),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.titulo,
    required this.icono,
    required this.valor,
    this.destacado = false,
  });

  final String titulo;
  final IconData icono;
  final AsyncValue<Money> valor;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: destacado ? scheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icono, size: 18, color: scheme.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    titulo,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            valor.when(
              data: (money) => Text(
                money.format(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              loading: () => const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => const Text('--'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductosBajoStock extends ConsumerWidget {
  const _ProductosBajoStock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosBajoStockProvider);
    return productos.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Text('No se pudo cargar el inventario.'),
      data: (lista) {
        if (lista.isEmpty) {
          return const _EmptyHint(
            icono: Icons.inventory_2_outlined,
            mensaje: 'Sin productos con inventario bajo.',
          );
        }
        return Card(
          child: Column(
            children: [
              for (final producto in lista)
                ListTile(
                  leading: const Icon(Icons.warning_amber_outlined),
                  title: Text(producto.nombre),
                  trailing: Text(
                    '${producto.stockActual.toStringAsFixed(2)} / '
                    '${producto.stockMinimo.toStringAsFixed(2)} ${producto.unidad}',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MovimientosRecientes extends ConsumerWidget {
  const _MovimientosRecientes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientos = ref.watch(movimientosRecientesProvider);
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    return movimientos.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Text('No se pudieron cargar los movimientos.'),
      data: (lista) {
        if (lista.isEmpty) {
          return const _EmptyHint(
            icono: Icons.receipt_long_outlined,
            mensaje: 'Aún no hay movimientos registrados.',
          );
        }
        return Card(
          child: Column(
            children: [
              for (final mov in lista)
                ListTile(
                  leading: Icon(_iconoMovimiento(mov.tipo)),
                  title: Text(_tituloMovimiento(mov.tipo)),
                  subtitle: Text(formatoFecha.format(mov.fecha.toLocal())),
                  trailing: Text(mov.monto.format()),
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _iconoMovimiento(TipoMovimientoReciente tipo) => switch (tipo) {
    TipoMovimientoReciente.venta => Icons.point_of_sale,
    TipoMovimientoReciente.compra => Icons.shopping_cart_outlined,
    TipoMovimientoReciente.gasto => Icons.receipt_long_outlined,
  };

  String _tituloMovimiento(TipoMovimientoReciente tipo) => switch (tipo) {
    TipoMovimientoReciente.venta => 'Venta',
    TipoMovimientoReciente.compra => 'Compra',
    TipoMovimientoReciente.gasto => 'Gasto',
  };
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icono, required this.mensaje});

  final IconData icono;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icono, color: scheme.outline),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                mensaje,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
