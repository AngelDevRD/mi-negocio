import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class _Modulo {
  const _Modulo(this.icono, this.titulo, this.descripcion, this.ruta);

  final IconData icono;
  final String titulo;
  final String descripcion;
  final String ruta;
}

class _Seccion {
  const _Seccion(this.titulo, this.modulos, {this.soloAdmin = false});

  final String titulo;
  final List<_Modulo> modulos;
  final bool soloAdmin;
}

/// Módulos del hub agrupados por sección. Los permisos (`soloAdmin`) son los
/// mismos que aplica el guard de rol del router (RN-15): aquí solo se
/// ocultan las opciones que el rol no puede abrir.
const _secciones = [
  _Seccion('Operación', [
    _Modulo(
      Icons.groups_outlined,
      'Clientes y fiado',
      'Lleva la cuenta de lo que te deben y registra abonos.',
      AppRoutes.clientes,
    ),
    _Modulo(
      Icons.shopping_cart_outlined,
      'Compras',
      'Registra compras a proveedores y repón el inventario.',
      AppRoutes.compras,
    ),
    _Modulo(
      Icons.receipt_long_outlined,
      'Gastos',
      'Anota los gastos del negocio por categoría.',
      AppRoutes.gastos,
    ),
  ]),
  _Seccion('Personal', soloAdmin: true, [
    _Modulo(
      Icons.badge_outlined,
      'Empleados',
      'Fichas, pagos y antigüedad del personal.',
      AppRoutes.empleados,
    ),
    _Modulo(
      Icons.people_outline,
      'Gestionar usuarios',
      'Crea cajeros y controla quién puede entrar a la app.',
      AppRoutes.usuarios,
    ),
  ]),
  _Seccion('Análisis', soloAdmin: true, [
    _Modulo(
      Icons.bar_chart_outlined,
      'Análisis financiero',
      'Ventas, gastos y ganancia por período.',
      AppRoutes.analisis,
    ),
    _Modulo(
      Icons.history,
      'Auditoría',
      'Quién hizo qué y cuándo dentro del sistema.',
      AppRoutes.auditoria,
    ),
    _Modulo(
      Icons.smart_toy_outlined,
      'Asistente IA',
      'Haz preguntas sobre tu negocio en lenguaje natural.',
      AppRoutes.asistente,
    ),
    _Modulo(
      Icons.storage_outlined,
      'Datos',
      'Respaldo y restauración, exportar reportes e importar desde Excel.',
      AppRoutes.datos,
    ),
  ]),
];

/// Hub "Más": reemplaza el menú "⋮" del dashboard. Lista todos los módulos
/// que no caben en la barra de navegación, agrupados por sección y con una
/// línea que explica para qué sirve cada uno. Incluye "Cerrar sesión" con
/// confirmación.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    final confirmar = await mostrarConfirmacion(
      context,
      titulo: 'Cerrar sesión',
      mensaje: 'Tendrás que volver a iniciar sesión para usar la app.',
      confirmarLabel: 'Cerrar sesión',
      destructivo: true,
    );
    if (!confirmar || !context.mounted) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = switch (ref.watch(authControllerProvider).value) {
      SesionActiva(:final usuario) => usuario,
      _ => null,
    };
    final esAdmin = usuario?.esAdministrador ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Más')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          if (usuario != null)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(usuario.nombre),
              subtitle: Text(esAdmin ? 'Administrador' : 'Cajero'),
            ),
          for (final seccion in _secciones)
            if (!seccion.soloAdmin || esAdmin) ...[
              _EncabezadoSeccion(seccion.titulo),
              for (final modulo in seccion.modulos)
                _ItemModulo(
                  icono: modulo.icono,
                  titulo: modulo.titulo,
                  descripcion: modulo.descripcion,
                  onTap: () => context.push(modulo.ruta),
                ),
            ],
          const _EncabezadoSeccion('Cuenta'),
          if (esAdmin)
            _ItemModulo(
              icono: Icons.storefront_outlined,
              titulo: 'Perfil y suscripción',
              descripcion: 'Datos del negocio y estado de tu licencia.',
              onTap: () => context.push(AppRoutes.perfil),
            ),
          if (esAdmin)
            _ItemModulo(
              icono: Icons.tune_outlined,
              titulo: 'Ajustes del negocio',
              descripcion: 'Reglas de operación, como vender sin stock.',
              onTap: () => context.push(AppRoutes.ajustes),
            ),
          _ItemModulo(
            icono: Icons.logout,
            titulo: 'Cerrar sesión',
            descripcion: 'Sal de tu cuenta en este equipo.',
            onTap: () => _cerrarSesion(context, ref),
          ),
        ],
      ),
    );
  }
}

class _EncabezadoSeccion extends StatelessWidget {
  const _EncabezadoSeccion(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Text(
          titulo,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ItemModulo extends StatelessWidget {
  const _ItemModulo({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      subtitle: Text(descripcion),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
