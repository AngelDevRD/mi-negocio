import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/usuario.dart';
import '../providers/auth_providers.dart';

/// Gestión de cuentas Cajero (RF-AUTH, solo Administrador): alta, reseteo de
/// contraseña y activar/desactivar.
///
/// Las contraseñas SOLO viajan del diálogo al repositorio: nunca se muestran
/// en un snackbar, ni se registran en logs.
class UsersManagementScreen extends ConsumerStatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  ConsumerState<UsersManagementScreen> createState() =>
      _UsersManagementScreenState();
}

class _UsersManagementScreenState extends ConsumerState<UsersManagementScreen> {
  bool _procesando = false;

  void _refrescar() {
    ref.invalidate(usuariosProvider);
  }

  /// Ejecuta [accion] (devuelve el mensaje de error, o `null` si salió bien)
  /// con el guard [_procesando]. Con éxito refresca la lista y muestra
  /// [exito].
  Future<void> _ejecutar(
    Future<String?> Function() accion,
    String exito,
  ) async {
    if (_procesando) return;
    setState(() => _procesando = true);
    final error = await accion();
    if (!mounted) return;
    setState(() => _procesando = false);
    if (error != null) {
      AppSnackbar.error(context, error);
    } else {
      _refrescar();
      AppSnackbar.exito(context, exito);
    }
  }

  String? get _actorId => switch (ref.read(authControllerProvider).value) {
    SesionActiva(:final usuario) => usuario.id,
    _ => null,
  };

  Future<void> _crearCajero() async {
    if (_procesando) return;
    final datos = await showDialog<(String, String, String)>(
      context: context,
      builder: (_) => const _CrearCajeroDialog(),
    );
    if (datos == null || !mounted) return;
    final (nombre, username, password) = datos;
    await _ejecutar(
      () => ref
          .read(authRepositoryProvider)
          .crearCajero(
            nombre: nombre,
            username: username,
            password: password,
            actorId: _actorId!,
          )
          .then((r) => r.when(ok: (_) => null, fail: (f) => f.message)),
      'Cajero creado. Ya puede iniciar sesión.',
    );
  }

  Future<void> _resetearPassword(Usuario usuario) async {
    if (_procesando) return;
    final confirmado = await mostrarConfirmacion(
      context,
      titulo: '¿Restablecer la contraseña?',
      mensaje:
          'La contraseña actual de ${usuario.nombre} dejará de funcionar. '
          'A continuación escribirás la nueva.',
      confirmarLabel: 'Continuar',
    );
    if (!confirmado || !mounted) return;
    final nueva = await showDialog<String>(
      context: context,
      builder: (_) => _ResetearPasswordDialog(usuario: usuario),
    );
    if (nueva == null || !mounted) return;
    await _ejecutar(
      () => ref
          .read(authRepositoryProvider)
          .resetearPassword(
            usuarioId: usuario.id,
            nuevaPassword: nueva,
            actorId: _actorId!,
          )
          .then((r) => r.when(ok: (_) => null, fail: (f) => f.message)),
      'Contraseña de ${usuario.nombre} restablecida.',
    );
  }

  Future<void> _establecerActivo(Usuario usuario, bool activo) async {
    if (_procesando) return;
    final confirmado = await mostrarConfirmacion(
      context,
      titulo: activo
          ? '¿Activar a ${usuario.nombre}?'
          : '¿Desactivar a ${usuario.nombre}?',
      mensaje: activo
          ? 'Podrá volver a iniciar sesión.'
          : 'No podrá iniciar sesión hasta que lo actives de nuevo. Sus '
                'ventas y su historial se conservan.',
      confirmarLabel: activo ? 'Activar' : 'Desactivar',
      destructivo: !activo,
    );
    if (!confirmado || !mounted) return;
    await _ejecutar(
      () => ref
          .read(authRepositoryProvider)
          .establecerActivo(
            usuarioId: usuario.id,
            activo: activo,
            actorId: _actorId!,
          )
          .then((r) => r.when(ok: (_) => null, fail: (f) => f.message)),
      activo ? '${usuario.nombre} activado.' : '${usuario.nombre} desactivado.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuariosProvider);
    final vacia = usuariosAsync.maybeWhen(
      data: (u) => u.isEmpty,
      orElse: () => false,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: vacia
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: _procesando ? null : _crearCajero,
              icon: const Icon(Icons.person_add),
              label: const Text('Nuevo cajero'),
            ),
      body: usuariosAsync.when(
        loading: () => const LoadingView(mensaje: 'Cargando usuarios...'),
        error: (error, stackTrace) => ErrorState(
          mensaje: 'No se pudieron cargar los usuarios.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: _refrescar,
        ),
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return EmptyState(
              icono: Icons.group_outlined,
              titulo: 'Aún no hay usuarios',
              descripcion:
                  'Crea una cuenta de cajero para que otra persona pueda '
                  'vender sin ver las ganancias del negocio.',
              accionLabel: 'Nuevo cajero',
              accionPrimaria: true,
              onAccion: _crearCajero,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              80,
            ),
            itemCount: usuarios.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => _UsuarioTile(
              usuario: usuarios[i],
              procesando: _procesando,
              onResetear: () => _resetearPassword(usuarios[i]),
              onActivo: (activo) => _establecerActivo(usuarios[i], activo),
            ),
          );
        },
      ),
    );
  }
}

