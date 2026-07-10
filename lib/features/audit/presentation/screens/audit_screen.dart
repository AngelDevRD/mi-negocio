import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/registro_auditoria.dart';
import '../providers/audit_providers.dart';

/// Pantalla de consulta de auditoría (RF-AUD-02, solo Administrador):
/// filtros por módulo/acción/usuario/rango de fechas y diff de
/// datos_antes/datos_despues por registro. Es de solo lectura: la
/// auditoría es append-only (RN-14).
class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosAsync = ref.watch(registrosAuditoriaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auditoría')),
      body: Column(
        children: [
          const _AuditoriaFiltroBar(),
          Expanded(
            child: registrosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No se pudieron cargar los registros.'),
              ),
              data: (registros) {
                if (registros.isEmpty) {
                  return const Center(
                    child: Text('No hay registros para este filtro.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  itemCount: registros.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _RegistroTile(registro: registros[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditoriaFiltroBar extends ConsumerWidget {
  const _AuditoriaFiltroBar();

  Future<void> _elegirRango(BuildContext context, WidgetRef ref) async {
    final filtro = ref.read(auditoriaFiltroProvider);
    final ahora = DateTime.now();
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(ahora.year - 5),
      lastDate: ahora,
      initialDateRange: filtro.desde != null && filtro.hasta != null
          ? DateTimeRange(start: filtro.desde!, end: filtro.hasta!)
          : null,
    );
    if (rango == null) return;
    ref
        .read(auditoriaFiltroProvider.notifier)
        .actualizar(
          (f) => f.copyWith(
            desde: rango.start,
            hasta: DateTime(
              rango.end.year,
              rango.end.month,
              rango.end.day,
              23,
              59,
              59,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(auditoriaFiltroProvider);
    final modulos = ref.watch(modulosAuditoriaProvider).value ?? [];
    final acciones = ref.watch(accionesAuditoriaProvider).value ?? [];
    final usuarios = ref.watch(usuariosAuditoriaProvider).value ?? [];
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: filtro.modulo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Módulo'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...modulos.map(
                      (m) => DropdownMenuItem(value: m, child: Text(m)),
                    ),
                  ],
                  onChanged: (valor) => ref
                      .read(auditoriaFiltroProvider.notifier)
                      .actualizar((f) => f.copyWith(modulo: valor)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: filtro.accion,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Acción'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ...acciones.map(
                      (a) => DropdownMenuItem(value: a, child: Text(a)),
                    ),
                  ],
                  onChanged: (valor) => ref
                      .read(auditoriaFiltroProvider.notifier)
                      .actualizar((f) => f.copyWith(accion: valor)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: filtro.usuarioId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...usuarios.map(
                      (u) =>
                          DropdownMenuItem(value: u.id, child: Text(u.nombre)),
                    ),
                  ],
                  onChanged: (valor) => ref
                      .read(auditoriaFiltroProvider.notifier)
                      .actualizar((f) => f.copyWith(usuarioId: valor)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (filtro.desde != null && filtro.hasta != null)
                InputChip(
                  label: Text(
                    '${formatoFecha.format(filtro.desde!)} - '
                    '${formatoFecha.format(filtro.hasta!)}',
                  ),
                  onDeleted: () => ref
                      .read(auditoriaFiltroProvider.notifier)
                      .actualizar((f) => f.copyWith(desde: null, hasta: null)),
                )
              else
                IconButton(
                  tooltip: 'Filtrar por fecha',
                  icon: const Icon(Icons.date_range_outlined),
                  onPressed: () => _elegirRango(context, ref),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegistroTile extends StatelessWidget {
  const _RegistroTile({required this.registro});

  final RegistroAuditoria registro;

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      child: ListTile(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => _RegistroDetalleDialog(registro: registro),
        ),
        leading: const Icon(Icons.history),
        title: Text('${registro.modulo} · ${registro.accion}'),
        subtitle: Text(
          '${registro.usuarioNombre} · '
          '${formatoFecha.format(registro.fecha.toLocal())}',
        ),
      ),
    );
  }
}

class _RegistroDetalleDialog extends StatelessWidget {
  const _RegistroDetalleDialog({required this.registro});

  final RegistroAuditoria registro;

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    final claves = <String>{
      ...?registro.datosAntes?.keys,
      ...?registro.datosDespues?.keys,
    };

    return AlertDialog(
      title: Text('${registro.modulo} · ${registro.accion}'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Usuario: ${registro.usuarioNombre}'),
              Text('Fecha: ${formatoFecha.format(registro.fecha.toLocal())}'),
              if (registro.entidadId != null) Text('ID: ${registro.entidadId}'),
              const SizedBox(height: AppSpacing.md),
              if (claves.isEmpty)
                const Text('Sin datos adicionales.')
              else
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    const TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: AppSpacing.sm),
                          child: Text(
                            'Campo',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Antes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Después',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    for (final clave in claves)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.xs,
                              right: AppSpacing.sm,
                            ),
                            child: Text(clave),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              '${registro.datosAntes?[clave] ?? '—'}',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              '${registro.datosDespues?[clave] ?? '—'}',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
