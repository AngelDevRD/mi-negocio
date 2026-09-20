import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
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

  /// Segundos de espera que le quedan a cada usuario bloqueado (por intentos
  /// fallidos). Un solo temporizador los descuenta a todos.
  final Map<String, int> _esperas = {};
  Timer? _cuentaRegresiva;

  int get _esperaActual => _esperas[_seleccionado?.username] ?? 0;

  @override
  void dispose() {
    _cuentaRegresiva?.cancel();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _iniciarCuentaRegresiva(String username, int segundos) {
    _esperas[username] = segundos;
    _cuentaRegresiva ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _descontar(),
    );
  }

  void _descontar() {
    if (!mounted) return;
    final terminaronAhora = <String>[];
    setState(() {
      for (final usuario in _esperas.keys.toList()) {
        final restante = _esperas[usuario]! - 1;
        if (restante <= 0) {
          _esperas.remove(usuario);
          terminaronAhora.add(usuario);
        } else {
          _esperas[usuario] = restante;
        }
      }
    });
    if (_esperas.isEmpty) {
      _cuentaRegresiva?.cancel();
      _cuentaRegresiva = null;
    }
    // El usuario elegido ya puede intentar de nuevo: foco en la contraseña.
    if (terminaronAhora.contains(_seleccionado?.username)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _passwordFocus.requestFocus();
      });
    }
  }

  Future<void> _entrar() async {
    if (_enviando || _esperaActual > 0) return;
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
    int? segundosDeEspera;
    try {
      final fallo = await ref
          .read(authControllerProvider.notifier)
          .login(
            username: usuario.username,
            password: _passwordController.text,
          );
      if (fallo is DemasiadosIntentosFailure) {
        // El mensaje lo arma la cuenta regresiva (no queda uno viejo al acabar).
        segundosDeEspera = fallo.segundos;
      } else {
        mensaje = fallo?.message;
      }
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
      if (segundosDeEspera != null) {
        _iniciarCuentaRegresiva(usuario.username, segundosDeEspera);
      }
    });
    if (mensaje != null || segundosDeEspera != null) {
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
    final espera = _esperaActual;
    // Mientras dura el bloqueo el mensaje sigue la cuenta regresiva.
    final mensajeError = espera > 0
        ? DemasiadosIntentosFailure.mensajeDeEspera(espera)
        : _error;

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
                  if (mensajeError != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      // La cuenta regresiva cambia cada segundo: no se anuncia
                      // en cada tick.
                      liveRegion: espera == 0,
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
                              mensajeError,
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
                    onPressed: _enviando || espera > 0 ? null : _entrar,
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
