import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

/// Usuario que se sugiere para el administrador (se puede cambiar).
const usuarioAdminSugerido = 'admin';

/// Wizard de primer uso (RF-AUTH): datos del negocio + creación del usuario
/// Administrador. Se muestra una sola vez, justo después de activar la
/// licencia. Solo dos pasos y lo mínimo obligatorio: el nombre del negocio y
/// la cuenta del administrador; el resto se puede completar después en
/// "Perfil y suscripción".
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
  final _usernameController = TextEditingController(text: usuarioAdminSugerido);
  final _passwordController = TextEditingController();

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
    super.dispose();
  }

  String? _opcional(TextEditingController c) {
    final texto = c.text.trim();
    return texto.isEmpty ? null : texto;
  }

  Future<void> _registrar() async {
    if (_enviando) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enviando = true);
    try {
      final fallo = await ref
          .read(authControllerProvider.notifier)
          .registrarNegocioYAdmin(
            nombreNegocio: _nombreNegocioController.text,
            identificacion: _opcional(_identificacionController),
            direccion: _opcional(_direccionController),
            telefono: _opcional(_telefonoController),
            email: _opcional(_emailController),
            nombreAdmin: _nombreAdminController.text,
            username: _usernameController.text,
            password: _passwordController.text,
          );
      if (fallo != null && mounted) {
        AppSnackbar.error(context, fallo.message);
      }
    } on Object catch (e, st) {
      // Nunca se registra la contraseña: solo el error.
      developer.log(
        'No se pudo crear el negocio',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        AppSnackbar.error(
          context,
          'No se pudo crear el negocio. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
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
                    Text(
                      'Solo dos pasos y empiezas a vender.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('1. Tu negocio', style: textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _nombreNegocioController,
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
                    const SizedBox(height: AppSpacing.xs),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      shape: const Border(),
                      collapsedShape: const Border(),
                      title: const Text('Más datos del negocio (opcional)'),
                      subtitle: const Text(
                        'RNC, dirección, teléfono y email. Los puedes '
                        'completar después.',
                      ),
                      children: [
                        TextFormField(
                          controller: _identificacionController,
                          decoration: const InputDecoration(
                            labelText: 'RNC o cédula',
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          enabled: !_enviando,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _direccionController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                          ),
                          keyboardType: TextInputType.streetAddress,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          enabled: !_enviando,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _telefonoController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          enabled: !_enviando,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_enviando,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return null;
                            return t.contains('@') && t.contains('.')
                                ? null
                                : 'Escribe un email válido';
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '2. Tu cuenta de administrador',
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _nombreAdminController,
                      decoration: const InputDecoration(labelText: 'Tu nombre'),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      enabled: !_enviando,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Escribe tu nombre'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        helperText: 'Con este nombre inicias sesión',
                      ),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      enabled: !_enviando,
                      validator: (v) => (v == null || v.trim().length < 3)
                          ? 'Mínimo 3 caracteres'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CampoPassword(
                      controller: _passwordController,
                      label: 'Contraseña',
                      helperText: 'Mínimo 6 caracteres',
                      enabled: !_enviando,
                      onEnviar: _registrar,
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
