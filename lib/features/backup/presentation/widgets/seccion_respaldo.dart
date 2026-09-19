import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart' show Respaldo;
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../data/presentation/widgets/seccion_datos.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../data/services/backup_archive_builder.dart';
import '../../data/services/backup_file_service.dart';
import '../providers/backup_providers.dart';

/// Sección "Respaldo" de Datos (RF-RES): crear un respaldo, restaurar desde un
/// archivo (con doble confirmación, es destructivo) y ver cuándo fue el
/// último.
class SeccionRespaldo extends ConsumerStatefulWidget {
  const SeccionRespaldo({super.key});

  @override
  ConsumerState<SeccionRespaldo> createState() => _SeccionRespaldoState();
}

class _SeccionRespaldoState extends ConsumerState<SeccionRespaldo> {
  /// Texto de la operación en curso ("Creando respaldo..."), o `null`.
  String? _enCurso;

  /// Hay un diálogo esperando la decisión del usuario: la operación sigue
  /// "en curso" (los botones quedan deshabilitados) pero no hay progreso que
  /// mostrar.
  bool _esperandoDecision = false;

  bool get _procesando => _enCurso != null;

  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

  void _registrarError(String mensaje, Object error, StackTrace st) {
    developer.log(mensaje, name: 'mi_negocio', error: error, stackTrace: st);
  }

  Future<void> _crear() async {
    if (_procesando) return;
    final servicio = ref.read(backupFileServiceProvider);
    setState(() => _enCurso = 'Creando el respaldo...');
    try {
      final archivo = await servicio.exportar();
      await servicio.compartir(archivo);
      if (!mounted) return;
      AppSnackbar.exito(
        context,
        'Respaldo creado: ${nombreDeArchivo(archivo.path)}',
      );
    } on Object catch (e, st) {
      _registrarError('No se pudo crear el respaldo', e, st);
      if (mounted) {
        AppSnackbar.error(context, 'No se pudo crear el respaldo.');
      }
    } finally {
      if (mounted) setState(() => _enCurso = null);
    }
  }

  Future<void> _restaurar() async {
    if (_procesando) return;
    final servicio = ref.read(backupFileServiceProvider);

    final ruta = await servicio.elegirArchivoRespaldo();
    if (ruta == null || !mounted) return;

    setState(() => _enCurso = 'Leyendo el respaldo...');
    BackupArchive paquete;
    try {
      paquete = await servicio.validar(ruta);
    } on BackupSchemaException catch (e) {
      _terminarConError(e.toString());
      return;
    } on BackupFormatException catch (e) {
      _terminarConError(e.toString());
      return;
    } on Object catch (e, st) {
      _registrarError('No se pudo leer el respaldo', e, st);
      _terminarConError('No se pudo leer el archivo de respaldo.');
      return;
    }

    final negocioActual = await ref.read(backupDaoProvider).obtenerNegocio();
    final nombreActual = negocioActual?.nombre ?? '';
    if (!mounted) return;

    // Confirmación 1: qué se va a reemplazar (destructiva).
    setState(() => _esperandoDecision = true);
    final continuar = await mostrarConfirmacion(
      context,
      titulo: '¿Restaurar este respaldo?',
      mensaje:
          'Respaldo de "${paquete.manifest.negocioNombre}" creado el '
          '${_fechaHora.format(paquete.manifest.fechaCreacion.toLocal())}.\n\n'
          'Esto REEMPLAZA todos los datos actuales de "$nombreActual" '
          '(ventas, productos, caja, empleados y fotos) por los del '
          'respaldo. No se puede deshacer. Si lo necesitas, crea antes un '
          'respaldo de los datos de ahora.',
      confirmarLabel: 'Continuar',
      destructivo: true,
    );
    if (!continuar || !mounted) {
      if (mounted) {
        setState(() {
          _enCurso = null;
          _esperandoDecision = false;
        });
      }
      return;
    }

    // Confirmación 2: escribir el nombre del negocio (red de seguridad).
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmarNombreDialog(nombreNegocio: nombreActual),
    );
    if (confirmado != true || !mounted) {
      if (mounted) {
        setState(() {
          _enCurso = null;
          _esperandoDecision = false;
        });
      }
      return;
    }

