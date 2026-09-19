import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/rango_fecha.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../data/presentation/widgets/seccion_datos.dart';
import '../../domain/entities/export_models.dart';
import '../providers/export_providers.dart';

/// Sección "Exportar" de Datos (RF-EXP): elegir reporte, formato y período,
/// generarlo y compartirlo. Recuerda el último archivo generado (nombre y
/// ruta) para poder compartirlo de nuevo.
class SeccionExportar extends ConsumerStatefulWidget {
  const SeccionExportar({super.key});

  @override
  ConsumerState<SeccionExportar> createState() => _SeccionExportarState();
}

class _SeccionExportarState extends ConsumerState<SeccionExportar> {
  bool _generando = false;

  RangoFecha _rango = RangoFecha.mes;
  DateTime? _desdePersonalizado;
  DateTime? _hastaPersonalizado;

  /// Último archivo generado (para compartirlo otra vez sin regenerarlo).
  XFile? _ultimo;

  static const _etiquetasReporte = {
    TipoReporte.ventas: 'Ventas por rango',
    TipoReporte.compras: 'Compras por rango',
    TipoReporte.inventarioValorizado: 'Inventario valorizado',
    TipoReporte.empleadosPagos: 'Empleados y pagos',
    TipoReporte.cierreCaja: 'Cierre de caja',
    TipoReporte.resumenMensual: 'Resumen mensual',
  };

  static const _etiquetasFormato = {
    FormatoExport.excel: 'Excel',
    FormatoExport.pdf: 'PDF',
    FormatoExport.csv: 'CSV',
  };

  bool _usaRangoFechas(TipoReporte tipo) =>
      tipo == TipoReporte.ventas ||
      tipo == TipoReporte.compras ||
      tipo == TipoReporte.empleadosPagos;

  /// Límites (UTC) del período elegido. "Todas las fechas" abarca desde 2020.
  ({DateTime desde, DateTime hasta}) _limites() {
    final ahora = DateTime.now();
    final l = limitesDeRango(
      _rango,
      ahora,
      desde: _desdePersonalizado,
      hasta: _hastaPersonalizado,
    );
    return (
      desde: l.desde ?? DateTime(2020).toUtc(),
      hasta: l.hasta ?? limitesDeDias(ahora, ahora).hasta,
    );
  }

  String? get _textoPersonalizado {
    if (_desdePersonalizado == null || _hastaPersonalizado == null) return null;
    final f = DateFormat('dd/MM/yyyy');
    return '${f.format(_desdePersonalizado!.toLocal())} - '
        '${f.format(_hastaPersonalizado!.toLocal())}';
  }

  Future<void> _elegirRango(RangoFecha rango) async {
    if (rango == RangoFecha.personalizado) {
      final seleccion = await elegirRangoDeFechas(
        context,
        desde: _desdePersonalizado,
        hasta: _hastaPersonalizado,
      );
      if (seleccion == null || !mounted) return;
      final l = limitesDeDias(seleccion.start, seleccion.end);
      setState(() {
        _rango = rango;
        _desdePersonalizado = l.desde;
        _hastaPersonalizado = l.hasta;
      });
      return;
    }
    setState(() => _rango = rango);
  }

  Future<void> _elegirMes() async {
    final mes = ref.read(mesResumenProvider);
    final fecha = await showDatePicker(
      context: context,
      initialDate: mes,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha == null) return;
    ref.read(mesResumenProvider.notifier).seleccionar(fecha);
  }

  Future<XFile?> _generarArchivo(TipoReporte tipo) async {
    final formato = ref.read(formatoExportProvider);
    final servicio = ref.read(exportFileServiceProvider);
    final limites = _limites();

    switch (tipo) {
      case TipoReporte.ventas:
        return servicio.generarVentas(
          desde: limites.desde,
          hasta: limites.hasta,
          formato: formato,
        );
      case TipoReporte.compras:
        return servicio.generarCompras(
          desde: limites.desde,
          hasta: limites.hasta,
          formato: formato,
        );
      case TipoReporte.inventarioValorizado:
        return servicio.generarInventario(formato);
      case TipoReporte.empleadosPagos:
        return servicio.generarEmpleadosPagos(
          desde: limites.desde,
          hasta: limites.hasta,
          formato: formato,
        );
      case TipoReporte.cierreCaja:
        final sesionId = ref.read(sesionCajaSeleccionadaProvider);
        if (sesionId == null) return null;
        return servicio.generarCierreCaja(sesionId: sesionId, formato: formato);
      case TipoReporte.resumenMensual:
        return servicio.generarResumenMensual(ref.read(mesResumenProvider));
    }
  }

