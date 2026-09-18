import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';
import '../../state/quotes_controller.dart';
import '../../widgets/app_logo.dart';
import '../cart/cart_screen.dart';
import '../catalog/catalog_screen.dart';
import '../categories/categories_screen.dart';
import '../debug/firestore_test_screen.dart';
import '../profile/profile_screen.dart';

/// Contenedor principal de la app una vez el usuario inicio sesion.
///
/// En movil muestra la barra inferior de navegacion; en pantallas anchas
/// (web y Windows) cambia a una barra lateral, que es lo esperado en esos
/// tamanos.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? userId = context.read<AuthController>().user?.id;
      context.read<QuotesController>().load(userId: userId);
    });
  }

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      CatalogScreen(onSeeAllCategories: () => _goTo(1)),
      const CategoriesScreen(),
      CartScreen(onExploreCatalog: () => _goTo(0)),
      const ProfileScreen(),
    ];

    final int cartCount = context.watch<CartController>().distinctCount;
    final bool rail = context.usesSideNavigation;

    final Widget body = IndexedStack(index: _index, children: pages);

    final PreferredSizeWidget appBar = AppBar(
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.cloud),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FirestoreTestScreen(),
              ),
            );
          },
        ),
      ],
    );

    if (rail) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: <Widget>[
            _SideNav(
              index: _index,
              cartCount: cartCount,
              onSelected: _goTo,
              extended: context.isDesktop,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: _BottomNav(
        index: _index,
        cartCount: cartCount,
        onSelected: _goTo,
      ),
    );
  }
}

/// Definicion unica de los destinos, compartida por la barra inferior y la
/// barra lateral para que nunca se desincronicen.
class _Destination {
  const _Destination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const List<_Destination> _destinations = <_Destination>[
  _Destination(
    Icons.storefront_outlined,
    Icons.storefront_rounded,
    'Catalogo',
  ),
  _Destination(
    Icons.grid_view_outlined,
    Icons.grid_view_rounded,
    'Categorias',
  ),
  _Destination(
    Icons.shopping_cart_outlined,
    Icons.shopping_cart_rounded,
    'Cotizacion',
  ),
  _Destination(
    Icons.person_outline_rounded,
    Icons.person_rounded,
    'Perfil',
  ),
];

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.index,
    required this.cartCount,
    required this.onSelected,
  });

  final int index;
  final int cartCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onSelected,
        destinations: <Widget>[
          for (int i = 0; i < _destinations.length; i++)
            NavigationDestination(
              icon: _icon(_destinations[i].icon, i),
              selectedIcon: _icon(_destinations[i].selectedIcon, i),
              label: _destinations[i].label,
            ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, int position) {
    final Widget child = Icon(icon);
    if (position != 2 || cartCount == 0) return child;
    return Badge.count(
      count: cartCount,
      backgroundColor: AppColors.brand,
      child: child,
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.index,
    required this.cartCount,
    required this.onSelected,
    required this.extended,
  });

  final int index;
  final int cartCount;
  final ValueChanged<int> onSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: onSelected,
      extended: extended,
      minExtendedWidth: 208,
      labelType: extended ? null : NavigationRailLabelType.all,
      leading: Padding(
        padding: EdgeInsets.fromLTRB(extended ? 16 : 0, 20, 0, 24),
        child: AppLogo(size: 38, showWordmark: extended),
      ),
      destinations: <NavigationRailDestination>[
        for (int i = 0; i < _destinations.length; i++)
          NavigationRailDestination(
            icon: _icon(_destinations[i].icon, i),
            selectedIcon: _icon(_destinations[i].selectedIcon, i),
            label: Text(_destinations[i].label),
          ),
      ],
    );
  }

  Widget _icon(IconData icon, int position) {
    final Widget child = Icon(icon);
    if (position != 2 || cartCount == 0) return child;
    return Badge.count(
      count: cartCount,
      backgroundColor: AppColors.brand,
      child: child,
    );
  }
}
