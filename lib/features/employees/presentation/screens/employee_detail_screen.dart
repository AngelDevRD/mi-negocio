import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/entities/pago_empleado.dart';
import '../providers/employees_providers.dart';
import '../widgets/etiquetas_empleado.dart';

/// Detalle de un empleado (RF-EMP): ficha, historial de pagos y total
/// pagado (RF-EMP-04).
class EmployeeDetailScreen extends ConsumerStatefulWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  bool _procesando = false;

  Future<void> _alternarActivo(Empleado empleado) async {
    if (_procesando) return;
    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) return;

    final desactivar = empleado.activo;
    final confirmado = await mostrarConfirmacion(
      context,
      titulo: desactivar ? '¿Desactivar a ${empleado.nombre}?' : '¿Activar?',
      mensaje: desactivar
          ? 'Dejará de aparecer entre los empleados activos. Su historial de '
                'pagos se conserva y puedes activarlo de nuevo cuando quieras.'
          : '${empleado.nombre} volverá a aparecer entre los empleados '
                'activos.',
      confirmarLabel: desactivar ? 'Desactivar' : 'Activar',
    );
    if (!confirmado || !mounted) return;

    setState(() => _procesando = true);
    final resultado = await ref
        .read(employeesRepositoryProvider)
        .establecerActivo(
          id: empleado.id,
          activo: !empleado.activo,
          usuarioId: usuarioId,
        );
    if (!mounted) return;
    setState(() => _procesando = false);
    resultado.when(
      ok: (_) {
        ref.invalidate(empleadoProvider(empleado.id));
        AppSnackbar.exito(
          context,
          desactivar ? 'Empleado desactivado.' : 'Empleado activado.',
        );
      },
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empleadoAsync = ref.watch(empleadoProvider(widget.employeeId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Empleado'),
          actions: [
            empleadoAsync.maybeWhen(
              data: (empleado) => empleado == null
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          context.push('/empleados/${empleado.id}/editar'),
                    ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Detalle'),
              Tab(text: 'Pagos'),
            ],
          ),
        ),
        floatingActionButton: empleadoAsync.maybeWhen(
          data: (empleado) => empleado == null
              ? null
              : FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () =>
                      context.push('/empleados/${empleado.id}/pago'),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar pago'),
                ),
          orElse: () => null,
        ),
        body: empleadoAsync.when(
          loading: () => const LoadingView(mensaje: 'Cargando empleado...'),
          error: (error, stackTrace) => ErrorState(
            mensaje: 'No se pudo cargar el empleado.',
            error: error,
            stackTrace: stackTrace,
            onReintentar: () =>
                ref.invalidate(empleadoProvider(widget.employeeId)),
          ),
          data: (empleado) {
            if (empleado == null) {
              return const EmptyState(
                icono: Icons.person_off_outlined,
                titulo: 'Empleado no encontrado',
                descripcion: 'Puede que ya no exista. Vuelve a la lista.',
              );
            }
            return TabBarView(
              children: [
                _DetalleTab(
                  empleado: empleado,
                  procesando: _procesando,
                  onAlternarActivo: () => _alternarActivo(empleado),
                ),
                _PagosTab(empleadoId: empleado.id),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetalleTab extends StatelessWidget {
  const _DetalleTab({
    required this.empleado,
    required this.procesando,
    required this.onAlternarActivo,
  });

  final Empleado empleado;
  final bool procesando;
  final VoidCallback onAlternarActivo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final salario = empleado.salario;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        80,
      ),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: scheme.primaryContainer,
            backgroundImage: empleado.fotoPath == null
                ? null
                : FileImage(File(empleado.fotoPath!)),
            child: empleado.fotoPath == null
                ? Icon(
                    Icons.person_outline,
                    size: 48,
                    color: scheme.onPrimaryContainer,
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            empleado.nombre,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              EtiquetaTipoEmpleado(empleado.tipo),
              EtiquetaActivo(activo: empleado.activo),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Fila('Cédula', empleado.cedula ?? '—'),
                _Fila('Dirección', empleado.direccion ?? '—'),
                _Fila('Teléfono', empleado.telefono ?? '—'),
                _Fila(
                  'Fecha de ingreso',
                  formatoFecha.format(empleado.fechaIngreso.toLocal()),
                ),
                _Fila('Antigüedad', empleado.tiempoTrabajado),
                _Fila('Salario', salario == null ? '—' : null, monto: salario),
                _Fila('Frecuencia de pago', empleado.frecuenciaPago ?? '—'),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: procesando ? null : onAlternarActivo,
          icon: Icon(
            empleado.activo ? Icons.visibility_off_outlined : Icons.visibility,
          ),
          label: Text(empleado.activo ? 'Desactivar' : 'Activar'),
        ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila(this.etiqueta, this.valor, {this.monto});

  final String etiqueta;
  final String? valor;

  /// Si se da, se muestra con [MoneyText] en vez de [valor].
  final Money? monto;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: monto != null
                ? MoneyText(monto!, textAlign: TextAlign.right, style: estilo)
                : Text(valor ?? '—', textAlign: TextAlign.right, style: estilo),
          ),
        ],
      ),
    );
  }
}

class _PagosTab extends ConsumerWidget {
  const _PagosTab({required this.empleadoId});

  final String empleadoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagosAsync = ref.watch(pagosEmpleadoProvider(empleadoId));
    final totalAsync = ref.watch(totalPagadoProvider(empleadoId));
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total pagado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                totalAsync.when(
                  data: (total) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: MoneyText(
                      total,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, _) => const Text('No disponible'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: pagosAsync.when(
            loading: () => const LoadingView(mensaje: 'Cargando pagos...'),
            error: (error, stackTrace) => ErrorState(
              mensaje: 'No se pudo cargar el historial de pagos.',
              error: error,
              stackTrace: stackTrace,
              onReintentar: () =>
                  ref.invalidate(pagosEmpleadoProvider(empleadoId)),
            ),
            data: (pagos) {
              if (pagos.isEmpty) {
                return const EmptyState(
                  icono: Icons.payments_outlined,
                  titulo: 'Aún no hay pagos registrados',
                  descripcion:
                      'Cada pago que registres aparecerá aquí con su fecha y '
                      'su período. Usa «Registrar pago» para el primero.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  80,
                ),
                itemCount: pagos.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) =>
                    _PagoTile(pago: pagos[i], formatoFecha: formatoFecha),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PagoTile extends StatelessWidget {
  const _PagoTile({required this.pago, required this.formatoFecha});

  final PagoEmpleado pago;
  final DateFormat formatoFecha;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.payments_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoneyText(
                    pago.monto,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(pago.periodo ?? 'Sin período'),
                  Text(
                    '${formatoFecha.format(pago.fecha.toLocal())} · '
                    '${pago.usuarioNombre}',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (pago.saleDeCaja) ...[
                    const SizedBox(height: AppSpacing.xs),
                    const EtiquetaEstado(
                      icono: Icons.point_of_sale_outlined,
                      texto: 'Salió de caja',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
