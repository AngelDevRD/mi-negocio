import 'package:flutter/material.dart';

import '../../../../core/database/enums.dart';
import '../../../../core/widgets/widgets.dart';

/// "Ventas" o "Delivery" con ícono y texto.
class EtiquetaTipoEmpleado extends StatelessWidget {
  const EtiquetaTipoEmpleado(this.tipo, {super.key});

  final TipoEmpleado tipo;

  @override
  Widget build(BuildContext context) {
    return switch (tipo) {
      TipoEmpleado.ventas => const EtiquetaEstado(
        icono: Icons.storefront_outlined,
        texto: 'Ventas',
      ),
      TipoEmpleado.delivery => const EtiquetaEstado(
        icono: Icons.delivery_dining_outlined,
        texto: 'Delivery',
      ),
    };
  }
}
