import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/database/tables/base.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/empleado.dart';
import '../providers/employees_providers.dart';

/// Alta/edición de la ficha de un empleado de ventas o delivery (RF-EMP-02).
class EmployeeFormScreen extends ConsumerStatefulWidget {
  const EmployeeFormScreen({super.key, this.employeeId, this.tipoInicial});

  final String? employeeId;

  /// Tipo preseleccionado al crear, según la pestaña activa en la lista.
  final TipoEmpleado? tipoInicial;

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _salarioController = TextEditingController();

  TipoEmpleado _tipo = TipoEmpleado.ventas;
  String? _fotoPath;
  DateTime _fechaIngreso = DateTime.now();
  String? _frecuenciaPago;
  bool _guardando = false;
  bool _inicializado = false;

  /// Hubo algún cambio del usuario sin guardar (salir pide confirmación).
  bool _modificado = false;

  /// El guardado terminó: se puede salir sin preguntar.
  bool _salidaLibre = false;

  bool get _esEdicion => widget.employeeId != null;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial ?? TipoEmpleado.ventas;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _salarioController.dispose();
    super.dispose();
  }

  void _cargarDatos(Empleado empleado) {
    if (_inicializado) return;
    _inicializado = true;
    _tipo = empleado.tipo;
    _fotoPath = empleado.fotoPath;
    _nombreController.text = empleado.nombre;
    _cedulaController.text = empleado.cedula ?? '';
    _direccionController.text = empleado.direccion ?? '';
    _telefonoController.text = empleado.telefono ?? '';
    _fechaIngreso = empleado.fechaIngreso;
    _frecuenciaPago = empleado.frecuenciaPago;
    if (empleado.salario != null) {
      _salarioController.text = empleado.salario!.format(symbol: false);
    }
  }

  void _marcarModificado() {
    if (!_modificado) setState(() => _modificado = true);
  }

  Future<void> _confirmarSalida() async {
    final descartar = await mostrarConfirmacion(
      context,
      titulo: '¿Descartar cambios?',
      mensaje: 'Tienes datos sin guardar. Si sales ahora, se pierden.',
      confirmarLabel: 'Descartar',
      cancelarLabel: 'Seguir editando',
      destructivo: true,
    );
    if (!descartar || !mounted) return;
    setState(() => _salidaLibre = true);
    context.pop();
  }

  Future<String> _guardarFoto(XFile archivo) async {
    final docs = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${docs.path}/empleados');
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

  Future<void> _elegirFoto(ImageSource origen) async {
    final archivo = await ImagePicker().pickImage(
      source: origen,
      imageQuality: 80,
    );
    if (archivo == null) return;
    final ruta = await _guardarFoto(archivo);
    if (!mounted) return;
    setState(() {
      _fotoPath = ruta;
      _modificado = true;
    });
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso,
      firstDate: DateTime(ahora.year - 50),
      lastDate: ahora,
    );
    if (fecha == null) return;
    setState(() {
      _fechaIngreso = fecha;
      _modificado = true;
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!_formKey.currentState!.validate()) return;

    final usuario = ref.read(authControllerProvider).value;
    final usuarioId = switch (usuario) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null) {
      AppSnackbar.error(context, 'No hay una sesión activa.');
      return;
    }

    setState(() => _guardando = true);

    final repo = ref.read(employeesRepositoryProvider);
    final salarioTexto = _salarioController.text.trim();
    final salario = salarioTexto.isEmpty ? null : Money.tryParse(salarioTexto);
    final cedula = _cedulaController.text.trim();
    final direccion = _direccionController.text.trim();
    final telefono = _telefonoController.text.trim();

    final resultado = _esEdicion
        ? await repo.actualizarEmpleado(
            id: widget.employeeId!,
            tipo: _tipo,
            fotoPath: _fotoPath,
            nombre: _nombreController.text,
            cedula: cedula.isEmpty ? null : cedula,
            direccion: direccion.isEmpty ? null : direccion,
            telefono: telefono.isEmpty ? null : telefono,
            fechaIngreso: _fechaIngreso.toUtc(),
            salario: salario,
            frecuenciaPago: _frecuenciaPago,
            usuarioId: usuarioId,
          )
        : await repo.crearEmpleado(
            tipo: _tipo,
            fotoPath: _fotoPath,
            nombre: _nombreController.text,
            cedula: cedula.isEmpty ? null : cedula,
            direccion: direccion.isEmpty ? null : direccion,
            telefono: telefono.isEmpty ? null : telefono,
            fechaIngreso: _fechaIngreso.toUtc(),
            salario: salario,
            frecuenciaPago: _frecuenciaPago,
            usuarioId: usuarioId,
          );

    if (!mounted) return;
    setState(() => _guardando = false);
    resultado.when(
      ok: (_) {
        if (_esEdicion) ref.invalidate(empleadoProvider(widget.employeeId!));
        AppSnackbar.exito(context, 'Empleado guardado.');
        setState(() => _salidaLibre = true);
        context.pop();
      },
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empleadoAsync = _esEdicion
        ? ref.watch(empleadoProvider(widget.employeeId!))
        : null;

    if (empleadoAsync != null) {
      return empleadoAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Editar empleado')),
          body: const LoadingView(mensaje: 'Cargando empleado...'),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(title: const Text('Editar empleado')),
          body: ErrorState(
            mensaje: 'No se pudo cargar el empleado.',
            error: error,
            stackTrace: stackTrace,
            onReintentar: () =>
                ref.invalidate(empleadoProvider(widget.employeeId!)),
          ),
        ),
        data: (empleado) {
          if (empleado == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Editar empleado')),
              body: const EmptyState(
                icono: Icons.person_off_outlined,
                titulo: 'Empleado no encontrado',
                descripcion: 'Puede que ya no exista. Vuelve a la lista.',
              ),
            );
          }
          _cargarDatos(empleado);
          return _buildForm(context);
        },
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return PopScope(
      canPop: _salidaLibre || !_modificado,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarSalida();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_esEdicion ? 'Editar empleado' : 'Nuevo empleado'),
        ),
        body: Form(
          key: _formKey,
          onChanged: _marcarModificado,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _FotoPicker(
                rutaFoto: _fotoPath,
                onTomarFoto: () => _elegirFoto(ImageSource.camera),
                onElegirGaleria: () => _elegirFoto(ImageSource.gallery),
                onQuitar: () => setState(() => _fotoPath = null),
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<TipoEmpleado>(
                segments: const [
                  ButtonSegment(
                    value: TipoEmpleado.ventas,
                    label: Text('Ventas'),
                  ),
                  ButtonSegment(
                    value: TipoEmpleado.delivery,
                    label: Text('Delivery'),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: (seleccion) => setState(() {
                  _tipo = seleccion.first;
                  _modificado = true;
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe el nombre del empleado'
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula (opcional)',
                  hintText: '000-0000000-0',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (!formatoCedulaRD.hasMatch(v.trim())) {
                    return 'Formato 000-0000000-0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección (opcional)',
                ),
                keyboardType: TextInputType.streetAddress,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de ingreso'),
                subtitle: Text(formatoFecha.format(_fechaIngreso)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _elegirFecha,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _salarioController,
                decoration: const InputDecoration(
                  labelText: 'Salario (opcional)',
                  prefixText: 'RD\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final monto = Money.tryParse(v);
                  if (monto == null || monto.isNegative) {
                    return 'Monto inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String?>(
                initialValue: _frecuenciaPago,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia de pago (opcional)',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Sin definir'),
                  ),
                  for (final frecuencia in frecuenciasPagoPredefinidas)
                    DropdownMenuItem(
                      value: frecuencia,
                      child: Text(frecuencia),
                    ),
                ],
                onChanged: (valor) => setState(() {
                  _frecuenciaPago = valor;
                  _modificado = true;
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
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

class _FotoPicker extends StatelessWidget {
  const _FotoPicker({
    required this.rutaFoto,
    required this.onTomarFoto,
    required this.onElegirGaleria,
    required this.onQuitar,
  });

  final String? rutaFoto;
  final VoidCallback onTomarFoto;
  final VoidCallback onElegirGaleria;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          if (rutaFoto != null)
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: FileImage(File(rutaFoto!)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton.filledTonal(
                    tooltip: 'Quitar foto',
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
              child: const Icon(Icons.person_outline, size: 48),
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
