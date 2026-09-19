import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/usuario.dart';
import '../providers/auth_providers.dart';

/// Login local (RF-AUTH): selector de usuario activo + contraseña.
///
/// El foco inicial está en la contraseña (el usuario ya viene elegido) y
/// Enter envía. Ante credenciales inválidas se muestra siempre el MISMO
/// mensaje del repositorio, sin distinguir entre usuario y contraseña.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  Usuario? _seleccionado;
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_enviando) return;
    final usuario = _seleccionado;
    if (usuario == null) {
      setState(() => _error = 'Selecciona un usuario.');
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    String? mensaje;
    try {
      final fallo = await ref
          .read(authControllerProvider.notifier)
          .login(
            username: usuario.username,
            password: _passwordController.text,
          );
      mensaje = fallo?.message;
    } on Object catch (e, st) {
      // Solo el error; nunca la contraseña.
      developer.log(
        'No se pudo iniciar sesión',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      mensaje = 'No se pudo iniciar sesión. Inténtalo de nuevo.';
    }
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _error = mensaje;
    });
    if (mensaje != null) {
      // Se borra lo escrito y se vuelve a la contraseña para reintentar.
      _passwordController.clear();
      // El campo se rehabilita en el próximo cuadro: se pide el foco después.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _passwordFocus.requestFocus();
      });
    }
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
                    'Mi Negocio',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Inicia sesión para continuar',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  usuariosAsync.when(
                    loading: () => const SizedBox(
                      height: 96,
                      child: LoadingView(mensaje: 'Cargando usuarios...'),
                    ),
                    error: (error, stackTrace) => ErrorState(
                      compacto: true,
                      mensaje: 'No se pudieron cargar los usuarios.',
                      error: error,
                      stackTrace: stackTrace,
                      onReintentar: () => ref.invalidate(usuariosProvider),
                    ),
                    data: (usuarios) {
                      if (usuarios.isEmpty) {
                        return const EmptyState(
                          compacto: true,
                          icono: Icons.person_off_outlined,
                          titulo: 'No hay usuarios activos',
                          descripcion:
                              'Pide al administrador que active tu '
                              'cuenta.',
                        );
                      }
                      _seleccionado ??= usuarios.first;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<Usuario>(
                            initialValue: usuarios.contains(_seleccionado)
                                ? _seleccionado
                                : usuarios.first,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Usuario',
                            ),
                            items: [
                              for (final u in usuarios)
                                DropdownMenuItem(
                                  value: u,
                                  child: Text(u.nombre),
                                ),
                            ],
                            onChanged: _enviando
                                ? null
                                : (v) => setState(() => _seleccionado = v),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          CampoPassword(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            autofocus: true,
                            enabled: !_enviando,
                            onEnviar: _entrar,
                          ),
                        ],
                      );
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      liveRegion: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 18,
                            color: scheme.error,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              _error!,
                              style: TextStyle(color: scheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
