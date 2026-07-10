import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/audit/presentation/screens/audit_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/setup_screen.dart';
import '../../features/auth/presentation/screens/users_management_screen.dart';
import '../../features/backup/presentation/screens/backup_screen.dart';
import '../../features/cash_register/presentation/screens/cash_register_close_screen.dart';
import '../../features/cash_register/presentation/screens/cash_register_history_screen.dart';
import '../../features/cash_register/presentation/screens/cash_register_screen.dart';
import '../../features/cash_register/presentation/screens/cash_register_session_detail_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/employees/presentation/screens/employee_detail_screen.dart';
import '../../features/employees/presentation/screens/employee_form_screen.dart';
import '../../features/employees/presentation/screens/employees_list_screen.dart';
import '../../features/employees/presentation/screens/payment_form_screen.dart';
import '../../features/expenses/presentation/screens/expense_form_screen.dart';
import '../../features/expenses/presentation/screens/expenses_list_screen.dart';
import '../../features/exports/presentation/screens/exports_screen.dart';
import '../../features/import/presentation/screens/import_screen.dart';
import '../../features/inventory/presentation/screens/inventory_adjustment_screen.dart';
import '../../features/inventory/presentation/screens/inventory_list_screen.dart';
import '../../features/inventory/presentation/screens/product_kardex_screen.dart';
import '../../features/license/domain/entities/licencia.dart';
import '../../features/license/presentation/providers/license_providers.dart';
import '../../features/license/presentation/screens/activation_screen.dart';
import '../../features/license/presentation/screens/blocked_screen.dart';
import '../../features/products/presentation/screens/categorias_management_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/products_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/purchases/presentation/screens/purchase_detail_screen.dart';
import '../../features/purchases/presentation/screens/purchase_form_screen.dart';
import '../../features/purchases/presentation/screens/purchases_list_screen.dart';
import '../../features/sales/presentation/screens/detailed_sale_screen.dart';
import '../../features/sales/presentation/screens/quick_sale_screen.dart';
import '../../features/sales/presentation/screens/sale_detail_screen.dart';
import '../../features/sales/presentation/screens/sales_list_screen.dart';
import '../database/enums.dart';

/// Rutas nombradas de la aplicación.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String licenseActivation = '/licencia/activar';
  static const String licenseBlocked = '/licencia/bloqueada';
  static const String setup = '/configuracion/inicial';
  static const String login = '/login';
  static const String usuarios = '/usuarios';
  static const String productos = '/productos';
  static const String productosNuevo = '/productos/nuevo';
  static const String productosCategorias = '/productos/categorias';
  static const String inventario = '/inventario';
  static const String compras = '/compras';
  static const String comprasNueva = '/compras/nueva';
  static const String ventas = '/ventas';
  static const String ventaRapida = '/ventas/rapida';
  static const String ventaDetallada = '/ventas/detallada';
  static const String caja = '/caja';
  static const String cajaCerrar = '/caja/cerrar';
  static const String cajaHistorial = '/caja/historial';
  static const String gastos = '/gastos';
  static const String gastosNuevo = '/gastos/nuevo';
  static const String empleados = '/empleados';
  static const String empleadosNuevo = '/empleados/nuevo';
  static const String auditoria = '/auditoria';
  static const String analisis = '/analisis';
  static const String exportaciones = '/exportaciones';
  static const String importar = '/importar';
  static const String respaldo = '/respaldo';
  static const String perfil = '/perfil';
  static const String asistente = '/asistente';
}

/// Rutas accesibles solo para el rol Administrador (RN-15, guard de rol).
const _rutasSoloAdmin = {
  AppRoutes.usuarios,
  AppRoutes.cajaCerrar,
  AppRoutes.auditoria,
  AppRoutes.analisis,
  AppRoutes.exportaciones,
  AppRoutes.importar,
  AppRoutes.respaldo,
  AppRoutes.perfil,
  AppRoutes.asistente,
};

/// RF-INV-03/RN-19: el ajuste manual de inventario es solo para Administrador.
bool _esRutaAjusteInventario(String destino) =>
    destino.startsWith('/inventario/') && destino.endsWith('/ajuste');

/// RF-EMP-05: el módulo de empleados es exclusivo del Administrador.
bool _esRutaEmpleados(String destino) => destino.startsWith('/empleados');

