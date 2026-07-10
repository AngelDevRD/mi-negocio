import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/usuario.dart';
import '../providers/auth_providers.dart';

/// Gestión de cuentas Cajero (RF-AUTH, solo Administrador): alta, reseteo de
/// contraseña y activar/desactivar.
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

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _ejecutar(Future<String?> Function() accion) async {
    setState(() => _procesando = true);
    final error = await accion();
    if (!mounted) return;
    setState(() => _procesando = false);
    if (error != null) {
      _mostrarError(error);
    } else {
      _refrescar();
    }
  }

  String? get _actorId => switch (ref.read(authControllerProvider).value) {
    SesionActiva(:final usuario) => usuario.id,
    _ => null,
  };

  Future<void> _crearCajero() async {
    final datos = await showDialog<(String, String, String)>(
      context: context,
      builder: (_) => const _CrearCajeroDialog(),
    );
    if (datos == null) return;
    final (nombre, username, password) = datos;
    await _ejecutar(() async {
      final fallo = await ref
          .read(authRepositoryProvider)
          .crearCajero(
            nombre: nombre,
            username: username,
            password: password,
            actorId: _actorId!,
          )
          .then((r) => r.when(ok: (_) => null, fail: (f) => f.message));
      return fallo;
    });
  }

  Future<void> _resetearPassword(Usuario usuario) async {
    final nueva = await showDialog<String>(
      context: context,
      builder: (_) => _ResetearPasswordDialog(usuario: usuario),
    );
    if (nueva == null) return;
    await _ejecutar(() async {
      final fallo = await ref
          .read(authRepositoryProvider)
          .resetearPassword(
            usuarioId: usuario.id,
            nuevaPassword: nueva,
            actorId: _actorId!,
          )
          .then((r) => r.when(ok: (_) => null, fail: (f) => f.message));
      return fallo;
    });
  }

  Future<void> _establecerActivo(Usuario usuario, bool activo) async {
    await _ejecutar(() async {
      final fallo = await ref
          .read(authRepositoryProvider)
          .establecerActivo(
            usuarioId: usuario.id,
            activo: activo,
            actorId: _actorId!,
          )
          .then((r) => r.when(ok: (_) => null, fail: (f) => f.message));
      return fallo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuariosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _procesando ? null : _crearCajero,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo cajero'),
      ),
      body: usuariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se pudieron cargar los usuarios.'),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _refrescar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (usuarios) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: usuarios.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) {
            final usuario = usuarios[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    usuario.esAdministrador
                        ? Icons.admin_panel_settings
                        : Icons.point_of_sale,
                  ),
                ),
                title: Text(usuario.nombre),
                subtitle: Text(
                  '${usuario.username} · ${usuario.esAdministrador ? 'Administrador' : 'Cajero'}'
                  '${usuario.activo ? '' : ' · Inactivo'}',
                ),
                trailing: _procesando
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : PopupMenuButton<String>(
                        onSelected: (accion) {
                          switch (accion) {
                            case 'reset':
                              _resetearPassword(usuario);
                            case 'activar':
                              _establecerActivo(usuario, true);
                            case 'desactivar':
                              _establecerActivo(usuario, false);
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
              ),
            );
          },
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo cajero'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
              autocorrect: false,
              validator: (v) => (v == null || v.trim().length < 3)
                  ? 'Mínimo 3 caracteres'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop((
              _nombreController.text,
              _usernameController.text,
              _passwordController.text,
            ));
          },
          child: const Text('Crear'),
        ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Restablecer contraseña — ${widget.usuario.nombre}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Nueva contraseña'),
          obscureText: true,
          autofocus: true,
          validator: (v) =>
              (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_passwordController.text);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