class _UsuarioTile extends StatelessWidget {
  const _UsuarioTile({
    required this.usuario,
    required this.procesando,
    required this.onResetear,
    required this.onActivo,
  });

  final Usuario usuario;
  final bool procesando;
  final VoidCallback onResetear;
  final ValueChanged<bool> onActivo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: usuario.activo
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
              child: Icon(
                usuario.esAdministrador
                    ? Icons.admin_panel_settings_outlined
                    : Icons.point_of_sale,
                color: usuario.activo
                    ? scheme.onPrimaryContainer
                    : scheme.outline,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Usuario: ${usuario.username}',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (usuario.esAdministrador)
                        const EtiquetaEstado(
                          icono: Icons.admin_panel_settings_outlined,
                          texto: 'Administrador',
                        )
                      else
                        const EtiquetaEstado(
                          icono: Icons.point_of_sale,
                          texto: 'Cajero',
                        ),
                      EtiquetaActivo(activo: usuario.activo),
                    ],
                  ),
                ],
              ),
            ),
            if (procesando)
              const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              PopupMenuButton<String>(
                tooltip: 'Acciones de ${usuario.nombre}',
                onSelected: (accion) {
                  switch (accion) {
                    case 'reset':
                      onResetear();
                    case 'activar':
                      onActivo(true);
                    case 'desactivar':
                      onActivo(false);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Text('Restablecer contraseña'),
                  ),
                  if (usuario.activo)
                    const PopupMenuItem(
                      value: 'desactivar',
                      child: Text('Desactivar'),
                    )
                  else
                    const PopupMenuItem(
                      value: 'activar',
                      child: Text('Activar'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Campo de contraseña con botón mostrar/ocultar. El texto vive solo en el
/// [controller]; nunca se registra ni se muestra fuera del propio campo.
class _CampoPassword extends StatefulWidget {
  const _CampoPassword({
    required this.controller,
    required this.label,
    required this.onEnviar,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onEnviar;
  final bool autofocus;

  @override
  State<_CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<_CampoPassword> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: widget.autofocus,
      obscureText: _oculta,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => widget.onEnviar(),
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: 'Mínimo 6 caracteres',
        suffixIcon: IconButton(
          tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(
            _oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
      validator: (v) =>
          (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
    );
  }
}

class _CrearCajeroDialog extends StatefulWidget {
  const _CrearCajeroDialog();

  @override
  State<_CrearCajeroDialog> createState() => _CrearCajeroDialogState();
}

class _CrearCajeroDialogState extends State<_CrearCajeroDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _crear() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((
      _nombreController.text,
      _usernameController.text,
      _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Nuevo cajero'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Escribe el nombre del cajero'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                helperText: 'Con este nombre inicia sesión',
              ),
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Mínimo 3 caracteres'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            _CampoPassword(
              controller: _passwordController,
              label: 'Contraseña',
              onEnviar: _crear,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _crear, child: const Text('Crear')),
      ],
    );
  }
}

class _ResetearPasswordDialog extends StatefulWidget {
  const _ResetearPasswordDialog({required this.usuario});

  final Usuario usuario;

  @override
  State<_ResetearPasswordDialog> createState() =>
      _ResetearPasswordDialogState();
}

class _ResetearPasswordDialogState extends State<_ResetearPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text('Nueva contraseña — ${widget.usuario.nombre}'),
      content: Form(
        key: _formKey,
        child: _CampoPassword(
          controller: _passwordController,
          label: 'Nueva contraseña',
          autofocus: true,
          onEnviar: _guardar,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
