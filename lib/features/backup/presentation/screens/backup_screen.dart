import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../data/services/backup_archive_builder.dart';
import '../../data/services/backup_file_service.dart';
import '../providers/backup_providers.dart';

/// Pantalla de respaldo y restauración (RF-RES, solo Administrador). No
/// disponible en el plan Demo (RF-RES-06/RN-17).
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licencia = ref.watch(licenseControllerProvider).value;
    final esDemo = switch (licencia) {
      LicenciaActiva(:final licencia) => licencia.tipo == TipoLicencia.demo,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Respaldo y restauración')),
      body: esDemo ? const _BloqueoDemo() : const _BackupBody(),
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
              'El respaldo y la restauración no están disponibles en el '
              'plan Demo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Activa una licencia Local o Nube para respaldar tus datos.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupBody extends ConsumerStatefulWidget {
  const _BackupBody();

  @override
  ConsumerState<_BackupBody> createState() => _BackupBodyState();
}

class _BackupBodyState extends ConsumerState<_BackupBody> {
  bool _procesando = false;
  String? _error;

  Future<void> _exportar() async {
    final servicio = ref.read(backupFileServiceProvider);
    setState(() {
      _procesando = true;
      _error = null;
    });
    try {
      final archivo = await servicio.exportar();
      await servicio.compartir(archivo);
    } catch (_) {
      setState(() => _error = 'No se pudo generar el respaldo.');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _restaurar() async {
    final servicio = ref.read(backupFileServiceProvider);

    final ruta = await servicio.elegirArchivoRespaldo();
    if (ruta == null) return;

    setState(() {
      _procesando = true;
      _error = null;
    });

    BackupArchive paquete;
    try {
      paquete = await servicio.validar(ruta);
    } on BackupSchemaException catch (e) {
      setState(() => _error = e.toString());
      if (mounted) setState(() => _procesando = false);
      return;
    } on BackupFormatException catch (e) {
      setState(() => _error = e.toString());
      if (mounted) setState(() => _procesando = false);
      return;
    } catch (_) {
      setState(() => _error = 'No se pudo leer el archivo de respaldo.');
      if (mounted) setState(() => _procesando = false);
      return;
    }

    final negocioActual = await ref.read(backupDaoProvider).obtenerNegocio();
    final nombreActual = negocioActual?.nombre ?? '';

    if (!mounted) return;
    final confirmado = await _confirmarRestauracion(
      context,
      paquete: paquete,
      nombreNegocioActual: nombreActual,
    );

    if (confirmado != true) {
      setState(() => _procesando = false);
      return;
    }

    try {
      final nombreArchivo = File(ruta).uri.pathSegments.last;
      await servicio.restaurar(paquete, nombreArchivo);
      if (!mounted) return;
      await _finalizarRestauracion(context);
    } catch (_) {
      setState(() => _error = 'No se pudo restaurar el respaldo.');
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<bool?> _confirmarRestauracion(
    BuildContext context, {
    required BackupArchive paquete,
    required String nombreNegocioActual,
  }) {
    final controller = TextEditingController();
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final coincide = controller.text.trim() == nombreNegocioActual;
            return AlertDialog(
              title: const Text('Restaurar respaldo'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Respaldo de "${paquete.manifest.negocioNombre}" '
                      'generado el ${df.format(paquete.manifest.fechaCreacion.toLocal())}.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Esta acción reemplazará TODOS los datos actuales de '
                      '"$nombreNegocioActual" por los del respaldo. '
                      'No se puede deshacer.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Para confirmar, escribe el nombre del negocio actual:'
                      ' $nombreNegocioActual',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setStateDialog(() {}),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: coincide
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  child: const Text('Restaurar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// CU-12, paso 5: reinicio de sesión tras restaurar.
  Future<void> _finalizarRestauracion(BuildContext context) async {
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
    if (context.mounted) context.go(AppRoutes.splash);
  }

  @override
  Widget build(BuildContext context) {
    final historialAsync = ref.watch(historialRespaldosProvider);
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Respaldo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Genera un archivo ZIP con todos los datos y fotos del negocio '
          'para guardarlo o compartirlo (RF-RES-01).',
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          icon: const Icon(Icons.backup_outlined),
          label: const Text('Generar y compartir respaldo'),
          onPressed: _procesando ? null : _exportar,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Restauración', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Reemplaza TODOS los datos actuales con los de un archivo de '
          'respaldo (RF-RES-02). Esta acción es destructiva.',
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          icon: const Icon(Icons.restore_outlined),
          label: const Text('Restaurar desde archivo'),
          onPressed: _procesando ? null : _restaurar,
        ),
        if (_procesando) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Historial', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        historialAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) =>
              const Text('No se pudo cargar el historial de respaldos.'),
          data: (respaldos) {
            if (respaldos.isEmpty) {
              return const Text('Todavía no se han generado respaldos.');
            }
            return Column(
              children: [
                for (final respaldo in respaldos)
                  ListTile(
                    leading: Icon(
                      respaldo.resultado == 'ok'
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: respaldo.resultado == 'ok'
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                    title: Text(respaldo.archivo),
                    subtitle: Text(
                      '${df.format(respaldo.fecha.toLocal())} · '
                      '${_formatearTamano(respaldo.tamanoBytes)}',
                    ),
                  ),
              ],
            );
          },
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
