import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Destino {
  const _Destino(this.etiqueta, this.icono, this.iconoActivo);

  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
}

/// Destinos principales, en el mismo orden que las ramas del
/// `StatefulShellRoute` de app_router.dart.
const _destinos = [
  _Destino('Inicio', Icons.home_outlined, Icons.home),
  _Destino('Ventas', Icons.point_of_sale_outlined, Icons.point_of_sale),
  _Destino(
    'Caja',
    Icons.account_balance_wallet_outlined,
    Icons.account_balance_wallet,
  ),
  _Destino('Productos', Icons.inventory_2_outlined, Icons.inventory_2),
  _Destino('Más', Icons.grid_view_outlined, Icons.grid_view),
];

/// Ancho desde el que se usa un `NavigationRail` lateral en vez de la barra
/// inferior (tablets y escritorio).
const double _anchoRail = 600;

/// Ancho desde el que el rail se muestra extendido, con etiquetas al lado.
const double _anchoRailExtendido = 1000;

/// Shell de navegación adaptativa: barra inferior en pantallas angostas,
/// rail lateral en anchas. Las etiquetas siempre son visibles.
///
/// Tocar el destino activo vuelve a la raíz de esa rama. El botón atrás en
/// la raíz de una rama distinta de Inicio va a Inicio en vez de cerrar la
/// app.
///
/// Uso: `StatefulShellRoute.indexedStack(builder: (context, state, shell) =>
/// AppShell(navigationShell: shell), branches: [...])`.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _seleccionar(int indice) {
    navigationShell.goBranch(
      indice,
      initialLocation: indice == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final indice = navigationShell.currentIndex;

    return PopScope(
      canPop: indice == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;

          if (ancho < _anchoRail) {
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: NavigationBar(
                selectedIndex: indice,
                onDestinationSelected: _seleccionar,
                destinations: [
                  for (final d in _destinos)
                    NavigationDestination(
                      icon: Icon(d.icono),
                      selectedIcon: Icon(d.iconoActivo),
                      label: d.etiqueta,
                    ),
                ],
              ),
            );
          }

          final extendido = ancho >= _anchoRailExtendido;
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: extendido,
                  labelType: extendido
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  selectedIndex: indice,
                  onDestinationSelected: _seleccionar,
                  destinations: [
                    for (final d in _destinos)
                      NavigationRailDestination(
                        icon: Icon(d.icono),
                        selectedIcon: Icon(d.iconoActivo),
                        label: Text(d.etiqueta),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        },
      ),
    );
  }
}
