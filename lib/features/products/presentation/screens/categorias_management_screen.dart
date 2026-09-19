import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/producto.dart';
import '../providers/products_providers.dart';

/// Gestión de categorías de productos (RF-PROD): alta, renombrado y
/// eliminación (soft delete).
class CategoriasManagementScreen extends ConsumerStatefulWidget {
  const CategoriasManagementScreen({super.key});

  @override
  ConsumerState<CategoriasManagementScreen> createState() =>
      _CategoriasManagementScreenState();
}

class _CategoriasManagementScreenState
    extends ConsumerState<CategoriasManagementScreen> {
  bool _procesando = false;

  Future<void> _crear() async {
    if (_procesando) return;
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => const _CategoriaDialog(titulo: 'Nueva categoría'),
    );
    if (nombre == null || !mounted) return;
    setState(() => _procesando = true);
    final resultado = await ref
        .read(productsRepositoryProvider)
        .crearCategoria(nombre);
    if (!mounted) return;
    setState(() => _procesando = false);
    resultado.when(
      ok: (_) => AppSnackbar.exito(context, 'Categoría creada.'),
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  Future<void> _renombrar(Categoria categoria) async {
    if (_procesando) return;
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => _CategoriaDialog(
        titulo: 'Renombrar categoría',
        valorInicial: categoria.nombre,
      ),
    );
    if (nombre == null || !mounted) return;
    setState(() => _procesando = true);
    final resultado = await ref
        .read(productsRepositoryProvider)
        .renombrarCategoria(id: categoria.id, nombre: nombre);
    if (!mounted) return;
    setState(() => _procesando = false);
    resultado.when(
      ok: (_) => AppSnackbar.exito(context, 'Categoría renombrada.'),
      fail: (f) => AppSnackbar.error(context, f.message),
    );
  }

  Future<void> _eliminar(Categoria categoria) async {
    if (_procesando) return;
    final confirmar = await mostrarConfirmacion(
      context,
      titulo: '¿Eliminar la categoría "${categoria.nombre}"?',
      mensaje:
          'Los productos que la tengan asignada conservarán la referencia. '
          'Esta acción no se puede deshacer.',
      confirmarLabel: 'Eliminar',
      destructivo: true,
    );
    if (!confirmar || !mounted) return;
    setState(() => _procesando = true);
    String? error;
    try {
      final resultado = await ref
          .read(productsRepositoryProvider)
          .eliminarCategoria(categoria.id);
      error = resultado.when(ok: (_) => null, fail: (f) => f.message);
    } on Object catch (e, st) {
      developer.log(
        'No se pudo eliminar la categoría',
        name: 'mi_negocio',
        error: e,
        stackTrace: st,
      );
      error = 'No se pudo eliminar la categoría. Inténtalo de nuevo.';
    }
    if (!mounted) return;
    setState(() => _procesando = false);
    if (error == null) {
      AppSnackbar.exito(context, 'Categoría "${categoria.nombre}" eliminada.');
    } else {
      AppSnackbar.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final vacia = categoriasAsync.maybeWhen(
      data: (c) => c.isEmpty,
      orElse: () => false,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: vacia
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: _procesando ? null : _crear,
              icon: const Icon(Icons.add),
              label: const Text('Categoría'),
            ),
      body: categoriasAsync.when(
        loading: () => const LoadingView(mensaje: 'Cargando categorías...'),
        error: (error, stackTrace) => ErrorState(
          mensaje: 'No se pudieron cargar las categorías.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () => ref.invalidate(categoriasProvider),
        ),
        data: (categorias) {
          if (categorias.isEmpty) {
            return EmptyState(
              icono: Icons.category_outlined,
              titulo: 'Aún no hay categorías',
              descripcion:
                  'Agrupa tus productos (bebidas, granos, limpieza...) para '
                  'encontrarlos y filtrarlos más rápido.',
              accionLabel: 'Crear categoría',
              accionPrimaria: true,
              onAccion: _crear,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              80,
            ),
            itemCount: categorias.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final categoria = categorias[i];
              return Card(
                child: ListTile(
                  title: Text(categoria.nombre),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Acciones de ${categoria.nombre}',
                    onSelected: (accion) {
                      switch (accion) {
                        case 'renombrar':
                          _renombrar(categoria);
                        case 'eliminar':
                          _eliminar(categoria);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'renombrar',
                        child: Text('Renombrar'),
                      ),
                      PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Diálogo simple para crear/renombrar una categoría.
class _CategoriaDialog extends StatefulWidget {
  const _CategoriaDialog({required this.titulo, this.valorInicial});

  final String titulo;
  final String? valorInicial;

  @override
  State<_CategoriaDialog> createState() => _CategoriaDialogState();
}

class _CategoriaDialogState extends State<_CategoriaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.valorInicial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre'),
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _guardar(),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Escribe el nombre de la categoría'
              : null,
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
