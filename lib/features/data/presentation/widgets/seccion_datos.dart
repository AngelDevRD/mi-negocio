import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Tarjeta de una sección de la pantalla "Datos" (Respaldo, Exportar,
/// Importar): ícono, título, una línea que explica para qué sirve y el
/// contenido propio de la sección.
class SeccionDatos extends StatelessWidget {
  const SeccionDatos({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.children,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Row(
                children: [
                  Icon(icono, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(titulo, style: textTheme.titleLarge)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              descripcion,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Nombre del archivo de [ruta] (después de la última `/` o `\`). No se usa
/// `XFile.name`: en escritorio devuelve la ruta completa si mezcla
/// separadores (p. ej. `C:\Temp/reporte.xlsx`).
String nombreDeArchivo(String ruta) => ruta.split(RegExp(r'[\\/]')).last;
