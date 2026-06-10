import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/license_providers.dart';

/// Pantalla de activación (RF-LIC-01): Demo de 15 días o clave de licencia.
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _claveController = TextEditingController();
  bool _procesando = false;

  @override
  void dispose() {
    _claveController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    setState(() => _procesando = true);
    try {
      await accion();
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _activarDemo() => _ejecutar(() async {
    final fallo = await ref
        .read(licenseControllerProvider.notifier)
        .activarDemo();
    if (fallo != null) _mostrarMensaje(fallo.message, error: true);
  });

  Future<void> _activarClave() => _ejecutar(() async {
    final fallo = await ref
        .read(licenseControllerProvider.notifier)
        .activarConClave(_claveController.text);
    if (fallo != null) _mostrarMensaje(fallo.message, error: true);
  });

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
                    'App Gestión Negocios',
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
                        : () => _RequestLicenseSheet.mostrar(context, ref),
                    child: const Text('¿No tienes licencia? Solicítala aquí'),
                  ),
                  if (_procesando) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Center(child: CircularProgressIndicator()),
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
class _RequestLicenseSheet extends ConsumerStatefulWidget {
  const _RequestLicenseSheet();

  static void mostrar(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _RequestLicenseSheet(),
    );
  }

  @override
  ConsumerState<_RequestLicenseSheet> createState() =>
      _RequestLicenseSheetState();
}

class _RequestLicenseSheetState extends ConsumerState<_RequestLicenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  String _tipoDeseado = 'local';
  bool _enviando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    final (mensaje, fallo) = await ref
        .read(licenseControllerProvider.notifier)
        .solicitar(
          nombreNegocio: _nombreController.text,
          emailAdmin: _emailController.text,
          telefono: _telefonoController.text.isEmpty
              ? null
              : _telefonoController.text,
          tipoDeseado: _tipoDeseado,
        );
    if (!mounted) return;
    setState(() => _enviando = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje ?? fallo!.message),
        backgroundColor: fallo != null
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
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
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email del administrador',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Email inválido' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _tipoDeseado,
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
              onChanged: (v) => setState(() => _tipoDeseado = v ?? 'local'),
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
    );
  }
}
