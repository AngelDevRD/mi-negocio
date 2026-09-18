import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../sales/presentation/metodo_pago_texto.dart';
import '../../domain/entities/cliente.dart';
import '../providers/customers_providers.dart';
import '../widgets/abono_dialog.dart';

/// Detalle de un cliente: saldo, límite, acciones (abono, compartir saldo) e
/// historial de movimientos.
class ClienteDetailScreen extends ConsumerWidget {
  const ClienteDetailScreen({super.key, required this.clienteId});

  final String clienteId;

  Cliente? _buscar(List<Cliente> clientes) {
    for (final c in clientes) {
      if (c.id == clienteId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientes = ref.watch(clientesProvider);
    final esAdmin = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };

    return clientes.when(
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          mensaje: 'No se pudo cargar el cliente.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () => ref.invalidate(clientesProvider),
        ),
      ),
      data: (lista) {
        final cliente = _buscar(lista);
        if (cliente == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icono: Icons.person_off_outlined,
              titulo: 'Cliente no encontrado',
            ),
          );
        }
        return _Detalle(cliente: cliente, esAdmin: esAdmin);
      },
    );
  }
}

class _Detalle extends ConsumerWidget {
  const _Detalle({required this.cliente, required this.esAdmin});

  final Cliente cliente;
  final bool esAdmin;

  Future<void> _abonar(BuildContext context) async {
    final saldoRestante = await showDialog<Money>(
      context: context,
      builder: (_) => AbonoDialog(cliente: cliente),
    );
    if (saldoRestante == null || !context.mounted) return;
    AppSnackbar.exito(
      context,
      'Abono registrado · Saldo ${saldoRestante.format()}',
    );
  }

  Future<void> _compartir(WidgetRef ref) async {
    final negocio = ref.read(negocioProvider).value?.nombre ?? 'el negocio';
    await ref.read(compartirTextoProvider)(
      'Hola ${cliente.nombre}, tu saldo pendiente en $negocio es '
      '${cliente.saldo.format()}.',
    );
  }

  Future<String?> _usuarioId(WidgetRef ref) async =>
      switch (ref.read(authControllerProvider).value) {
        SesionActiva(:final usuario) => usuario.id,
        _ => null,
      };

  Future<void> _alternarActivo(BuildContext context, WidgetRef ref) async {
    final usuarioId = await _usuarioId(ref);
    if (usuarioId == null) return;
    final nuevo = !cliente.activo;
    final r = await ref
        .read(customersRepositoryProvider)
        .establecerActivo(id: cliente.id, activo: nuevo, usuarioId: usuarioId);
    if (!context.mounted) return;
    r.when(
      ok: (_) => AppSnackbar.exito(
        context,
        nuevo ? 'Cliente activado' : 'Cliente desactivado',
      ),
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final usuarioId = await _usuarioId(ref);
    if (usuarioId == null || !context.mounted) return;
    final confirmar = await mostrarConfirmacion(
      context,
      titulo: 'Eliminar cliente',
      mensaje:
          'Se eliminará a ${cliente.nombre}. Si tiene movimientos no se '
          'podrá eliminar: desactívalo para conservar su historial.',
      confirmarLabel: 'Eliminar',
      destructivo: true,
    );
    if (!confirmar || !context.mounted) return;
    final r = await ref
        .read(customersRepositoryProvider)
        .eliminarCliente(cliente.id, usuarioId: usuarioId);
    if (!context.mounted) return;
    r.when(
      ok: (_) {
        AppSnackbar.exito(context, 'Cliente eliminado');
        context.pop();
      },
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientos = ref.watch(movimientosClienteProvider(cliente.id));
    final debe = cliente.saldo.cents > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(cliente.nombre),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (opcion) => switch (opcion) {
              'editar' => context.push('/clientes/${cliente.id}/editar'),
              'activo' => _alternarActivo(context, ref),
              'eliminar' => _eliminar(context, ref),
              _ => null,
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'editar', child: Text('Editar')),
              if (esAdmin)
                PopupMenuItem(
                  value: 'activo',
                  child: Text(cliente.activo ? 'Desactivar' : 'Activar'),
                ),
              if (esAdmin)
                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _CabeceraSaldo(cliente: cliente),
          if (debe) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () => _abonar(context),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Registrar abono'),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonalIcon(
              onPressed: () => _compartir(ref),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartir saldo'),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Historial', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          movimientos.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: LoadingView(),
            ),
            error: (error, stackTrace) => ErrorState(
              compacto: true,
              mensaje: 'No se pudo cargar el historial.',
              error: error,
              stackTrace: stackTrace,
              onReintentar: () =>
                  ref.invalidate(movimientosClienteProvider(cliente.id)),
            ),
            data: (lista) {
              if (lista.isEmpty) {
                return const EmptyState(
                  compacto: true,
                  icono: Icons.history,
                  titulo: 'Sin movimientos',
                  descripcion: 'Aquí verás las ventas fiadas y los abonos.',
                );
              }
              return Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final m in lista) _FilaMovimiento(movimiento: m),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CabeceraSaldo extends StatelessWidget {
  const _CabeceraSaldo({required this.cliente});

  final Cliente cliente;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final colores = context.appColors;
    final saldo = cliente.saldo;
    final limite = cliente.limiteCredito;

    final (titulo, color) = saldo.cents > 0
        ? ('Debe', colores.advertencia)
        : saldo.cents < 0
        ? ('Saldo a favor', colores.exito)
        : ('Al día', scheme.onSurfaceVariant);
    final disponible = limite == null
        ? null
        : Money(limite.cents - saldo.cents).cents.clamp(0, limite.cents);

    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (saldo.cents != 0)
              MoneyText(
                Money(saldo.cents.abs()),
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (cliente.telefono != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(cliente.telefono!, style: textTheme.bodyMedium),
            ],
            if (limite != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Límite de crédito ${limite.format()} · Disponible '
                '${Money(disponible!).format()}',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (!cliente.activo) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Cliente inactivo: no se le puede fiar, pero puede abonar.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilaMovimiento extends StatelessWidget {
  const _FilaMovimiento({required this.movimiento});

  final MovimientoCliente movimiento;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = movimiento;
    final (icono, titulo) = switch (m.tipo) {
      TipoMovimientoCliente.cargo => (
        Icons.receipt_long_outlined,
        'Venta fiada',
      ),
      TipoMovimientoCliente.abono => (
        Icons.payments_outlined,
        m.metodoPago == null ? 'Abono' : 'Abono (${m.metodoPago!.etiqueta})',
      ),
      TipoMovimientoCliente.anulacion => (Icons.block, 'Venta anulada'),
    };
    // El abono reduce la deuda: verde, no el rojo de un monto negativo.
    final esAbono = m.tipo == TipoMovimientoCliente.abono;
    final signo = m.monto.cents >= 0 ? '+' : '−';
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(m.fecha.toLocal());

    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      subtitle: Text(
        [fecha, if (m.nota != null && m.nota!.isNotEmpty) m.nota!].join(' · '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            signo,
            style: textTheme.titleMedium?.copyWith(
              color: esAbono ? context.appColors.exito : null,
            ),
          ),
          MoneyText(
            Money(m.monto.cents.abs()),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: esAbono ? context.appColors.exito : null,
            ),
          ),
        ],
      ),
      onTap: m.ventaId == null
          ? null
          : () => context.push('/ventas/${m.ventaId}'),
    );
  }
}
