import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../backup/presentation/widgets/seccion_respaldo.dart';
import '../../../exports/presentation/widgets/seccion_exportar.dart';
import '../../../import/presentation/widgets/seccion_importar.dart';
import '../../../license/domain/entities/licencia.dart';
import '../../../license/presentation/providers/license_providers.dart';

/// "Datos" (solo Administrador): respaldo y restauración, exportación de
/// reportes e importación desde Excel en UNA pantalla, cada cosa en su
/// sección. No disponible en el plan Demo (RN-17): las tres funciones
/// sacan datos del equipo o los reemplazan.
class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licencia = ref.watch(licenseControllerProvider).value;
    final esDemo = switch (licencia) {
      LicenciaActiva(:final licencia) => licencia.tipo == TipoLicencia.demo,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Datos')),
      body: esDemo
          ? const EmptyState(
              icono: Icons.lock_outline,
              titulo: 'Datos no está disponible en el plan Demo',
              descripcion:
                  'Activa una licencia Local o Nube para respaldar, exportar '
                  'e importar los datos de tu negocio.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const [
                SeccionRespaldo(),
                SizedBox(height: AppSpacing.md),
                SeccionExportar(),
                SizedBox(height: AppSpacing.md),
                SeccionImportar(),
              ],
            ),
    );
  }
}
