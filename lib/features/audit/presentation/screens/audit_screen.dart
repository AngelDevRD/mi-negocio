import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/rango_fecha.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/registro_auditoria.dart';
import '../../domain/repositories/audit_repository.dart';
import '../etiquetas_auditoria.dart';
import '../providers/audit_providers.dart';

/// Pantalla de consulta de auditoría (RF-AUD-02, solo Administrador):
/// filtros por fecha/módulo/acción/usuario y diff de datos_antes/
/// datos_despues por registro. Es de solo lectura: la auditoría es
/// append-only (RN-14). Carga por páginas: nunca trae todo el historial.
class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosAsync = ref.watch(registrosAuditoriaProvider);
    final filtro = ref.watch(auditoriaFiltroProvider);
    final limite = ref.watch(limiteAuditoriaProvider);
    final hayFiltros =
        filtro.modulo != null ||
        filtro.accion != null ||
        filtro.usuarioId != null ||
        filtro.desde != null ||
        filtro.hasta != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Auditoría')),
      body: Column(
        children: [
          const _AuditoriaFiltroBar(),
          Expanded(
            child: registrosAsync.when(
              loading: () =>
                  const LoadingView(mensaje: 'Cargando registros...'),
              error: (error, stackTrace) => ErrorState(
                mensaje: 'No se pudieron cargar los registros.',
                error: error,
                stackTrace: stackTrace,
                onReintentar: () => ref.invalidate(registrosAuditoriaProvider),
              ),
              data: (registros) {
                if (registros.isEmpty) {
                  return hayFiltros
                      ? EmptyState(
                          icono: Icons.filter_alt_off_outlined,
                          titulo: 'Ningún registro coincide',
                          descripcion:
                              'Prueba con otro período, módulo, acción o '
                              'usuario.',
                          accionLabel: 'Quitar filtros',
                          onAccion: () => ref
                              .read(auditoriaFiltroProvider.notifier)
                              .actualizar((_) => const AuditoriaFiltro()),
                        )
                      : const EmptyState(
                          icono: Icons.history,
                          titulo: 'Aún no hay registros',
                          descripcion:
                              'Cada vez que alguien cree, edite o anule algo '
                              'importante, quedará anotado aquí.',
                        );
                }
                final hayMas = registros.length >= limite;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  itemCount: registros.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    if (i < registros.length) {
                      return _RegistroTile(registro: registros[i]);
                    }
                    return _PieDeLista(
                      cantidad: registros.length,
                      hayMas: hayMas,
                      onCargarMas: () => ref
                          .read(limiteAuditoriaProvider.notifier)
                          .cargarMas(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PieDeLista extends StatelessWidget {
  const _PieDeLista({
    required this.cantidad,
    required this.hayMas,
    required this.onCargarMas,
  });

  final int cantidad;
  final bool hayMas;
  final VoidCallback onCargarMas;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          hayMas
              ? 'Mostrando los $cantidad más recientes'
              : 'Mostrando $cantidad ${cantidad == 1 ? 'registro' : 'registros'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (hayMas) ...[
          const SizedBox(height: AppSpacing.sm),
          FilledButton.tonal(
            onPressed: onCargarMas,
            child: const Text('Cargar más'),
          ),
        ],
      ],
    );
  }
}

class _AuditoriaFiltroBar extends ConsumerStatefulWidget {
  const _AuditoriaFiltroBar();

  @override
  ConsumerState<_AuditoriaFiltroBar> createState() =>
      _AuditoriaFiltroBarState();
}

class _AuditoriaFiltroBarState extends ConsumerState<_AuditoriaFiltroBar> {
  RangoFecha _rango = RangoFecha.todo;
  String? _textoPersonalizado;

  void _aplicarRango(
    RangoFecha rango, {
    DateTime? desde,
    DateTime? hasta,
    String? texto,
  }) {
    final limites = limitesDeRango(
      rango,
      DateTime.now(),
      desde: desde,
      hasta: hasta,
    );
    setState(() {
      _rango = rango;
      _textoPersonalizado = texto;
    });
    ref
        .read(auditoriaFiltroProvider.notifier)
        .actualizar(
          (f) => f.copyWith(desde: limites.desde, hasta: limites.hasta),
        );
  }

  Future<void> _elegirRango(RangoFecha rango) async {
    if (rango != RangoFecha.personalizado) {
      _aplicarRango(rango);
      return;
    }
    final filtro = ref.read(auditoriaFiltroProvider);
    final seleccion = await elegirRangoDeFechas(
      context,
      desde: filtro.desde,
      hasta: filtro.hasta,
    );
    if (seleccion == null || !mounted) return;
    final l = limitesDeDias(seleccion.start, seleccion.end);
    final f = DateFormat('dd/MM/yyyy');
    _aplicarRango(
      rango,
      desde: l.desde,
      hasta: l.hasta,
      texto: '${f.format(seleccion.start)} - ${f.format(seleccion.end)}',
    );
  }

  void _limpiar() {
    setState(() {
      _rango = RangoFecha.todo;
      _textoPersonalizado = null;
    });
    ref
        .read(auditoriaFiltroProvider.notifier)
        .actualizar((_) => const AuditoriaFiltro());
  }

  @override
  Widget build(BuildContext context) {
    final filtro = ref.watch(auditoriaFiltroProvider);
    final modulos = ref.watch(modulosAuditoriaProvider).value ?? [];
    final acciones = ref.watch(accionesAuditoriaProvider).value ?? [];
    final usuarios = ref.watch(usuariosAuditoriaProvider).value ?? [];
    final controlador = ref.read(auditoriaFiltroProvider.notifier);
    final hayFiltros =
        filtro.modulo != null ||
        filtro.accion != null ||
        filtro.usuarioId != null ||
        _rango != RangoFecha.todo;

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
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FiltroFechaChip(
                rango: _rango,
                textoPersonalizado: _textoPersonalizado,
                onElegir: _elegirRango,
              ),
              if (hayFiltros)
                TextButton.icon(
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: const Text('Quitar filtros'),
                  onPressed: _limpiar,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('modulo-${filtro.modulo}'),
                  initialValue: filtro.modulo,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Módulo'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    for (final m in modulos)
                      DropdownMenuItem(
                        value: m,
                        child: Text(etiquetaDeModulo(m)),
                      ),
                  ],
                  onChanged: (valor) =>
                      controlador.actualizar((f) => f.copyWith(modulo: valor)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('accion-${filtro.accion}'),
                  initialValue: filtro.accion,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Acción'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    for (final a in acciones)
                      DropdownMenuItem(
                        value: a,
                        child: Text(
                          etiquetaDeAccion(a).texto,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (valor) =>
                      controlador.actualizar((f) => f.copyWith(accion: valor)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String?>(
            key: ValueKey('usuario-${filtro.usuarioId}'),
            initialValue: filtro.usuarioId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Usuario'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              for (final u in usuarios)
                DropdownMenuItem(value: u.id, child: Text(u.nombre)),
            ],
            onChanged: (valor) =>
                controlador.actualizar((f) => f.copyWith(usuarioId: valor)),
          ),
        ],
      ),
    );
  }
}

class _RegistroTile extends StatelessWidget {
  const _RegistroTile({required this.registro});

  final RegistroAuditoria registro;

  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accion = etiquetaDeAccion(registro.accion);
    final destructiva =
        registro.accion == 'anular' || registro.accion == 'eliminar';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => _RegistroDetalleDialog(registro: registro),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        EtiquetaEstado(
                          icono: accion.icono,
                          texto: accion.texto,
                          color: destructiva ? scheme.error : scheme.primary,
                        ),
                        Text(
                          etiquetaDeModulo(registro.modulo),
                          style: textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${registro.usuarioNombre} · '
                      '${_fechaHora.format(registro.fecha.toLocal())}',
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

class _RegistroDetalleDialog extends StatelessWidget {
  const _RegistroDetalleDialog({required this.registro});

  final RegistroAuditoria registro;

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    final accion = etiquetaDeAccion(registro.accion);
    final claves = <String>{
      ...?registro.datosAntes?.keys,
      ...?registro.datosDespues?.keys,
    };

    return AlertDialog(
      scrollable: true,
      title: Text('${etiquetaDeModulo(registro.modulo)} · ${accion.texto}'),
      content: SizedBox(
        width: double.maxFinite,
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
                          child: Text('${registro.datosAntes?[clave] ?? '—'}'),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
