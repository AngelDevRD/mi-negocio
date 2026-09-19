import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/empleado.dart';
import '../providers/employees_providers.dart';
import '../widgets/etiquetas_empleado.dart';

/// Lista de empleados (RF-EMP-01): dos secciones (Ventas/Delivery) con la
/// misma ficha, diferenciadas por [TipoEmpleado].
class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TipoEmpleado get _tipoActual =>
      _tabController.index == 0 ? TipoEmpleado.ventas : TipoEmpleado.delivery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ventas'),
            Tab(text: 'Delivery'),
          ],
        ),
      ),
      // Con la sección vacía, la única acción principal es la del estado
      // vacío: el FAB se oculta para no duplicarla.
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) => Consumer(
          builder: (context, ref, _) {
            final tipo = _tipoActual;
            final vacia = ref
                .watch(empleadosProvider(tipo))
                .maybeWhen(data: (e) => e.isEmpty, orElse: () => false);
            if (vacia) return const SizedBox.shrink();
            return FloatingActionButton.extended(
              heroTag: null,
              onPressed: () =>
                  context.push('/empleados/nuevo?tipo=${tipo.name}'),
              icon: const Icon(Icons.add),
              label: const Text('Empleado'),
            );
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _EmpleadosTab(tipo: TipoEmpleado.ventas),
          _EmpleadosTab(tipo: TipoEmpleado.delivery),
        ],
      ),
    );
  }
}

class _EmpleadosTab extends ConsumerWidget {
  const _EmpleadosTab({required this.tipo});

  final TipoEmpleado tipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empleadosAsync = ref.watch(empleadosProvider(tipo));
    final seccion = tipo == TipoEmpleado.ventas ? 'de ventas' : 'de delivery';

    return empleadosAsync.when(
      loading: () => const LoadingView(mensaje: 'Cargando empleados...'),
      error: (error, stackTrace) => ErrorState(
        mensaje: 'No se pudieron cargar los empleados.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () => ref.invalidate(empleadosProvider(tipo)),
      ),
      data: (empleados) {
        if (empleados.isEmpty) {
          return EmptyState(
            icono: Icons.badge_outlined,
            titulo: 'Aún no hay empleados $seccion',
            descripcion:
                'Registra a tu equipo para llevar el control de sus pagos y '
                'su antigüedad.',
            accionLabel: 'Agregar empleado',
            accionPrimaria: true,
            onAccion: () => context.push('/empleados/nuevo?tipo=${tipo.name}'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            80,
          ),
          itemCount: empleados.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => _EmpleadoTile(empleado: empleados[i]),
        );
      },
    );
  }
}

class _EmpleadoTile extends StatelessWidget {
  const _EmpleadoTile({required this.empleado});

  final Empleado empleado;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final salario = empleado.salario;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/empleados/${empleado.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: empleado.activo
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHighest,
                backgroundImage: empleado.fotoPath == null
                    ? null
                    : FileImage(File(empleado.fotoPath!)),
                child: empleado.fotoPath == null
                    ? Icon(
                        Icons.person_outline,
                        color: empleado.activo
                            ? scheme.onPrimaryContainer
                            : scheme.outline,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empleado.nombre,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        EtiquetaTipoEmpleado(empleado.tipo),
                        if (!empleado.activo)
                          const EtiquetaActivo(activo: false),
                      ],
                    ),
                    if (salario != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Flexible(
                            child: MoneyText(
                              salario,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (empleado.frecuenciaPago != null)
                            Text(
                              ' · ${empleado.frecuenciaPago}',
                              style: textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Antigüedad: ${empleado.tiempoTrabajado}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