  Future<void> _generar() async {
    if (_generando) return;
    final tipo = ref.read(tipoReporteProvider);
    setState(() => _generando = true);
    XFile? archivo;
    try {
      archivo = await _generarArchivo(tipo);
      if (archivo == null) {
        if (mounted) {
          AppSnackbar.error(context, 'Selecciona una sesión de caja.');
        }
        return;
      }
      if (mounted) setState(() => _ultimo = archivo);
      await ref.read(exportFileServiceProvider).compartir(archivo);
      if (mounted) {
        AppSnackbar.exito(
          context,
          'Reporte listo: ${nombreDeArchivo(archivo.path)}',
        );
      }
    } on Object catch (e, st) {
      developer.log(
        'No se pudo generar el reporte',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        AppSnackbar.error(
          context,
          archivo == null
              ? 'No se pudo generar el reporte.'
              : 'El reporte se generó, pero no se pudo compartir. Búscalo '
                    'en: ${archivo.path}',
        );
      }
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _compartirDeNuevo() async {
    final archivo = _ultimo;
    if (archivo == null || _generando) return;
    try {
      await ref.read(exportFileServiceProvider).compartir(archivo);
    } on Object catch (e, st) {
      developer.log(
        'No se pudo compartir el reporte',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        AppSnackbar.error(context, 'No se pudo compartir el archivo.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = ref.watch(tipoReporteProvider);
    final formato = ref.watch(formatoExportProvider);
    final mes = ref.watch(mesResumenProvider);
    final mesFormato = DateFormat('MMMM yyyy', 'es');
    final textTheme = Theme.of(context).textTheme;

    return SeccionDatos(
      icono: Icons.ios_share_outlined,
      titulo: 'Exportar',
      descripcion:
          'Reportes en Excel, PDF o CSV para tu contador o tus '
          'propios controles.',
      children: [
        DropdownButtonFormField<TipoReporte>(
          initialValue: tipo,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Reporte'),
          items: [
            for (final opcion in TipoReporte.values)
              DropdownMenuItem(
                value: opcion,
                child: Text(_etiquetasReporte[opcion]!),
              ),
          ],
          onChanged: _generando
              ? null
              : (valor) {
                  if (valor == null) return;
                  ref.read(tipoReporteProvider.notifier).seleccionar(valor);
                },
        ),
        if (tipo != TipoReporte.resumenMensual) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Formato', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<FormatoExport>(
            segments: [
              for (final opcion in FormatoExport.values)
                ButtonSegment(
                  value: opcion,
                  label: Text(_etiquetasFormato[opcion]!),
                ),
            ],
            selected: {formato},
            onSelectionChanged: _generando
                ? null
                : (seleccion) => ref
                      .read(formatoExportProvider.notifier)
                      .seleccionar(seleccion.first),
          ),
        ],
        if (_usaRangoFechas(tipo)) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Período', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: FiltroFechaChip(
              rango: _rango,
              textoPersonalizado: _textoPersonalizado,
              onElegir: _generando ? (_) {} : _elegirRango,
            ),
          ),
        ],
        if (tipo == TipoReporte.cierreCaja) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Sesión de caja', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          const _SesionCajaSelector(),
        ],
        if (tipo == TipoReporte.resumenMensual) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Mes', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(mesFormato.format(mes)),
            onPressed: _generando ? null : _elegirMes,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          icon: _generando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.ios_share_outlined),
          label: Text(_generando ? 'Generando...' : 'Generar y compartir'),
          onPressed: _generando ? null : _generar,
        ),
        if (_ultimo != null) ...[
          const SizedBox(height: AppSpacing.md),
          _UltimoArchivo(archivo: _ultimo!, onCompartir: _compartirDeNuevo),
        ],
      ],
    );
  }
}

/// Último archivo generado: nombre, ruta y botón para compartirlo otra vez.
class _UltimoArchivo extends StatelessWidget {
  const _UltimoArchivo({required this.archivo, required this.onCompartir});

  final XFile archivo;
  final VoidCallback onCompartir;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(Icons.description_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Último archivo', style: textTheme.labelSmall),
                  Text(
                    nombreDeArchivo(archivo.path),
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    archivo.path,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Compartir de nuevo',
              icon: const Icon(Icons.share_outlined),
              onPressed: onCompartir,
            ),
          ],
        ),
      ),
    );
  }
}

class _SesionCajaSelector extends ConsumerWidget {
  const _SesionCajaSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesionesAsync = ref.watch(sesionesCajaCerradasProvider);
    final seleccionada = ref.watch(sesionCajaSeleccionadaProvider);
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return sesionesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => ErrorState(
        compacto: true,
        mensaje: 'No se pudieron cargar las sesiones de caja.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () => ref.invalidate(sesionesCajaCerradasProvider),
      ),
      data: (sesiones) {
        if (sesiones.isEmpty) {
          return const EmptyState(
            compacto: true,
            icono: Icons.point_of_sale_outlined,
            titulo: 'Aún no hay cajas cerradas',
            descripcion:
                'El reporte de cierre se genera de una caja ya cerrada.',
          );
        }
        return DropdownButtonFormField<String>(
          initialValue: seleccionada,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Caja cerrada'),
          hint: const Text('Selecciona una sesión'),
          items: [
            for (final sesion in sesiones)
              DropdownMenuItem(
                value: sesion.id,
                child: Text(
                  'Apertura: ${df.format(sesion.fechaApertura.toLocal())}'
                  '${sesion.fechaCierre != null ? ' · Cierre: ${df.format(sesion.fechaCierre!.toLocal())}' : ''}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (valor) => ref
              .read(sesionCajaSeleccionadaProvider.notifier)
              .seleccionar(valor),
        );
      },
    );
  }
}
