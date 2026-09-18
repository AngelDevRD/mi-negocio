import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/money_text.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/domain/entities/producto.dart';
import '../../domain/entities/venta.dart';
import '../providers/sales_providers.dart';

bool _esAdministrador(WidgetRef ref) =>
    switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.esAdministrador,
      _ => false,
    };

// ---------------------------------------------------------------------------
// Flujo: agregar producto y cobrar
// ---------------------------------------------------------------------------

/// Pide cantidad o monto de [producto] y lo agrega al carrito. Si la cantidad
/// pedida (sumada a lo ya agregado) supera la existencia, advierte y deja
/// continuar (RN-12: la venta con stock insuficiente se permite tras aviso).
Future<void> agregarProductoAlCarrito(
  BuildContext context,
  WidgetRef ref,
  Producto producto,
) async {
  final item = await showDialog<ItemVentaInput>(
    context: context,
    builder: (_) => CantidadMontoDialog(producto: producto),
  );
  if (item == null || !context.mounted) return;

  final enCarrito = ref
      .read(carritoVentaProvider)
      .items
      .where((i) => i.productoId == producto.id)
      .fold<double>(0, (suma, i) => suma + i.cantidad);

  if (producto.stockActual - (enCarrito + item.cantidad) < 0) {
    final continuar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stock insuficiente'),
        content: Text(
          '"${producto.nombre}" tiene ${producto.stockActual.toStringAsFixed(2)} '
          '${producto.unidad} en existencia. ¿Continuar de todos modos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (continuar != true) return;
  }
  if (!context.mounted) return;

  ref.read(carritoVentaProvider.notifier).agregarItem(item);
}

/// Cobra el carrito: pide el monto recibido, registra la venta y limpia el
/// carrito. Devuelve `true` si la venta quedó registrada.
///
/// Solo puede haber un cobro a la vez ([faseCobroProvider]): el guard se
/// toma de forma síncrona al pulsar "Cobrar", así que un doble toque no lanza
/// dos ventas. Si el registro falla, el carrito se conserva intacto.
Future<bool> cobrarVenta(BuildContext context, WidgetRef ref) async {
  if (ref.read(faseCobroProvider) != FaseCobro.libre) return false;
  // Se capturan antes de los await: la barra puede desmontarse al vaciarse el
  // carrito y el guard debe liberarse igual.
  final fase = ref.read(faseCobroProvider.notifier);
  final carrito = ref.read(carritoVentaProvider.notifier);
  final registrar = carrito.registrar;
  fase.establecer(FaseCobro.ingresandoMonto);
  try {
    final total = ref.read(carritoVentaProvider).total;
    final recibido = await showDialog<Money>(
      context: context,
      builder: (_) => CobroDialog(total: total),
    );
    if (recibido == null) return false;

    final usuarioId = switch (ref.read(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario.id,
      _ => null,
    };
    if (usuarioId == null || !context.mounted) return false;

    fase.establecer(FaseCobro.registrando);
    final Result<String> resultado;
    try {
      resultado = await registrar(tipo: TipoVenta.rapida, usuarioId: usuarioId);
    } catch (error, stackTrace) {
      // Excepción inesperada (p.ej. base de datos): no se sabe si la venta se
      // guardó, así que el carrito se conserva intacto y se avisa.
      developer.log(
        'Excepción al registrar la venta',
        name: 'mi_negocio',
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        AppSnackbar.error(
          context,
          'No se pudo registrar la venta. Intenta de nuevo.',
        );
      }
      return false;
    }

    // La venta ya quedó guardada: el carrito se limpia SIEMPRE, esté o no
    // montada la pantalla (el carrito es global; si no, los mismos productos
    // podrían cobrarse dos veces). Solo el aviso depende del contexto.
    return resultado.when(
      ok: (_) {
        carrito.limpiar();
        if (context.mounted) {
          final cambio = recibido - total;
          AppSnackbar.exito(
            context,
            'Venta registrada · Cambio ${cambio.format()}',
          );
        }
        return true;
      },
      fail: (f) {
        if (context.mounted) AppSnackbar.error(context, f.message);
        return false;
      },
    );
  } finally {
    fase.establecer(FaseCobro.libre);
  }
}

// ---------------------------------------------------------------------------
// Catálogo
// ---------------------------------------------------------------------------

/// Alto de una tarjeta de producto: escala con el tamaño de texto del sistema
/// para que nombre (2 líneas), precio y stock no desborden con texto grande.
double alturaTarjetaProducto(BuildContext context) {
  const relleno = AppSpacing.sm * 2 + AppSpacing.xs;
  // nombre 2 líneas + precio + stock + "En carrito", a escala 1.0
  const texto = 100.0;
  return relleno + MediaQuery.textScalerOf(context).scale(texto) + 4;
}

/// Tarjeta compacta de producto: nombre, precio y disponibilidad (con texto,
/// no solo color).
class ProductoPosTile extends StatelessWidget {
  const ProductoPosTile({
    super.key,
    required this.producto,
    required this.onTap,
    this.enCarrito = 0,
  });

  final Producto producto;
  final VoidCallback onTap;

  /// Cantidad de este producto ya en el carrito (0 = no está).
  final double enCarrito;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sinStock = producto.stockActual <= 0;
    final bajo = !sinStock && producto.stockBajo;
    final etiquetaStock = sinStock
        ? 'Sin stock'
        : bajo
        ? 'Stock bajo: ${formatoCantidad(producto.stockActual)}'
        : formatoCantidadUnidad(producto.stockActual, producto.unidad);
    final seleccionado = enCarrito > 0;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      // Borde primario además del texto "En carrito": no solo color.
      shape: seleccionado
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              side: BorderSide(color: scheme.primary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                producto.nombre,
                style: textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoneyText(
                    producto.precioVenta,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      if (sinStock || bajo) ...[
                        Icon(
                          sinStock
                              ? Icons.block_outlined
                              : Icons.warning_amber_outlined,
                          size: 14,
                          color: sinStock
                              ? scheme.error
                              : context.appColors.advertencia,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Flexible(
                        child: Text(
                          etiquetaStock,
                          style: textTheme.bodySmall?.copyWith(
                            color: sinStock
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                            fontWeight: sinStock ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (seleccionado)
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 14,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            'En carrito: ${formatoCantidad(enCarrito)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Carrito
// ---------------------------------------------------------------------------

/// Barra fija del teléfono: cantidad de artículos, total y "Cobrar". Tocar la
/// barra abre la hoja con las líneas.
class BarraCarrito extends ConsumerWidget {
  const BarraCarrito({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final carrito = ref.watch(carritoVentaProvider);
    final n = carrito.items.length;

    return Material(
      color: scheme.primaryContainer,
      shape: Border(top: BorderSide(color: scheme.outlineVariant)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => mostrarHojaCarrito(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$n artículo${n == 1 ? '' : 's'}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                              MoneyText(
                                carrito.total,
                                style: textTheme.titleLarge?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _BotonCobrar(
                // El tema fija ancho infinito; en una fila hay que acotarlo.
                style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                onPressed: () => cobrarVenta(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Abre la hoja con las líneas del carrito (teléfono).
Future<void> mostrarHojaCarrito(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _HojaCarrito(),
  );
}

class _HojaCarrito extends StatelessWidget {
  const _HojaCarrito();

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.viewInsetsOf(context).bottom;
    final alto = MediaQuery.sizeOf(context).height * 0.85;
    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alto),
        child: const CarritoPanel(enHoja: true),
      ),
    );
  }
}

/// Líneas editables del carrito, nota, total y "Cobrar". Se usa como panel
/// lateral fijo (escritorio) y dentro de la hoja del teléfono ([enHoja]).
class CarritoPanel extends ConsumerStatefulWidget {
  const CarritoPanel({super.key, this.enHoja = false});

  final bool enHoja;

  @override
  ConsumerState<CarritoPanel> createState() => _CarritoPanelState();
}

class _CarritoPanelState extends ConsumerState<CarritoPanel> {
  late final _notaController = TextEditingController(
    text: ref.read(carritoVentaProvider).nota ?? '',
  );

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _editar(int indice, ItemVentaInput item, bool esAdmin) async {
    final actualizado = await showDialog<ItemVentaInput>(
      context: context,
      builder: (_) => EditarLineaDialog(item: item, esAdmin: esAdmin),
    );
    if (actualizado == null) return;
    final controller = ref.read(carritoVentaProvider.notifier);
    controller.actualizarCantidad(indice, actualizado.cantidad);
    // Solo el Administrador puede cambiar el precio de una línea.
    if (esAdmin) {
      controller.actualizarPrecio(indice, actualizado.precioUnitario);
    }
  }

  Future<void> _cobrar() async {
    final ok = await cobrarVenta(context, ref);
    if (ok && mounted && widget.enHoja) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final carrito = ref.watch(carritoVentaProvider);
    final esAdmin = _esAdministrador(ref);
    final controller = ref.read(carritoVentaProvider.notifier);

    // Al limpiar el carrito (venta registrada) se vacía también la nota.
    ref.listen(carritoVentaProvider.select((c) => c.nota), (_, nota) {
      if (nota == null && _notaController.text.isNotEmpty) {
        _notaController.clear();
      }
    });

    final lista = carrito.items.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: EmptyState(
              compacto: true,
              icono: Icons.shopping_cart_outlined,
              titulo: 'Toca un producto para agregarlo',
            ),
          )
        : ListView.separated(
            shrinkWrap: widget.enHoja,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: carrito.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = carrito.items[i];
              return LineaCarrito(
                item: item,
                onEditar: () => _editar(i, item, esAdmin),
                onMenos: () => item.cantidad <= 1
                    ? controller.quitarItem(i)
                    : controller.actualizarCantidad(i, item.cantidad - 1),
                onMas: () =>
                    controller.actualizarCantidad(i, item.cantidad + 1),
                onQuitar: () => controller.quitarItem(i),
              );
            },
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text('Carrito', style: textTheme.titleMedium),
        ),
        if (widget.enHoja) Flexible(child: lista) else Expanded(child: lista),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _notaController,
                minLines: 1,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Nota (opcional)'),
                onChanged: (valor) => controller.establecerNota(
                  valor.trim().isEmpty ? null : valor,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text('Total', style: textTheme.titleLarge),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: MoneyText(
                      carrito.total,
                      textAlign: TextAlign.right,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _BotonCobrar(onPressed: carrito.items.isEmpty ? null : _cobrar),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botón "Cobrar": con un cobro en curso se deshabilita (no se puede lanzar un
/// segundo cobro) y, mientras registra, muestra un indicador de progreso.
class _BotonCobrar extends ConsumerWidget {
  const _BotonCobrar({required this.onPressed, this.style});

  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fase = ref.watch(faseCobroProvider);
    return FilledButton(
      style: style,
      onPressed: fase == FaseCobro.libre ? onPressed : null,
      child: fase == FaseCobro.registrando
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          : const Text('Cobrar'),
    );
  }
}

/// Una línea del carrito: nombre, precio unitario, cantidad con -/+ y
/// subtotal. Tocar la cantidad abre la edición (cantidad y, solo
/// Administrador, precio).
class LineaCarrito extends StatelessWidget {
  const LineaCarrito({
    super.key,
    required this.item,
    required this.onEditar,
    required this.onMenos,
    required this.onMas,
    required this.onQuitar,
  });

  final ItemVentaInput item;
  final VoidCallback onEditar;
  final VoidCallback onMenos;
  final VoidCallback onMas;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(item.productoNombre, style: textTheme.titleSmall),
                ),
              ),
              IconButton(
                tooltip: 'Quitar del carrito',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline),
                onPressed: onQuitar,
              ),
            ],
          ),
          Text(
            '${item.precioUnitario.format()} c/u',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Quitar uno',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove),
                onPressed: onMenos,
              ),
              TextButton(
                onPressed: onEditar,
                child: Text(
                  formatoCantidad(item.cantidad),
                  style: textTheme.titleMedium,
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Agregar uno',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add),
                onPressed: onMas,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MoneyText(
                  item.subtotal,
                  textAlign: TextAlign.right,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diálogos
// ---------------------------------------------------------------------------

/// Edita una línea del carrito: cantidad y precio unitario (el precio solo es
/// editable por el Administrador).
class EditarLineaDialog extends StatefulWidget {
  const EditarLineaDialog({
    super.key,
    required this.item,
    required this.esAdmin,
  });

  final ItemVentaInput item;
  final bool esAdmin;

  @override
  State<EditarLineaDialog> createState() => _EditarLineaDialogState();
}

class _EditarLineaDialogState extends State<EditarLineaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _cantidadController = TextEditingController(
    text: formatoCantidad(widget.item.cantidad),
  );
  late final _precioController = TextEditingController(
    text: widget.item.precioUnitario.format(symbol: false),
  );

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  double? _parseCantidad(String texto) =>
      double.tryParse(texto.replaceAll(',', '.').trim());

  String? _validarCantidad(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = _parseCantidad(valor);
    if (parsed == null || parsed <= 0) return 'Cantidad inválida';
    return null;
  }

  String? _validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Obligatorio';
    final parsed = double.tryParse(valor.replaceAll(',', ''));
    if (parsed == null || parsed < 0) return 'Precio inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.productoNombre),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cantidadController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: _validarCantidad,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _precioController,
              enabled: widget.esAdmin,
              decoration: InputDecoration(
                labelText: 'Precio unitario',
                prefixText: 'RD\$ ',
                helperText: widget.esAdmin
                    ? null
                    : 'Solo el Administrador puede cambiar el precio',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: _validarPrecio,
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
            Navigator.of(context).pop(
              ItemVentaInput(
                productoId: widget.item.productoId,
                productoNombre: widget.item.productoNombre,
                cantidad: _parseCantidad(_cantidadController.text)!,
                precioUnitario: Money.parse(_precioController.text),
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Billetes dominicanos de referencia para los botones de monto rápido.
const _billetes = [50, 100, 200, 500, 1000, 2000];

/// Montos rápidos: los 3 billetes más pequeños MAYORES que el total (uno igual
/// al total ya lo cubre "Exacto"). Con total sobre el billete mayor: ninguno.
List<Money> montosRapidos(Money total) => [
  for (final billete in _billetes)
    if (Money.fromPesos(billete) > total) Money.fromPesos(billete),
].take(3).toList();

/// Diálogo de cobro: monto recibido → cambio. El campo abre con el total
/// seleccionado (escribir el billete lo reemplaza), Enter confirma y los
/// chips fijan el monto; el cambio es el dato principal.
class CobroDialog extends StatefulWidget {
  const CobroDialog({super.key, required this.total});

  final Money total;

  @override
  State<CobroDialog> createState() => _CobroDialogState();
}

class _CobroDialogState extends State<CobroDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _montoController = TextEditingController(
    text: widget.total.format(symbol: false),
  );

  @override
  void initState() {
    super.initState();
    _seleccionarTodo();
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  void _seleccionarTodo() {
    _montoController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _montoController.text.length,
    );
  }

  Money? _recibidoActual() {
    try {
      return Money.parse(
        _montoController.text.isEmpty ? '0' : _montoController.text,
      );
    } on FormatException {
      return null;
    }
  }

  void _fijar(Money monto) {
    setState(() {
      _montoController.text = monto.format(symbol: false);
      _seleccionarTodo();
    });
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_recibidoActual());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final recibido = _recibidoActual();
    final diferencia = recibido != null ? recibido - widget.total : null;
    final montos = [widget.total, ...montosRapidos(widget.total)];

    final Widget cambio;
    if (diferencia == null) {
      cambio = Text('--', style: textTheme.titleLarge);
    } else if (diferencia.isNegative) {
      cambio = Text(
        'Faltan ${(-diferencia).format()}',
        style: textTheme.titleLarge?.copyWith(
          color: scheme.error,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      cambio = Row(
        children: [
          Text('Cambio', style: textTheme.titleMedium),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: MoneyText(
              diferencia,
              textAlign: TextAlign.right,
              style: textTheme.headlineMedium?.copyWith(
                color: context.appColors.exito,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Cobrar'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('Total', style: textTheme.titleMedium),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: MoneyText(
                      widget.total,
                      textAlign: TextAlign.right,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _montoController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Monto recibido',
                  prefixText: 'RD\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obligatorio';
                  final monto = _recibidoActual();
                  if (monto == null) return 'Monto inválido';
                  if (monto < widget.total) return 'Monto insuficiente';
                  return null;
                },
                onChanged: (_) => setState(() {}),
                onFieldSubmitted: (_) => _confirmar(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (var i = 0; i < montos.length; i++)
                    ChoiceChip(
                      label: Text(
                        i == 0
                            ? 'Exacto'
                            : formatoCantidad(montos[i].cents / 100),
                      ),
                      selected: recibido == montos[i],
                      onSelected: (_) => _fijar(montos[i]),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              cambio,
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _confirmar, child: const Text('Confirmar')),
      ],
    );
  }
}

/// Diálogo para agregar un producto al carrito indicando la cantidad o el
/// monto a vender (RF-VEN): permite vender por monto (ej. RD$ 150 de
/// chuleta) y calcula la cantidad correspondiente según el precio unitario.
class CantidadMontoDialog extends StatefulWidget {
  const CantidadMontoDialog({super.key, required this.producto});

  final Producto producto;

  @override
  State<CantidadMontoDialog> createState() => _CantidadMontoDialogState();
}

class _CantidadMontoDialogState extends State<CantidadMontoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _cantidadController = TextEditingController(text: '1');
  late final _montoController = TextEditingController(
    text: widget.producto.precioVenta.format(symbol: false),
  );

  @override
  void dispose() {
    _cantidadController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  double? _parseCantidad(String texto) =>
      double.tryParse(texto.replaceAll(',', '.').trim());

  void _onCantidadChanged(String texto) {
    final cantidad = _parseCantidad(texto);
    if (cantidad == null) return;
    final monto = Money((widget.producto.precioVenta.cents * cantidad).round());
    _montoController.text = monto.format(symbol: false);
    setState(() {});
  }

  void _onMontoChanged(String texto) {
    if (widget.producto.precioVenta.cents == 0) return;
    Money monto;
    try {
      monto = Money.parse(texto.isEmpty ? '0' : texto);
    } on FormatException {
      return;
    }
    final cantidad = monto.cents / widget.producto.precioVenta.cents;
    _cantidadController.text = cantidad.toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.producto.nombre),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Precio: ${widget.producto.precioVenta.format()} '
              'por ${widget.producto.unidad}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _cantidadController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Cantidad (${widget.producto.unidad})',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: _onCantidadChanged,
              validator: (v) {
                final cantidad = v == null ? null : _parseCantidad(v);
                if (cantidad == null || cantidad <= 0) {
                  return 'Cantidad inválida';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto a vender',
                prefixText: 'RD\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: _onMontoChanged,
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
            Navigator.of(context).pop(
              ItemVentaInput(
                productoId: widget.producto.id,
                productoNombre: widget.producto.nombre,
                cantidad: _parseCantidad(_cantidadController.text)!,
                precioUnitario: widget.producto.precioVenta,
              ),
            );
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
