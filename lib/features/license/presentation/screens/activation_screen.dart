import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/license_providers.dart';

/// Mensaje que se muestra cuando algo falla sin un motivo legible.
const _errorGenerico = 'No se pudo completar la operación. Inténtalo de nuevo.';

/// Pantalla de activación (RF-LIC-01): Demo de 15 días o clave de licencia.
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _claveController = TextEditingController();

  /// Qué se está haciendo ("Activando la licencia..."), o `null`. Mientras
  /// haya algo en curso los botones quedan deshabilitados (guard doble toque).
  String? _enCurso;

  bool get _procesando => _enCurso != null;

  @override
  void dispose() {
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _ejecutar(
    String texto,
    Future<Failure?> Function() accion,
  ) async {
    if (_procesando) return;
    setState(() => _enCurso = texto);
    try {
      final fallo = await accion();
      if (fallo != null && mounted) {
        AppSnackbar.error(context, fallo.message);
      }
    } on Object catch (e, st) {
      developer.log(
        'Falló la activación',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      if (mounted) AppSnackbar.error(context, _errorGenerico);
    } finally {
      if (mounted) setState(() => _enCurso = null);
    }
  }

  Future<void> _activarDemo() => _ejecutar(
    'Preparando tu prueba gratis...',
    () => ref.read(licenseControllerProvider.notifier).activarDemo(),
  );

  Future<void> _activarClave() => _ejecutar(
    'Activando la licencia...',
    () => ref
        .read(licenseControllerProvider.notifier)
        .activarConClave(_claveController.text),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.storefront, size: 64, color: scheme.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'MiTienda 360',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Activa la aplicación para comenzar',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tengo una clave de licencia',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _claveController,
                            decoration: const InputDecoration(
                              labelText: 'Clave de licencia',
                              hintText: 'XXXX-XXXX-XXXX',
                            ),
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.visiblePassword,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _activarClave(),
                            enabled: !_procesando,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton(
                            onPressed: _procesando ? null : _activarClave,
                            child: const Text('Activar licencia'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Quiero probar la aplicación',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Demo gratis por 15 días con hasta 25 productos. '
                            'Tus datos se conservan al activar una licencia.',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton(
                            onPressed: _procesando ? null : _activarDemo,
                            child: const Text('Comenzar prueba gratis'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _procesando
                        ? null
                        : () => RequestLicenseSheet.mostrar(context, ref),
                    child: const Text('¿No tienes licencia? Solicítala aquí'),
                  ),
                  if (_enCurso != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _enCurso!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Formulario de solicitud de licencia (RF-LIC-07).
class RequestLicenseSheet extends ConsumerStatefulWidget {
  const RequestLicenseSheet({super.key});

  static void mostrar(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RequestLicenseSheet(),
    );
  }

  @override
  ConsumerState<RequestLicenseSheet> createState() =>
      RequestLicenseSheetState();
}

class RequestLicenseSheetState extends ConsumerState<RequestLicenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  String _tipoDeseado = 'local';
  bool _enviando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    String? mensaje;
    Failure? fallo;
    try {
      (mensaje, fallo) = await ref
          .read(licenseControllerProvider.notifier)
          .solicitar(
            nombreNegocio: _nombreController.text,
            telefono: _telefonoController.text.trim().isEmpty
                ? null
                : _telefonoController.text.trim(),
            tipoDeseado: _tipoDeseado,
          );
    } on Object catch (e, st) {
      developer.log(
        'Falló la solicitud de licencia',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      fallo = const ValidationFailure(_errorGenerico);
    }
    if (!mounted) return;
    setState(() => _enviando = false);
    if (fallo != null) {
      // El formulario sigue abierto: se puede corregir y reintentar.
      AppSnackbar.error(context, fallo.message);
      return;
    }
    AppSnackbar.exito(context, mensaje ?? 'Solicitud enviada.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Solicitar licencia',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del negocio',
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                enabled: !_enviando,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe el nombre de tu negocio'
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: !_enviando,
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _tipoDeseado,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Plan deseado'),
                items: const [
                  DropdownMenuItem(
                    value: 'local',
                    child: Text('Local (un dispositivo)'),
                  ),
                  DropdownMenuItem(
                    value: 'nube',
                    child: Text('Nube (con sincronización)'),
                  ),
                ],
                onChanged: _enviando
                    ? null
                    : (v) => setState(() => _tipoDeseado = v ?? 'local'),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _enviando ? null : _enviar,
                child: _enviando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enviar solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
