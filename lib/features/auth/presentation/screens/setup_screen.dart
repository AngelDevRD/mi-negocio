import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';

/// Wizard de primer uso (RF-AUTH): datos del negocio + creación del usuario
/// Administrador. Se muestra una sola vez, justo después de activar la
/// licencia.
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreNegocioController = TextEditingController();
  final _identificacionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  final _nombreAdminController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _enviando = false;

  @override
  void dispose() {
    _nombreNegocioController.dispose();
    _identificacionController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _nombreAdminController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Las contraseñas no coinciden.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    setState(() => _enviando = true);
    final fallo = await ref
        .read(authControllerProvider.notifier)
        .registrarNegocioYAdmin(
          nombreNegocio: _nombreNegocioController.text,
          identificacion: _identificacionController.text.isEmpty
              ? null
              : _identificacionController.text,
          direccion: _direccionController.text.isEmpty
              ? null
              : _direccionController.text,
          telefono: _telefonoController.text.isEmpty
              ? null
              : _telefonoController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          nombreAdmin: _nombreAdminController.text,
          username: _usernameController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (fallo != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallo.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración inicial')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Datos del negocio', style: textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _nombreNegocioController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del negocio',
                      ),
                      enabled: !_enviando,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Obligatorio'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _identificacionController,
                      decoration: const InputDecoration(
                        labelText: 'RNC o cédula (opcional)',
                      ),
                      enabled: !_enviando,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección (opcional)',
                      ),
                      enabled: !_enviando,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono (opcional)',
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !_enviando,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (opcional)',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_enviando,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Cuenta del administrador',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _nombreAdminController,
                      decoration: const InputDecoration(labelText: 'Tu nombre'),
                      enabled: !_enviando,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Obligatorio'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Usuario'),
                      autocorrect: false,
                      enabled: !_enviando,
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Mínimo 3 caracteres'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                      ),
                      obscureText: true,
                      enabled: !_enviando,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _confirmarController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                      ),
                      obscureText: true,
                      enabled: !_enviando,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: _enviando ? null : _registrar,
                      child: _enviando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear negocio y comenzar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
