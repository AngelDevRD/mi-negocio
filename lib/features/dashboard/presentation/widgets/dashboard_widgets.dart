import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cantidades.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';
import '../../../sales/presentation/widgets/abrir_caja_dialog.dart';
import '../../domain/entities/dashboard_data.dart';
import '../providers/dashboard_providers.dart';

/// Máximo de filas en las listas compactas del Inicio.
const int _maxFilas = 5;

/// "8:05 a. m." en hora local (sin depender de datos de locale de intl).
String _horaLocal(DateTime instante) {
  final local = instante.toLocal();
  final hora12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minutos = local.minute.toString().padLeft(2, '0');
  final sufijo = local.hour < 12 ? 'a.\u00A0m.' : 'p.\u00A0m.';
  // Espacios sin ruptura: con texto grande "a. m." no debe partirse.
  return '$hora12:$minutos\u00A0$sufijo';
}

/// 3 -> "3", 2.5 -> "2.50".
String _cantidad(double valor) => valor == valor.roundToDouble()
    ? valor.toInt().toString()
    : valor.toStringAsFixed(2);

/// Etiqueta con ícono + texto (el estado nunca depende solo del color).
class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.icono,
    required this.texto,
    required this.fondo,
    required this.contenido,
  });

  final IconData icono;
  final String texto;
  final Color fondo;
  final Color contenido;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 16, color: contenido),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                texto,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: contenido,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Saludo breve, como texto secundario.
class SaludoUsuario extends StatelessWidget {
  const SaludoUsuario({super.key, required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hola, $nombre',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Tarjeta con estilo de advertencia (fondo tenue + borde y ícono en el color
/// de advertencia del tema). La usan la caja cerrada y el vencimiento.
class _TarjetaAdvertencia extends StatelessWidget {
  const _TarjetaAdvertencia({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.advertencia;
    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: color),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

/// Banner de vencimiento próximo de la suscripción (F18), solo Administrador.
class VencimientoBanner extends ConsumerWidget {
  const VencimientoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final check = ref.watch(licenseControllerProvider).value;
    final licencia = switch (check) {
      LicenciaActiva(:final licencia) => licencia,
      LicenciaBloqueada(:final licencia) => licencia,
      _ => null,
    };
    if (licencia == null) return const SizedBox.shrink();

    final dias = licencia.diasParaVencer(DateTime.now().toUtc());
    if (dias == null || dias > diasAlertaRenovacion) {
      return const SizedBox.shrink();
    }

    final mensaje = dias <= 0
        ? 'Tu suscripción venció. Renueva desde Perfil para evitar '
              'interrupciones.'
        : 'Tu suscripción vence en $dias ${dias == 1 ? 'día' : 'días'}. '
              'Renueva desde Perfil.';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: _TarjetaAdvertencia(
        onTap: () => context.push(AppRoutes.perfil),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: context.appColors.advertencia,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(mensaje)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// Estado de la caja. Abierta: hora de apertura y monto actual; toca para ir a
/// la pestaña Caja. Cerrada: aviso de advertencia con "Abrir caja".
///
/// [abrirEsPrimaria]: "Abrir caja" es el botón sólido solo si es LA acción
/// principal de la pantalla; sin productos lo es "Agregar producto" y aquí
/// baja a tonal (una sola acción principal por estado).
class TarjetaCaja extends ConsumerWidget {
  const TarjetaCaja({super.key, this.abrirEsPrimaria = true});

  final bool abrirEsPrimaria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caja = ref.watch(cajaActualProvider);
    return caja.when(
      loading: () => const Card(
        margin: EdgeInsets.zero,
        child: SizedBox(height: 120, child: LoadingView()),
      ),
      error: (error, stackTrace) => Card(
        margin: EdgeInsets.zero,
        child: ErrorState(
          compacto: true,
          mensaje: 'No se pudo cargar el estado de caja.',
          error: error,
          stackTrace: stackTrace,
          onReintentar: () => ref.invalidate(cajaActualProvider),
        ),
      ),
      data: (sesion) => sesion == null
          ? _CajaCerrada(abrirEsPrimaria: abrirEsPrimaria)
          : _CajaAbierta(sesion: sesion),
    );
  }
}

class _CajaAbierta extends StatelessWidget {
  const _CajaAbierta({required this.sesion});

  final CajaActual sesion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AppRoutes.caja),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Etiqueta(
                    icono: Icons.lock_open_outlined,
                    texto: 'Caja abierta',
                    fondo: scheme.primaryContainer,
                    contenido: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'desde ${_horaLocal(sesion.fechaApertura)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                label: 'Monto actual en caja',
                child: MoneyText(
                  sesion.montoActual,
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CajaCerrada extends StatelessWidget {
  const _CajaCerrada({required this.abrirEsPrimaria});

  final bool abrirEsPrimaria;

  @override
  Widget build(BuildContext context) {
    return _TarjetaAdvertencia(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, color: context.appColors.advertencia),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text('La caja está cerrada. Ábrela para poder vender.'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (abrirEsPrimaria)
            FilledButton(
              onPressed: () => mostrarDialogoAbrirCaja(context),
              child: const Text('Abrir caja'),
            )
          else
            FilledButton.tonal(
              onPressed: () => mostrarDialogoAbrirCaja(context),
              child: const Text('Abrir caja'),
            ),
        ],
      ),
    );
  }
}

/// Acciones rápidas. Con la caja abierta "Nueva venta" es la acción principal
/// (botón sólido); con la caja cerrada la principal es "Abrir caja" (en
/// [TarjetaCaja]) y "Nueva venta" baja a tonal. "Registrar compra" siempre es
/// secundaria.
class AccionesPrincipales extends StatelessWidget {
  const AccionesPrincipales({super.key, required this.cajaAbierta});

  final bool cajaAbierta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cajaAbierta)
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.ventaRapida),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Nueva venta'),
          )
        else
          FilledButton.tonalIcon(
            onPressed: () => context.push(AppRoutes.ventaRapida),
            icon: const Icon(Icons.point_of_sale),
            label: const Text('Nueva venta'),
          ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.tonalIcon(
          onPressed: () => context.push(AppRoutes.comprasNueva),
          icon: const Icon(Icons.shopping_cart_outlined),
          label: const Text('Registrar compra'),
        ),
      ],
    );
  }
}

/// Tarjeta de un indicador: título (puede ocupar 2 líneas), monto sin recorte
/// y, opcionalmente, una línea de ayuda. Su alto depende del contenido.
class TarjetaIndicador extends StatelessWidget {
  const TarjetaIndicador({
    super.key,
    required this.titulo,
    required this.valor,
    required this.onReintentar,
    this.estiloMonto,
    this.ayuda,
  });

