import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_widgets.dart';

/// Ancho máximo del contenido: en pantallas muy anchas no se estira.
const double _anchoMaximo = 1100;

/// Ancho de contenido desde el que "Inventario bajo" y "Últimos movimientos"
/// van lado a lado. El contenido descuenta el rail de navegación y el padding,
/// por eso el umbral es menor que el ancho de pantalla (~1000 px).
const double _anchoDosColumnas = 900;

/// Pantalla principal post-login (RF-DASH). Vista diferenciada por rol:
/// la ganancia bruta del mes solo se muestra al Administrador (RN-15).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario,
      _ => null,
    };
    final esAdmin = usuario?.esAdministrador ?? false;
    // Mientras carga se asume que hay productos (evita parpadear la bienvenida).
    final hayProductos = ref.watch(negocioTieneProductosProvider).value ?? true;
    // Mientras carga o si falla se asume abierta (no cambia el botón principal).
    final caja = ref.watch(cajaActualProvider);
    final cajaAbierta = !caja.hasValue || caja.value != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _anchoMaximo),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (usuario != null) ...[
                SaludoUsuario(nombre: usuario.nombre),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (esAdmin) const VencimientoBanner(),
              if (esAdmin) const AvisoProductosSinCosto(),
              TarjetaCaja(abrirEsPrimaria: hayProductos),
              const SizedBox(height: AppSpacing.md),
              // Sin productos no hay nada que vender ni comprar: la única
              // acción principal es "Agregar producto" (en la bienvenida).
              if (!hayProductos)
                TarjetaBienvenida(esAdmin: esAdmin)
              else ...[
                AccionesPrincipales(cajaAbierta: cajaAbierta),
                const SizedBox(height: AppSpacing.lg),
                const VentasHoyCard(),
                const SizedBox(height: AppSpacing.sm),
                const PorCobrarCard(),
                IndicadoresMes(esAdmin: esAdmin),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= _anchoDosColumnas) {
                      return const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: InventarioBajoSeccion()),
                          SizedBox(width: AppSpacing.md),
                          Expanded(child: MovimientosRecientesSeccion()),
                        ],
                      );
                    }
                    return const Column(
                      children: [
                        InventarioBajoSeccion(),
                        SizedBox(height: AppSpacing.lg),
                        MovimientosRecientesSeccion(),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