    setState(() {
      _enCurso = 'Restaurando el respaldo...';
      _esperandoDecision = false;
    });
    try {
      final nombreArchivo = File(ruta).uri.pathSegments.last;
      await servicio.restaurar(paquete, nombreArchivo);
      if (!mounted) return;
      await _finalizarRestauracion();
    } on Object catch (e, st) {
      _registrarError('No se pudo restaurar el respaldo', e, st);
      if (mounted) {
        AppSnackbar.error(context, 'No se pudo restaurar el respaldo.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _enCurso = null;
          _esperandoDecision = false;
        });
      }
    }
  }

  void _terminarConError(String mensaje) {
    if (!mounted) return;
    setState(() => _enCurso = null);
    AppSnackbar.error(context, mensaje);
  }

  /// CU-12, paso 5: reinicio de sesión tras restaurar.
  Future<void> _finalizarRestauracion() async {
    setState(() => _esperandoDecision = true);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Respaldo restaurado'),
        content: const Text(
          'Los datos se restauraron correctamente. Vuelve a iniciar sesión '
          'para continuar.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    await ref.read(authControllerProvider.notifier).logout();
    ref.invalidate(licenseControllerProvider);
    if (mounted) context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final historialAsync = ref.watch(historialRespaldosProvider);

    return SeccionDatos(
      icono: Icons.backup_outlined,
      titulo: 'Respaldo',
      descripcion:
          'Una copia de TODOS los datos y fotos de tu negocio, para guardarla '
          'o compartirla. Si cambias de equipo o algo falla, la restauras.',
      children: [
        _UltimoRespaldo(historialAsync: historialAsync),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          icon: const Icon(Icons.backup_outlined),
          label: const Text('Crear respaldo'),
          onPressed: _procesando ? null : _crear,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          icon: const Icon(Icons.restore_outlined),
          label: const Text('Restaurar desde archivo'),
          onPressed: _procesando ? null : _restaurar,
        ),
        if (_enCurso != null && !_esperandoDecision) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(),
          const SizedBox(height: AppSpacing.xs),
          Text(_enCurso!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.md),
        Text('Historial', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        _Historial(historialAsync: historialAsync),
      ],
    );
  }
}

/// "Último respaldo: 15/09/2026 10:30 · 1.2 MB", o un aviso si no hay ninguno.
class _UltimoRespaldo extends StatelessWidget {
  const _UltimoRespaldo({required this.historialAsync});

  final AsyncValue<List<Respaldo>> historialAsync;

  @override
  Widget build(BuildContext context) {
    final ultimo = historialAsync.value
        ?.where((r) => r.resultado == 'ok')
        .firstOrNull;
    if (historialAsync.isLoading && ultimo == null) {
      return const SizedBox.shrink();
    }
    if (ultimo == null) {
      return EtiquetaEstado(
        icono: Icons.warning_amber_rounded,
        texto: 'Aún no has creado ningún respaldo',
        color: context.appColors.advertencia,
      );
    }
    return EtiquetaEstado(
      icono: Icons.check_circle_outline,
      texto:
          'Último respaldo: '
          '${_SeccionRespaldoState._fechaHora.format(ultimo.fecha.toLocal())}'
          ' · ${_formatearTamano(ultimo.tamanoBytes)}',
      color: context.appColors.exito,
    );
  }
}

class _Historial extends ConsumerWidget {
  const _Historial({required this.historialAsync});

  final AsyncValue<List<Respaldo>> historialAsync;

  /// Cuántos respaldos se listan (los más recientes).
  static const _maximo = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return historialAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (error, stackTrace) => ErrorState(
        compacto: true,
        mensaje: 'No se pudo cargar el historial de respaldos.',
        error: error,
        stackTrace: stackTrace,
        onReintentar: () => ref.invalidate(historialRespaldosProvider),
      ),
      data: (respaldos) {
        if (respaldos.isEmpty) {
          return const EmptyState(
            compacto: true,
            icono: Icons.history,
            titulo: 'Todavía no hay respaldos',
            descripcion: 'Cada respaldo que crees quedará anotado aquí.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final respaldo in respaldos.take(_maximo))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      respaldo.resultado == 'ok'
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 20,
                      color: respaldo.resultado == 'ok'
                          ? context.appColors.exito
                          : scheme.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            respaldo.archivo,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${_SeccionRespaldoState._fechaHora.format(respaldo.fecha.toLocal())}'
                            ' · ${_formatearTamano(respaldo.tamanoBytes)}'
                            '${respaldo.resultado == 'ok' ? '' : ' · Falló'}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (respaldos.length > _maximo)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Se muestran los $_maximo más recientes.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Segunda barrera de la restauración: hay que escribir el nombre del
/// negocio actual para habilitar "Restaurar".
class _ConfirmarNombreDialog extends StatefulWidget {
  const _ConfirmarNombreDialog({required this.nombreNegocio});

  final String nombreNegocio;

  @override
  State<_ConfirmarNombreDialog> createState() => _ConfirmarNombreDialogState();
}

class _ConfirmarNombreDialogState extends State<_ConfirmarNombreDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final coincide = _controller.text.trim() == widget.nombreNegocio;
    return AlertDialog(
      scrollable: true,
      title: const Text('Confirma con el nombre del negocio'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Escribe "${widget.nombreNegocio}" para restaurar.'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Nombre del negocio'),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: coincide ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Restaurar'),
        ),
      ],
    );
  }
}

String _formatearTamano(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