  final String titulo;
  final AsyncValue<Money> valor;
  final VoidCallback onReintentar;
  final TextStyle? estiloMonto;
  final String? ayuda;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            valor.when(
              data: (monto) => MoneyText(
                monto,
                style: (estiloMonto ?? textTheme.titleLarge)?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stackTrace) => ErrorState(
                compacto: true,
                mensaje: 'No se pudo cargar.',
                error: error,
                stackTrace: stackTrace,
                onReintentar: onReintentar,
              ),
            ),
            if (ayuda != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                ayuda!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Ventas de hoy": el indicador destacado (el monto más grande tras la caja).
class VentasHoyCard extends ConsumerWidget {
  const VentasHoyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TarjetaIndicador(
      titulo: 'Ventas de hoy',
      valor: ref.watch(ventasDelDiaProvider),
      onReintentar: () => ref.invalidate(ventasDelDiaProvider),
      estiloMonto: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

/// Indicadores del mes en rejilla: 2 columnas en pantallas angostas, 4 desde
/// 600 px. Cada fila se ajusta a la más alta de sus tarjetas y una fila
/// incompleta reparte todo el ancho (nunca queda un hueco huérfano).
class IndicadoresMes extends ConsumerWidget {
  const IndicadoresMes({super.key, required this.esAdmin});

  final bool esAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarjetas = <Widget>[
      TarjetaIndicador(
        titulo: 'Ventas del mes',
        valor: ref.watch(ventasDelMesProvider),
        onReintentar: () => ref.invalidate(ventasDelMesProvider),
      ),
      TarjetaIndicador(
        titulo: 'Compras del mes',
        valor: ref.watch(comprasDelMesProvider),
        onReintentar: () => ref.invalidate(comprasDelMesProvider),
      ),
      TarjetaIndicador(
        titulo: 'Gastos del mes',
        valor: ref.watch(gastosDelMesProvider),
        onReintentar: () => ref.invalidate(gastosDelMesProvider),
      ),
      if (esAdmin)
        TarjetaIndicador(
          titulo: 'Ganancia bruta del mes',
          valor: ref.watch(gananciaDelMesProvider),
          onReintentar: () => ref.invalidate(gananciaDelMesProvider),
          ayuda: 'Ventas menos costo de lo vendido',
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = math.min(
          constraints.maxWidth >= 600 ? 4 : 2,
          tarjetas.length,
        );
        final filas = <Widget>[];
        for (var i = 0; i < tarjetas.length; i += columnas) {
          final grupo = tarjetas.sublist(
            i,
            math.min(i + columnas, tarjetas.length),
          );
          if (filas.isNotEmpty) {
            filas.add(const SizedBox(height: AppSpacing.sm));
          }
          filas.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < grupo.length; j++) ...[
                    if (j > 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(child: grupo[j]),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(children: filas);
      },
    );
  }
}

class _EncabezadoSeccion extends StatelessWidget {
  const _EncabezadoSeccion({required this.titulo, required this.onVerTodo});

  final String titulo;
  final VoidCallback onVerTodo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        TextButton(onPressed: onVerTodo, child: const Text('Ver todo')),
      ],
    );
  }
}

/// Productos con stock bajo (máx. 5) con enlace a Inventario.
class InventarioBajoSeccion extends ConsumerWidget {
  const InventarioBajoSeccion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosBajoStockProvider);
    final advertencia = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EncabezadoSeccion(
          titulo: 'Inventario bajo',
          onVerTodo: () => context.push(AppRoutes.inventario),
        ),
        productos.when(
          loading: () => const Card(
            margin: EdgeInsets.zero,
            child: SizedBox(height: 96, child: LoadingView()),
          ),
          error: (error, stackTrace) => Card(
            margin: EdgeInsets.zero,
            child: ErrorState(
              compacto: true,
              mensaje: 'No se pudo cargar el inventario.',
              error: error,
              stackTrace: stackTrace,
              onReintentar: () => ref.invalidate(productosBajoStockProvider),
            ),
          ),
          data: (lista) {
            if (lista.isEmpty) {
              return const Card(
                margin: EdgeInsets.zero,
                child: EmptyState(
                  compacto: true,
                  icono: Icons.inventory_2_outlined,
                  titulo: 'Todo el inventario está en orden',
                ),
              );
            }
            return Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final producto in lista.take(_maxFilas))
                    ListTile(
                      title: Text(producto.nombre),
                      subtitle: Text(
                        'Quedan ${formatoCantidadUnidad(producto.stockActual, producto.unidad)}'
                        ' · mínimo ${_cantidad(producto.stockMinimo)}',
                      ),
                      trailing: _Etiqueta(
                        icono: Icons.warning_amber_outlined,
                        texto: 'Stock bajo',
                        fondo: advertencia.advertencia,
                        contenido: advertencia.onAdvertencia,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Últimos movimientos (máx. 5) con enlace a la pestaña Ventas.
class MovimientosRecientesSeccion extends ConsumerWidget {
  const MovimientosRecientesSeccion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movimientos = ref.watch(movimientosRecientesProvider);
    final formatoFecha = DateFormat('dd/MM/yyyy HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EncabezadoSeccion(
          titulo: 'Últimos movimientos',
          onVerTodo: () => context.go(AppRoutes.ventas),
        ),
        movimientos.when(
          loading: () => const Card(
            margin: EdgeInsets.zero,
            child: SizedBox(height: 96, child: LoadingView()),
          ),
          error: (error, stackTrace) => Card(
            margin: EdgeInsets.zero,
            child: ErrorState(
              compacto: true,
              mensaje: 'No se pudieron cargar los movimientos.',
              error: error,
              stackTrace: stackTrace,
              onReintentar: () => ref.invalidate(movimientosRecientesProvider),
            ),
          ),
          data: (lista) {
            if (lista.isEmpty) {
              return const Card(
                margin: EdgeInsets.zero,
                child: EmptyState(
                  compacto: true,
                  icono: Icons.receipt_long_outlined,
                  titulo: 'Aún no hay movimientos registrados',
                ),
              );
            }
            return Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final mov in lista.take(_maxFilas))
                    ListTile(
                      leading: Icon(_icono(mov.tipo)),
                      title: Text(_titulo(mov.tipo)),
                      subtitle: Text(formatoFecha.format(mov.fecha.toLocal())),
                      trailing: MoneyText(
                        mov.monto,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  static IconData _icono(TipoMovimientoReciente tipo) => switch (tipo) {
    TipoMovimientoReciente.venta => Icons.point_of_sale,
    TipoMovimientoReciente.compra => Icons.shopping_cart_outlined,
    TipoMovimientoReciente.gasto => Icons.receipt_long_outlined,
  };

  static String _titulo(TipoMovimientoReciente tipo) => switch (tipo) {
    TipoMovimientoReciente.venta => 'Venta',
    TipoMovimientoReciente.compra => 'Compra',
    TipoMovimientoReciente.gasto => 'Gasto',
  };
}

/// Primer uso: el negocio todavía no tiene productos.
class TarjetaBienvenida extends StatelessWidget {
  const TarjetaBienvenida({super.key, required this.esAdmin});

  final bool esAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          EmptyState(
            compacto: true,
            icono: Icons.inventory_2_outlined,
            titulo: 'Empieza agregando tus productos',
            descripcion:
                'Con tu catálogo listo podrás vender, comprar y ver aquí los '
                'indicadores de tu negocio.',
          ),
          // Único botón sólido de la pantalla sin productos.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.productosNuevo),
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
            ),
          ),
          if (esAdmin)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: TextButton(
                onPressed: () => context.push(AppRoutes.importar),
                child: const Text('Importar desde Excel'),
              ),
            ),
        ],
      ),
    );
  }
}
