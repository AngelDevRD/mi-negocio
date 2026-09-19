import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Indicador de carga centrado, con [mensaje] opcional debajo.
///
/// Uso: `LoadingView(mensaje: 'Cargando ventas...')` dentro de la rama
/// `loading` de un `AsyncValue.when`.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.mensaje});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Cargando',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (mensaje != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(mensaje!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vacío: ícono atenuado, título, descripción de POR QUÉ está vacío y
/// una acción opcional para crear el primer registro.
///
/// Uso: `EmptyState(icono: Icons.inventory_2_outlined, titulo: 'Sin
/// productos', descripcion: 'Agrega tu primer producto para empezar a
/// vender.', accionLabel: 'Agregar producto', onAccion: () => ...)`. Con
/// `compacto: true` se usa en línea dentro de una sección (sin centrar a
/// pantalla completa, ícono más pequeño).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icono,
    required this.titulo,
    this.descripcion,
    this.accionLabel,
    this.onAccion,
    this.accionPrimaria = false,
    this.compacto = false,
  });

  final IconData icono;
  final String titulo;
  final String? descripcion;
  final String? accionLabel;
  final VoidCallback? onAccion;

  /// `true`: la acción es LA acción principal de la pantalla (botón relleno,
  /// no tonal). Úsalo cuando el estado vacío es todo lo que hay en pantalla.
  final bool accionPrimaria;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final contenido = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: compacto ? 32 : 64, color: scheme.outline),
        SizedBox(height: compacto ? AppSpacing.sm : AppSpacing.md),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: compacto ? textTheme.titleSmall : textTheme.titleMedium,
        ),
        if (descripcion != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            descripcion!,
            textAlign: TextAlign.center,
            // onSurfaceVariant (color de TEXTO, AA >= 4.5:1), no outline
            // (ese es un color de borde, pensado para 3:1).
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
        if (accionLabel != null && onAccion != null) ...[
          SizedBox(height: compacto ? AppSpacing.sm : AppSpacing.md),
          if (accionPrimaria)
            FilledButton(onPressed: onAccion, child: Text(accionLabel!))
          else
            FilledButton.tonal(onPressed: onAccion, child: Text(accionLabel!)),
        ],
      ],
    );

    if (compacto) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: contenido,
      );
    }
    // SingleChildScrollView: con texto largo, pantalla en horizontal o
    // textScaler grande, el contenido puede exceder el alto disponible; sin
    // scroll eso se ve como franjas de overflow en vez de simplemente
    // desplazarse.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: contenido,
      ),
    );
  }
}

/// Estado de error: mensaje humano (nunca `error.toString()`) y botón
/// "Reintentar" si se da [onReintentar]. Registra [error]/[stackTrace] con
/// `dart:developer` una sola vez por error (no repite el log en cada
/// rebuild mientras el error no cambie).
///
/// Uso: `ErrorState(mensaje: 'No se pudieron cargar las ventas.', error: e,
/// stackTrace: st, onReintentar: () => ref.invalidate(ventasProvider))`.
class ErrorState extends StatefulWidget {
  const ErrorState({
    super.key,
    required this.mensaje,
    this.error,
    this.stackTrace,
    this.onReintentar,
    this.compacto = false,
  });

  final String mensaje;
  final Object? error;
  final StackTrace? stackTrace;
  final VoidCallback? onReintentar;
  final bool compacto;

  @override
  State<ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<ErrorState> {
  @override
  void initState() {
    super.initState();
    _registrar();
  }

  @override
  void didUpdateWidget(covariant ErrorState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.error != oldWidget.error) {
      _registrar();
    }
  }

  void _registrar() {
    if (widget.error == null) return;
    developer.log(
      widget.mensaje,
      name: 'mi_negocio',
      error: widget.error,
      stackTrace: widget.stackTrace,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final contenido = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: widget.compacto ? 32 : 64,
          color: scheme.error,
        ),
        SizedBox(height: widget.compacto ? AppSpacing.sm : AppSpacing.md),
        Text(
          widget.mensaje,
          textAlign: TextAlign.center,
          style: widget.compacto ? textTheme.titleSmall : textTheme.titleMedium,
        ),
        if (widget.onReintentar != null) ...[
          SizedBox(height: widget.compacto ? AppSpacing.sm : AppSpacing.md),
          FilledButton.tonal(
            onPressed: widget.onReintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ],
    );

    if (widget.compacto) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: contenido,
      );
    }
    // Ver comentario equivalente en EmptyState: sin scroll, el contenido
    // puede exceder el alto disponible y mostrar overflow.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: contenido,
      ),
    );
  }
}
