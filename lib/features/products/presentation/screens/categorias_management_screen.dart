import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
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
  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _crear() async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => const _CategoriaDialog(titulo: 'Nueva categoría'),
    );
    if (nombre == null) return;
    final resultado = await ref
        .read(productsRepositoryProvider)
        .crearCategoria(nombre);
    resultado.when(ok: (_) {}, fail: (f) => _mostrarError(f.message));
  }

  Future<void> _renombrar(Categoria categoria) async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => _CategoriaDialog(
        titulo: 'Renombrar categoría',
        valorInicial: categoria.nombre,
      ),
    );
    if (nombre == null) return;
    final resultado = await ref
        .read(productsRepositoryProvider)
        .renombrarCategoria(id: categoria.id, nombre: nombre);
    resultado.when(ok: (_) {}, fail: (f) => _mostrarError(f.message));
  }

  Future<void> _eliminar(Categoria categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar "${categoria.nombre}"? Los productos que la tengan '
          'asignada conservarán la referencia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await ref.read(productsRepositoryProvider).eliminarCategoria(categoria.id);
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crear,
        icon: const Icon(Icons.add),
        label: const Text('Categoría'),
      ),
      body: categoriasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('No se pudieron cargar las categorías.')),
        data: (categorias) {
          if (categorias.isEmpty) {
            return const Center(child: Text('Aún no hay categorías.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: categorias.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final categoria = categorias[i];
              return Card(
                child: ListTile(
                  title: Text(categoria.nombre),
                  trailing: PopupMenuButton<String>(
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
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
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
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
