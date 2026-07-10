import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/empleado.dart';
import '../providers/employees_providers.dart';

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
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final tipo = _tabController.index == 0
              ? TipoEmpleado.ventas
              : TipoEmpleado.delivery;
          return FloatingActionButton.extended(
            onPressed: () => context.push('/empleados/nuevo?tipo=${tipo.name}'),
            icon: const Icon(Icons.add),
            label: const Text('Empleado'),
          );
        },
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

    return empleadosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
          const Center(child: Text('No se pudieron cargar los empleados.')),
      data: (empleados) {
        if (empleados.isEmpty) {
          return const Center(child: Text('Aún no hay empleados.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
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
    return Card(
      child: ListTile(
        onTap: () => context.push('/empleados/${empleado.id}'),
        leading: CircleAvatar(
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
        title: Text(empleado.nombre),
        subtitle: Text(
          '${empleado.tiempoTrabajado}'
          '${empleado.salario == null ? '' : ' · ${empleado.salario!.format()}'}'
          '${empleado.activo ? '' : ' · Inactivo'}',
        ),
      ),
    );
  }
}
