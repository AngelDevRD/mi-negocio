import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/usuario.dart';
import '../providers/auth_providers.dart';

/// Login local (RF-AUTH): selector de usuario activo + contraseña.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _passwordController = TextEditingController();
  Usuario? _seleccionado;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final usuario = _seleccionado;
    if (usuario == null) {
      setState(() => _error = 'Selecciona un usuario.');
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    final fallo = await ref
        .read(authControllerProvider.notifier)
        .login(username: usuario.username, password: _passwordController.text);
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _error = fallo?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final usuariosAsync = ref.watch(usuariosActivosProvider);

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
                    'Iniciar sesión',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  usuariosAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        const Text('No se pudieron cargar los usuarios.'),
                    data: (usuarios) {
                      if (usuarios.isEmpty) {
                        return const Text(
                          'No hay usuarios activos. Contacta al administrador.',
                        );
                      }
                      _seleccionado ??= usuarios.first;
                      return DropdownButtonFormField<Usuario>(
                        initialValue: usuarios.contains(_seleccionado)
                            ? _seleccionado
                            : usuarios.first,
                        decoration: const InputDecoration(labelText: 'Usuario'),
                        items: [
                          for (final u in usuarios)
                            DropdownMenuItem(value: u, child: Text(u.nombre)),
                        ],
                        onChanged: _enviando
                            ? null
                            : (v) => setState(() => _seleccionado = v),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    enabled: !_enviando,
                    onSubmitted: (_) => _entrar(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _error!,
                      style: TextStyle(color: scheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _enviando ? null : _entrar,
                    child: _enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
