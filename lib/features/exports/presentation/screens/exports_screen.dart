import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../domain/entities/export_models.dart';
import '../providers/export_providers.dart';

/// Pantalla de exportaciones (RF-EXP, solo Administrador). No disponible en
/// el plan Demo (RF-EXP-04/RN-17).
class ExportsScreen extends ConsumerWidget {
  const ExportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licencia = ref.watch(licenseControllerProvider).value;
    final esDemo = switch (licencia) {
      LicenciaActiva(:final licencia) => licencia.tipo == TipoLicencia.demo,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Exportaciones')),
      body: esDemo ? const _BloqueoDemo() : const _ExportsForm(),
    );
  }
}

class _BloqueoDemo extends StatelessWidget {
  const _BloqueoDemo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Las exportaciones no están disponibles en el plan Demo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Activa una licencia Local o Nube para exportar reportes.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportsForm extends ConsumerStatefulWidget {
  const _ExportsForm();

  @override
  ConsumerState<_ExportsForm> createState() => _ExportsFormState();
}

class _ExportsFormState extends ConsumerState<_ExportsForm> {
  bool _generando = false;
  String? _error;

  static const _etiquetasReporte = {
    TipoReporte.ventas: 'Ventas por rango',
    TipoReporte.compras: 'Compras por rango',
    TipoReporte.inventarioValorizado: 'Inventario valorizado',
    TipoReporte.empleadosPagos: 'Empleados y pagos',
    TipoReporte.cierreCaja: 'Cierre de caja',
    TipoReporte.resumenMensual: 'Resumen mensual',
  };

  static const _etiquetasFormato = {
    FormatoExport.excel: 'Excel (.xlsx)',
    FormatoExport.pdf: 'PDF',
    FormatoExport.csv: 'CSV',
  };

  bool _usaRangoFechas(TipoReporte tipo) =>
      tipo == TipoReporte.ventas ||
      tipo == TipoReporte.compras ||
      tipo == TipoReporte.empleadosPagos;

  Future<void> _elegirRango() async {
    final rango = ref.read(rangoExportProvider);
    final seleccion = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: rango,
    );
    if (seleccion == null) return;
    ref.read(rangoExportProvider.notifier).seleccionar(seleccion);
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

  Future<void> _generar() async {
    final tipo = ref.read(tipoReporteProvider);
    final formato = ref.read(formatoExportProvider);
    final rango = ref.read(rangoExportProvider);
    final servicio = ref.read(exportFileServiceProvider);

    final desde = DateTime(
      rango.start.year,
      rango.start.month,
      rango.start.day,
    ).toUtc();
    final hasta = DateTime(
      rango.end.year,
      rango.end.month,
      rango.end.day,
      23,
      59,
      59,
    ).toUtc();

    setState(() {
      _generando = true;
      _error = null;
    });

    try {
      switch (tipo) {
        case TipoReporte.ventas:
          final archivo = await servicio.generarVentas(
            desde: desde,
            hasta: hasta,
            formato: formato,
          );
          await servicio.compartir(archivo);
        case TipoReporte.compras:
          final archivo = await servicio.generarCompras(
            desde: desde,
            hasta: hasta,
            formato: formato,
          );
          await servicio.compartir(archivo);
        case TipoReporte.inventarioValorizado:
          final archivo = await servicio.generarInventario(formato);
          await servicio.compartir(archivo);
        case TipoReporte.empleadosPagos:
          final archivo = await servicio.generarEmpleadosPagos(
            desde: desde,
            hasta: hasta,
            formato: formato,
          );
          await servicio.compartir(archivo);
        case TipoReporte.cierreCaja:
          final sesionId = ref.read(sesionCajaSeleccionadaProvider);
          if (sesionId == null) {
            setState(() => _error = 'Selecciona una sesión de caja.');
            return;
          }
          final archivo = await servicio.generarCierreCaja(
            sesionId: sesionId,
            formato: formato,
          );
          await servicio.compartir(archivo);
        case TipoReporte.resumenMensual:
          final archivo = await servicio.generarResumenMensual(
            ref.read(mesResumenProvider),
          );
          await servicio.compartir(archivo);
      }
    } catch (_) {
      setState(() => _error = 'No se pudo generar el reporte.');
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = ref.watch(tipoReporteProvider);
    final formato = ref.watch(formatoExportProvider);
    final rango = ref.watch(rangoExportProvider);
    final mes = ref.watch(mesResumenProvider);
    final df = DateFormat('dd/MM/yyyy');
    final mesFormato = DateFormat('MMMM yyyy', 'es');

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Reporte', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<TipoReporte>(
          initialValue: tipo,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            for (final opcion in TipoReporte.values)
              DropdownMenuItem(
                value: opcion,
                child: Text(_etiquetasReporte[opcion]!),
              ),
          ],
          onChanged: (valor) {
            if (valor == null) return;
            ref.read(tipoReporteProvider.notifier).seleccionar(valor);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (tipo != TipoReporte.resumenMensual) ...[
          Text('Formato', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<FormatoExport>(
            segments: [
              for (final opcion in FormatoExport.values)
                ButtonSegment(
                  value: opcion,
                  label: Text(_etiquetasFormato[opcion]!),
                ),
            ],
            selected: {formato},
            onSelectionChanged: (seleccion) => ref
                .read(formatoExportProvider.notifier)
                .seleccionar(seleccion.first),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (_usaRangoFechas(tipo)) ...[
          Text(
            'Rango de fechas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range_outlined),
            label: Text('${df.format(rango.start)} - ${df.format(rango.end)}'),
            onPressed: _elegirRango,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (tipo == TipoReporte.cierreCaja) ...[
          Text(
            'Sesión de caja',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SesionCajaSelector(),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (tipo == TipoReporte.resumenMensual) ...[
          Text('Mes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(mesFormato.format(mes)),
            onPressed: _elegirMes,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
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
      ],
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
      error: (e, _) =>
          const Text('No se pudieron cargar las sesiones de caja.'),
      data: (sesiones) {
        if (sesiones.isEmpty) {
          return const Text('No hay sesiones de caja cerradas.');
        }
        return DropdownButtonFormField<String>(
          initialValue: seleccionada,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          hint: const Text('Selecciona una sesión'),
          items: [
            for (final sesion in sesiones)
              DropdownMenuItem(
                value: sesion.id,
                child: Text(
                  'Apertura: ${df.format(sesion.fechaApertura.toLocal())}'
                  '${sesion.fechaCierre != null ? ' · Cierre: ${df.format(sesion.fechaCierre!.toLocal())}' : ''}',
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