/// Router central con cadena de guards: licencia → auth → rol.
///
/// Orden obligatorio del redirect (RN-15):
///   1. Licencia (F3): sin licencia → activación; suspendida/vencida → bloqueo.
///   2. Sin negocio registrado → wizard de configuración inicial.
///   3. Sin sesión → /login.
///   4. Ruta solo-admin con rol cajero → /.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Reevalúa el redirect cuando cambia el estado de la licencia o la sesión.
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(licenseControllerProvider, (_, _) => refresh.value++);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final licencia = ref.read(licenseControllerProvider);
      final destino = state.matchedLocation;

      // Guard 1 — licencia
      if (licencia.isLoading) {
        return destino == AppRoutes.splash ? null : AppRoutes.splash;
      }
      switch (licencia.value) {
        case SinLicencia() || null:
          return destino == AppRoutes.licenseActivation
              ? null
              : AppRoutes.licenseActivation;
        case LicenciaBloqueada():
          // Desde el bloqueo se permite ir a activar otra licencia.
          return (destino == AppRoutes.licenseBlocked ||
                  destino == AppRoutes.licenseActivation)
              ? null
              : AppRoutes.licenseBlocked;
        case LicenciaActiva():
          // Guards 2-4 — auth y rol.
          final enPantallaDeLicencia =
              destino == AppRoutes.splash || destino.startsWith('/licencia');
          final auth = ref.read(authControllerProvider);
          if (auth.isLoading) {
            return enPantallaDeLicencia ? AppRoutes.splash : null;
          }
          switch (auth.value) {
            case SinNegocio() || null:
              return destino == AppRoutes.setup ? null : AppRoutes.setup;
            case SinSesion():
              if (enPantallaDeLicencia || destino == AppRoutes.setup) {
                return AppRoutes.login;
              }
              return destino == AppRoutes.login ? null : AppRoutes.login;
            case SesionActiva(:final usuario):
              final enPantallaDeAuth =
                  enPantallaDeLicencia ||
                  destino == AppRoutes.login ||
                  destino == AppRoutes.setup;
              if (enPantallaDeAuth) return AppRoutes.home;
              if ((_rutasSoloAdmin.contains(destino) ||
                      _esRutaAjusteInventario(destino) ||
                      _esRutaEmpleados(destino)) &&
                  !usuario.esAdministrador) {
                return AppRoutes.home;
              }
              return null;
          }
      }
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.licenseActivation,
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: AppRoutes.licenseBlocked,
        builder: (context, state) => const BlockedScreen(),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.usuarios,
        builder: (context, state) => const UsersManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.productos,
        builder: (context, state) => const ProductsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.productosNuevo,
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.productosCategorias,
        builder: (context, state) => const CategoriasManagementScreen(),
      ),
      GoRoute(
        path: '/productos/:id',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/productos/:id/editar',
        builder: (context, state) =>
            ProductFormScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.inventario,
        builder: (context, state) => const InventoryListScreen(),
      ),
      GoRoute(
        path: '/inventario/:id',
        builder: (context, state) =>
            ProductKardexScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/inventario/:id/ajuste',
        builder: (context, state) =>
            InventoryAdjustmentScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.compras,
        builder: (context, state) => const PurchasesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.comprasNueva,
        builder: (context, state) => const PurchaseFormScreen(),
      ),
      GoRoute(
        path: '/compras/:id',
        builder: (context, state) =>
            PurchaseDetailScreen(compraId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.ventas,
        builder: (context, state) => const SalesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.ventaRapida,
        builder: (context, state) => const QuickSaleScreen(),
      ),
      GoRoute(
        path: AppRoutes.ventaDetallada,
        builder: (context, state) => const DetailedSaleScreen(),
      ),
      GoRoute(
        path: '/ventas/:id',
        builder: (context, state) =>
            SaleDetailScreen(ventaId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.caja,
        builder: (context, state) => const CashRegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.cajaCerrar,
        builder: (context, state) => const CashRegisterCloseScreen(),
      ),
      GoRoute(
        path: AppRoutes.cajaHistorial,
        builder: (context, state) => const CashRegisterHistoryScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.cajaHistorial}/:id',
        builder: (context, state) => CashRegisterSessionDetailScreen(
          sesionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.gastos,
        builder: (context, state) => const ExpensesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.gastosNuevo,
        builder: (context, state) => const ExpenseFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.empleados,
        builder: (context, state) => const EmployeesListScreen(),
      ),
      GoRoute(
        path: AppRoutes.empleadosNuevo,
        builder: (context, state) {
          final tipo = TipoEmpleado.values.byName(
            state.uri.queryParameters['tipo'] ?? TipoEmpleado.ventas.name,
          );
          return EmployeeFormScreen(tipoInicial: tipo);
        },
      ),
      GoRoute(
        path: '/empleados/:id',
        builder: (context, state) =>
            EmployeeDetailScreen(employeeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/empleados/:id/editar',
        builder: (context, state) =>
            EmployeeFormScreen(employeeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/empleados/:id/pago',
        builder: (context, state) =>
            PaymentFormScreen(employeeId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.auditoria,
        builder: (context, state) => const AuditScreen(),
      ),
      GoRoute(
        path: AppRoutes.analisis,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.exportaciones,
        builder: (context, state) => const ExportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.importar,
        builder: (context, state) => const ImportScreen(),
      ),
      GoRoute(
        path: AppRoutes.respaldo,
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: AppRoutes.perfil,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.asistente,
        builder: (context, state) => const AiChatScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
