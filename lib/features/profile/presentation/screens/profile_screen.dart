import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../../license/presentation/screens/activation_screen.dart';
import '../providers/profile_providers.dart';

/// Perfil del negocio y suscripción (F18): datos editables del negocio,
/// plan/estado/vencimiento de la licencia y renovación manual.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final negocioAsync = ref.watch(negocioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil y suscripción')),
      body: negocioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('No se pudo cargar el perfil del negocio.'),
        ),
        data: (negocio) {
          if (negocio == null) {
            return const Center(child: Text('Negocio no configurado.'));
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _PerfilForm(negocio: negocio),
              const SizedBox(height: AppSpacing.lg),
              const _SuscripcionCard(),
            ],
          );
        },
      ),
    );
  }
}

/// Formulario editable del perfil del negocio (RE-05).
class _PerfilForm extends ConsumerStatefulWidget {
  const _PerfilForm({required this.negocio});

  final Negocio negocio;

  @override
  ConsumerState<_PerfilForm> createState() => _PerfilFormState();
}

class _PerfilFormState extends ConsumerState<_PerfilForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _identificacionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  String? _logoPath;
  bool _guardando = false;
  bool _inicializado = false;
  String? _error;
  String? _mensaje;

  @override
  void dispose() {
    _nombreController.dispose();
    _identificacionController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _cargarDatos(Negocio negocio) {
    if (_inicializado) return;
    _inicializado = true;
    _nombreController.text = negocio.nombre;
    _identificacionController.text = negocio.identificacion ?? '';
    _direccionController.text = negocio.direccion ?? '';
    _telefonoController.text = negocio.telefono ?? '';
    _emailController.text = negocio.email ?? '';
    _logoPath = negocio.logoPath;
  }

  Future<String> _guardarLogo(XFile archivo) async {
    final docs = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${docs.path}/negocio');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    final extension = archivo.path.contains('.')
        ? archivo.path.substring(archivo.path.lastIndexOf('.'))
        : '.jpg';
    final destino = '${carpeta.path}/${generateUuidV4()}$extension';
    await File(archivo.path).copy(destino);
    return destino;
  }

  Future<void> _elegirLogo(ImageSource origen) async {
    final archivo = await ImagePicker().pickImage(
      source: origen,
      imageQuality: 80,
    );
    if (archivo == null) return;
    final ruta = await _guardarLogo(archivo);
    if (!mounted) return;
    setState(() => _logoPath = ruta);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = ref.read(authControllerProvider).value;
    final actorId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (actorId == null) {
      setState(() => _error = 'No hay una sesión activa.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
      _mensaje = null;
    });

    final identificacion = _identificacionController.text.trim();
    final direccion = _direccionController.text.trim();
    final telefono = _telefonoController.text.trim();
    final email = _emailController.text.trim();

    try {
      await ref
          .read(profileLocalDatasourceProvider)
          .actualizarPerfil(
            actual: widget.negocio,
            nombre: _nombreController.text.trim(),
            identificacion: identificacion.isEmpty ? null : identificacion,
            direccion: direccion.isEmpty ? null : direccion,
            telefono: telefono.isEmpty ? null : telefono,
            email: email.isEmpty ? null : email,
            logoPath: _logoPath,
            actorId: actorId,
          );
      if (!mounted) return;
      setState(() => _mensaje = 'Perfil actualizado.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _cargarDatos(widget.negocio);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Datos del negocio',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LogoPicker(
                rutaLogo: _logoPath,
                onTomarFoto: () => _elegirLogo(ImageSource.camera),
                onElegirGaleria: () => _elegirLogo(ImageSource.gallery),
                onQuitar: () => setState(() => _logoPath = null),
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
                controller: _identificacionController,
                decoration: const InputDecoration(
                  labelText: 'RNC o cédula (opcional)',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección (opcional)',
                ),
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
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (opcional)',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_mensaje != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_mensaje!),
              ],
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({
    required this.rutaLogo,
    required this.onTomarFoto,
    required this.onElegirGaleria,
    required this.onQuitar,
  });

  final String? rutaLogo;
  final VoidCallback onTomarFoto;
  final VoidCallback onElegirGaleria;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          if (rutaLogo != null)
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: FileImage(File(rutaLogo!)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filledTonal(
                    onPressed: onQuitar,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            )
          else
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.storefront_outlined, size: 48),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Platform.isAndroid || Platform.isIOS)
                OutlinedButton.icon(
                  onPressed: onTomarFoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Tomar foto'),
                ),
              if (Platform.isAndroid || Platform.isIOS)
                const SizedBox(width: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: onElegirGaleria,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de suscripción (F18): plan actual, estado, vencimiento y
/// renovación manual.
class _SuscripcionCard extends ConsumerStatefulWidget {
  const _SuscripcionCard();

  @override
  ConsumerState<_SuscripcionCard> createState() => _SuscripcionCardState();
}

class _SuscripcionCardState extends ConsumerState<_SuscripcionCard> {
  bool _renovando = false;
  bool _activando = false;
  final _claveController = TextEditingController();

  @override
  void dispose() {
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _renovar() async {
    setState(() => _renovando = true);
    final (mensaje, fallo) = await ref
        .read(licenseControllerProvider.notifier)
        .renovar();
    if (!mounted) return;
    setState(() => _renovando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje ?? fallo!.message),
        backgroundColor: fallo != null
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
  }

  /// Activa o cambia de plan (p. ej. Demo -> Local/Nube) sin cerrar sesión.
  Future<void> _activarClave() async {
    final clave = _claveController.text.trim();
    if (clave.isEmpty) return;
    setState(() => _activando = true);
    final fallo = await ref
        .read(licenseControllerProvider.notifier)
        .activarConClave(clave);
    if (!mounted) return;
    setState(() => _activando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fallo?.message ?? 'Licencia activada correctamente.'),
        backgroundColor: fallo != null
            ? Theme.of(context).colorScheme.error
            : null,
      ),
    );
    if (fallo == null) _claveController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final check = ref.watch(licenseControllerProvider).value;
    final licencia = switch (check) {
      LicenciaActiva(:final licencia) => licencia,
      LicenciaBloqueada(:final licencia) => licencia,
      _ => null,
    };

    if (licencia == null) {
      return const SizedBox.shrink();
    }

    final formatoFecha = DateFormat('dd/MM/yyyy');
    final dias = licencia.diasParaVencer(DateTime.now().toUtc());
    final mostrarAlerta = dias != null && dias <= diasAlertaRenovacion;
    final esDemo = licencia.tipo == TipoLicencia.demo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Suscripción', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(etiqueta: 'Plan', valor: _tipoLabel(licencia.tipo)),
            _InfoRow(etiqueta: 'Estado', valor: _estadoLabel(licencia.estado)),
            _InfoRow(
              etiqueta: 'Activación',
              valor: formatoFecha.format(licencia.fechaActivacion.toLocal()),
            ),
            if (licencia.fechaVencimiento != null)
              _InfoRow(
                etiqueta: 'Próximo vencimiento',
                valor: formatoFecha.format(
                  licencia.fechaVencimiento!.toLocal(),
                ),
              ),
            if (mostrarAlerta) ...[
              const SizedBox(height: AppSpacing.sm),
              _AlertaVencimiento(dias: dias),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              'Activar o cambiar de plan',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              esDemo
                  ? 'Ingresa la clave que te dio el propietario para pasar '
                        'de Demo a Local o Nube, sin perder tus datos.'
                  : 'Ingresa una nueva clave para cambiar el plan de esta '
                        'licencia.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _claveController,
              decoration: const InputDecoration(
                labelText: 'Clave de licencia',
                hintText: 'AGN-XXXX-XXXX-XXXX',
              ),
              textCapitalization: TextCapitalization.characters,
              enabled: !_activando,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonal(
              onPressed: _activando ? null : _activarClave,
              child: _activando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Activar / cambiar licencia'),
            ),
            if (!esDemo) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _renovando ? null : _renovar,
                child: _renovando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Renovar'),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => RequestLicenseSheet.mostrar(context, ref),
              child: const Text('Solicitar una licencia al propietario'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertaVencimiento extends StatelessWidget {
  const _AlertaVencimiento({required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mensaje = dias <= 0
        ? 'Tu suscripción venció. Renueva para evitar interrupciones.'
        : 'Tu suscripción vence en $dias ${dias == 1 ? 'día' : 'días'}.';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: scheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            valor,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

String _tipoLabel(TipoLicencia tipo) => switch (tipo) {
  TipoLicencia.demo => 'Demo',
  TipoLicencia.local => 'Local',
  TipoLicencia.nube => 'Nube',
};

String _estadoLabel(EstadoLicencia estado) => switch (estado) {
  EstadoLicencia.pendiente => 'Pendiente',
  EstadoLicencia.activa => 'Activa',
  EstadoLicencia.suspendida => 'Suspendida',
  EstadoLicencia.vencida => 'Vencida',
  EstadoLicencia.transferida => 'Transferida',
};
