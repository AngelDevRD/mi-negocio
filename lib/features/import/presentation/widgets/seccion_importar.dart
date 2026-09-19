import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../data/presentation/widgets/seccion_datos.dart';
import '../../domain/entities/import_target.dart';
import '../providers/import_providers.dart';

/// Sección "Importar" de Datos (FASE 20): elegir el tipo de datos, ver qué
/// columnas reconoce la app, cargar el Excel, emparejar columnas, revisar la
/// vista previa y confirmar. Al terminar lista los errores fila por fila.
class SeccionImportar extends ConsumerStatefulWidget {
  const SeccionImportar({super.key});

  @override
  ConsumerState<SeccionImportar> createState() => _SeccionImportarState();
}

class _SeccionImportarState extends ConsumerState<SeccionImportar> {
  bool _leyendo = false;
  bool _importando = false;
  String? _errorArchivo;
  String? _nombreArchivo;

  static final DateFormat _fecha = DateFormat('dd/MM/yyyy');

  /// Errores por fila que se listan (el resto se resume).
  static const _maximoErrores = 20;

  String? _usuarioId() {
    final sesion = ref.read(authControllerProvider).value;
    return switch (sesion) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
  }

  Future<void> _elegirArchivo() async {
    if (_leyendo) return;
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
        if (mounted) setState(() => _leyendo = false);
        return;
      }
      final error = ref
          .read(importControllerProvider.notifier)
          .cargarArchivo(bytes);
      if (!mounted) return;
      setState(() {
        _leyendo = false;
        _errorArchivo = error;
        _nombreArchivo = error == null ? archivo.name : null;
      });
    } on Object catch (e, st) {
      developer.log(
        'No se pudo leer el Excel',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      setState(() {
        _leyendo = false;
        _errorArchivo =
            'No se pudo leer el archivo. Comprueba que sea un Excel '
            '(.xlsx o .xls) válido.';
        _nombreArchivo = null;
      });
    }
  }

  Future<void> _confirmar() async {
    if (_importando) return;
    final usuarioId = _usuarioId();
    final estado = ref.read(importControllerProvider);
    final hoja = estado.hoja;
    if (usuarioId == null || hoja == null || estado.cargandoImportacion) {
      return;
    }

    final filas = hoja.filas.length;
    final confirmado = await mostrarConfirmacion(
      context,
      titulo: '¿Importar $filas ${filas == 1 ? 'fila' : 'filas'}?',
      mensaje:
          'Se agregarán como ${estado.targetType.etiqueta.toLowerCase()} a '
          'los datos actuales (no reemplaza nada). Las filas con errores se '
          'omiten y se listan al terminar.',
      confirmarLabel: 'Importar',
    );
    if (!confirmado || !mounted || _importando) return;

    setState(() => _importando = true);
    final error = await ref
        .read(importControllerProvider.notifier)
        .confirmarImportacion(usuarioId: usuarioId);
    if (!mounted) return;
    setState(() => _importando = false);
    final resultado = ref.read(importControllerProvider).resultado;
    if (error != null) {
      AppSnackbar.error(context, error);
    } else if (resultado != null) {
      AppSnackbar.exito(
        context,
        '${resultado.insertados} '
        '${resultado.insertados == 1 ? 'fila importada' : 'filas importadas'}'
        '${resultado.errores.isEmpty ? '.' : ' (${resultado.errores.length} con errores).'}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(importControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final campos = camposImportacion[estado.targetType]!;
    final ocupado = _importando || estado.cargandoImportacion;

    return SeccionDatos(
      icono: Icons.file_upload_outlined,
      titulo: 'Importar',
      descripcion:
          'Trae tus datos desde el Excel de tu sistema anterior. Revisa la '
          'vista previa antes de importar.',
      children: [
        Text('1. Qué vas a importar', style: textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<ImportTargetType>(
          initialValue: estado.targetType,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Tipo de datos'),
          items: [
            for (final tipo in ImportTargetType.values)
              DropdownMenuItem(value: tipo, child: Text(tipo.etiqueta)),
          ],
          onChanged: ocupado
              ? null
              : (valor) {
                  if (valor == null) return;
                  ref
                      .read(importControllerProvider.notifier)
                      .seleccionarTipo(valor);
                },
        ),
        const SizedBox(height: AppSpacing.sm),
        // "Plantilla": las columnas que la app reconoce para este tipo.
        Text(
          'Columnas que reconoce la app (* obligatoria). Tu Excel debe '
          'tener una fila de encabezados; en el paso 3 las emparejas.',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final campo in campos)
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(
                  campo.requerido ? '${campo.etiqueta} *' : campo.etiqueta,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('2. Tu archivo', style: textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(
          icon: _leyendo
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(
            _leyendo
                ? 'Leyendo el archivo...'
                : (_nombreArchivo ?? 'Elegir archivo Excel'),
          ),
          onPressed: (_leyendo || ocupado) ? null : _elegirArchivo,
        ),
        if (_errorArchivo != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _Mensaje(
            icono: Icons.error_outline,
            texto: _errorArchivo!,
            color: scheme.error,
          ),
        ],
        if (estado.hojas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          if (estado.hojas.length > 1) ...[
            DropdownButtonFormField<int>(
              initialValue: estado.hojaSeleccionada,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Hoja del Excel'),
              items: [
                for (var i = 0; i < estado.hojas.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(estado.hojas[i].nombre),
                  ),
              ],
              onChanged: ocupado
                  ? null
                  : (valor) {
                      if (valor == null) return;
                      ref
                          .read(importControllerProvider.notifier)
                          .seleccionarHoja(valor);
                    },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  '3. Empareja las columnas',
                  style: textTheme.labelLarge,
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
                onPressed: (estado.cargandoIA || ocupado)
                    ? null
                    : () => ref
                          .read(importControllerProvider.notifier)
                          .sugerirMapeoIA(),
              ),
            ],
          ),
          if (estado.advertenciasIA != null &&
              estado.advertenciasIA!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            for (final a in estado.advertenciasIA!)
              _Mensaje(
                icono: Icons.warning_amber_rounded,
                texto: a,
                color: context.appColors.advertencia,
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          const _MapeoTabla(),
          const SizedBox(height: AppSpacing.md),
          Text('4. Vista previa', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          _VistaPrevia(formatoFecha: _fecha),
          if (estado.error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _Mensaje(
              icono: Icons.error_outline,
              texto: estado.error!,
              color: scheme.error,
            ),
          ],
          if (estado.resultado != null) ...[
            const SizedBox(height: AppSpacing.md),
            _ResultadoImportacion(
              insertados: estado.resultado!.insertados,
              errores: estado.resultado!.errores,
              maximoErrores: _maximoErrores,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            icon: ocupado
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt_outlined),
            label: Text(ocupado ? 'Importando...' : 'Importar'),
            onPressed: ocupado ? null : _confirmar,
          ),
          if (ocupado) ...[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(),
          ],
        ],
      ],
    );
  }
}

/// Línea de mensaje con ícono + texto (no solo color).
class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.icono,
    required this.texto,
    required this.color,
  });

  final IconData icono;
  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(texto, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}

/// Resultado de una importación: cuántas filas entraron y, una por una, las
/// que no (con el número de fila del Excel y el motivo).
class _ResultadoImportacion extends StatelessWidget {
  const _ResultadoImportacion({
    required this.insertados,
    required this.errores,
    required this.maximoErrores,
  });

  final int insertados;
  final List<String> errores;
  final int maximoErrores;

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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EtiquetaEstado(
              icono: Icons.check_circle_outline,
              texto:
                  '$insertados ${insertados == 1 ? 'fila importada' : 'filas importadas'}',
              color: context.appColors.exito,
            ),
            if (errores.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              EtiquetaEstado(
                icono: Icons.error_outline,
                texto:
                    '${errores.length} ${errores.length == 1 ? 'fila no se importó' : 'filas no se importaron'}',
                color: scheme.error,
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final error in errores.take(maximoErrores))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• $error', style: textTheme.bodySmall),
                ),
              if (errores.length > maximoErrores)
                Text(
                  'y ${errores.length - maximoErrores} más.',
                  style: textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
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
