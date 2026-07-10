import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/empleado.dart';
import '../../domain/entities/pago_empleado.dart';
import '../providers/employees_providers.dart';

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

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _alternarActivo(Empleado empleado) async {
    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) return;

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
      ok: (_) => ref.invalidate(empleadoProvider(empleado.id)),
      fail: (f) => _mostrarError(f.message),
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
                  onPressed: () =>
                      context.push('/empleados/${empleado.id}/pago'),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Registrar pago'),
                ),
          orElse: () => null,
        ),
        body: empleadoAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) =>
              const Center(child: Text('No se pudo cargar el empleado.')),
          data: (empleado) {
            if (empleado == null) {
              return const Center(child: Text('Empleado no encontrado.'));
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
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Center(
          child: Text(
            empleado.tipo == TipoEmpleado.ventas ? 'Ventas' : 'Delivery',
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
                _Fila('Tiempo trabajado', empleado.tiempoTrabajado),
                _Fila('Salario', empleado.salario?.format() ?? '—'),
                _Fila('Frecuencia de pago', empleado.frecuenciaPago ?? '—'),
                _Fila('Estado', empleado.activo ? 'Activo' : 'Inactivo'),
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
  const _Fila(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: Theme.of(context).textTheme.bodyMedium),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total pagado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                totalAsync.when(
                  data: (total) => Text(
                    total.format(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
        ),
        Expanded(
          child: pagosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                const Center(child: Text('No se pudo cargar el historial.')),
            data: (pagos) {
              if (pagos.isEmpty) {
                return const Center(
                  child: Text('Aún no hay pagos registrados.'),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
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
    return Card(
      child: ListTile(
        leading: const Icon(Icons.payments_outlined),
        title: Text(pago.monto.format()),
        subtitle: Text(
          '${pago.periodo ?? 'Sin período'}\n'
          '${formatoFecha.format(pago.fecha.toLocal())} · ${pago.usuarioNombre}'
          '${pago.saleDeCaja ? ' · Salió de caja' : ''}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
