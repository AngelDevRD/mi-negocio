import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../domain/entities/import_target.dart';
import '../providers/import_providers.dart';

/// Pantalla de importación de datos de migración (FASE 20, solo
/// Administrador). No disponible en el plan Demo (RN-17, igual que
/// exportaciones).
class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licencia = ref.watch(licenseControllerProvider).value;
    final esDemo = switch (licencia) {
      LicenciaActiva(:final licencia) => licencia.tipo == TipoLicencia.demo,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Importar datos')),
      body: esDemo ? const _BloqueoDemo() : const _ImportForm(),
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
              'La importación de datos no está disponible en el plan Demo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Activa una licencia Local o Nube para migrar datos desde Excel.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportForm extends ConsumerStatefulWidget {
  const _ImportForm();

  @override
  ConsumerState<_ImportForm> createState() => _ImportFormState();
}

class _ImportFormState extends ConsumerState<_ImportForm> {
  bool _leyendo = false;
  String? _errorArchivo;
  String? _nombreArchivo;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  String? _usuarioId() {
    final sesion = ref.read(authControllerProvider).value;
    return switch (sesion) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
  }

  Future<void> _elegirArchivo() async {
    setState(() {
      _leyendo = true;
      _errorArchivo = null;
    });
    try {
      final resultado = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );
      final archivo = resultado?.files.single;
      final bytes = archivo?.bytes;
      if (archivo == null || bytes == null) {
        setState(() => _leyendo = false);
        return;
      }
      final error = ref
          .read(importControllerProvider.notifier)
          .cargarArchivo(bytes);
      setState(() {
        _leyendo = false;
        _errorArchivo = error;
        _nombreArchivo = error == null ? archivo.name : null;
      });
    } catch (e) {
      setState(() {
        _leyendo = false;
        _errorArchivo = 'No se pudo leer el archivo: $e';
        _nombreArchivo = null;
      });
    }
  }

  Future<void> _confirmar() async {
    final usuarioId = _usuarioId();
    if (usuarioId == null) return;
    await ref
        .read(importControllerProvider.notifier)
        .confirmarImportacion(usuarioId: usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(importControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Sube el Excel de tu sistema anterior. La IA te ayuda a mapear las '
          'columnas al formato de la app; revisa y corrige antes de importar.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          icon: _leyendo
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(_nombreArchivo ?? 'Elegir archivo Excel'),
          onPressed: _leyendo ? null : _elegirArchivo,
        ),
        if (_errorArchivo != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _errorArchivo!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (estado.hojas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          if (estado.hojas.length > 1) ...[
            Text('Hoja', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: estado.hojaSeleccionada,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                for (var i = 0; i < estado.hojas.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(estado.hojas[i].nombre),
                  ),
              ],
              onChanged: (valor) {
                if (valor == null) return;
                ref
                    .read(importControllerProvider.notifier)
                    .seleccionarHoja(valor);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            'Tipo de datos a importar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<ImportTargetType>(
            initialValue: estado.targetType,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (final tipo in ImportTargetType.values)
                DropdownMenuItem(value: tipo, child: Text(tipo.etiqueta)),
            ],
            onChanged: (valor) {
              if (valor == null) return;
              ref
                  .read(importControllerProvider.notifier)
                  .seleccionarTipo(valor);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mapeo de columnas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                icon: estado.cargandoIA
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_outlined),
                label: const Text('Sugerir con IA'),
                onPressed: estado.cargandoIA
                    ? null
                    : () => ref
                          .read(importControllerProvider.notifier)
                          .sugerirMapeoIA(),
              ),
            ],
          ),
          if (estado.advertenciasIA != null &&
              estado.advertenciasIA!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ...estado.advertenciasIA!.map(
              (a) => Text(
                '⚠ $a',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          const _MapeoTabla(),
          const SizedBox(height: AppSpacing.lg),
          Text('Vista previa', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _VistaPrevia(formatoFecha: _fecha),
          if (estado.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              estado.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (estado.resultado != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${estado.resultado!.insertados} fila(s) importada(s).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ...estado.resultado!.errores.map(
              (e) => Text(
                e,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            icon: estado.cargandoImportacion
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt_outlined),
            label: Text(
              estado.cargandoImportacion ? 'Importando...' : 'Importar',
            ),
            onPressed: estado.cargandoImportacion ? null : _confirmar,
          ),
        ],
      ],
    );
  }
}

class _MapeoTabla extends ConsumerWidget {
  const _MapeoTabla();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(importControllerProvider);
    final hoja = estado.hoja;
    if (hoja == null) return const SizedBox.shrink();
    final campos = camposImportacion[estado.targetType]!;
    const sinColumna = '';

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          children: [
            Text('Campo', style: Theme.of(context).textTheme.labelLarge),
            Text(
              'Columna Excel',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              'Transformación',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        for (final campo in campos)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  campo.requerido ? '${campo.etiqueta} *' : campo.etiqueta,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: DropdownButtonFormField<String>(
                  initialValue:
                      estado.mapeo[campo.campo]?.columna ?? sinColumna,
                  isExpanded: true,
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    const DropdownMenuItem(
                      value: sinColumna,
                      child: Text('(ninguna)'),
                    ),
                    for (final encabezado in hoja.encabezados)
                      DropdownMenuItem(
                        value: encabezado,
                        child: Text(encabezado),
                      ),
                  ],
                  onChanged: (valor) {
                    final actual = estado.mapeo[campo.campo];
                    if (actual == null) return;
                    ref
                        .read(importControllerProvider.notifier)
                        .actualizarMapeo(
                          campo.campo,
                          actual.copyWith(
                            columna: (valor == null || valor.isEmpty)
                                ? null
                                : valor,
                          ),
                        );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: DropdownButtonFormField<ColumnTransform>(
                  initialValue:
                      estado.mapeo[campo.campo]?.transform ?? campo.transform,
                  isExpanded: true,
                  decoration: const InputDecoration(isDense: true),
                  items: [
                    for (final transform in ColumnTransform.values)
                      DropdownMenuItem(
                        value: transform,
                        child: Text(transform.etiqueta),
                      ),
                  ],
                  onChanged: (valor) {
                    final actual = estado.mapeo[campo.campo];
                    if (actual == null || valor == null) return;
                    ref
                        .read(importControllerProvider.notifier)
                        .actualizarMapeo(
                          campo.campo,
                          actual.copyWith(transform: valor),
                        );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _VistaPrevia extends ConsumerWidget {
  const _VistaPrevia({required this.formatoFecha});

  final DateFormat formatoFecha;

  String _formatear(Object? valor) {
    if (valor == null) return '';
    if (valor is DateTime) return formatoFecha.format(valor.toLocal());
    return valor.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(importControllerProvider.notifier);
    final estado = ref.watch(importControllerProvider);
    final hoja = estado.hoja;
    if (hoja == null) return const SizedBox.shrink();

    final campos = camposImportacion[estado.targetType]!;
    final filas = controller.previaTransformada();
    if (filas.isEmpty) {
      return const Text('No hay filas para mostrar.');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          for (final campo in campos) DataColumn(label: Text(campo.etiqueta)),
        ],
        rows: [
          for (final fila in filas)
            DataRow(
              cells: [
                for (final campo in campos)
                  DataCell(
                    Text(
                      campo.transform == ColumnTransform.dinero &&
                              fila[campo.campo] is int
                          ? Money(
                              fila[campo.campo] as int,
                            ).format(symbol: false)
                          : _formatear(fila[campo.campo]),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
