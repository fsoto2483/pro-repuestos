import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/product.dart';
import '../../state/auth_controller.dart';
import '../../state/catalog_controller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/common.dart';
import '../product/product_detail_screen.dart';
import 'widgets/category_chips.dart';
import 'widgets/filters_sheet.dart';
import 'widgets/product_card.dart';
import 'widgets/product_grid.dart';
import 'widgets/promo_banner.dart';
import 'widgets/search_bar_field.dart';
import 'widgets/vehicle_filter.dart';
import '../admin/import_csv_screen.dart';

/// Pantalla principal: catalogo con busqueda rapida, categorias, destacados y
/// la grilla completa de productos.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.onSeeAllCategories});

  final VoidCallback onSeeAllCategories;

  @override
  Widget build(BuildContext context) {
    final CatalogController catalog = context.watch<CatalogController>();
    final double gutter = context.horizontalPadding;

    return Scaffold(
      
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: RefreshIndicator(
            color: AppColors.brand,
            onRefresh: catalog.load,
            child: CustomScrollView(

              slivers: <Widget>[
                _AppHeader(gutter: gutter),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 14),
                    child: SearchBarField(
                      value: catalog.query,
                      onChanged: catalog.search,
                      filterCount: catalog.activeFilterCount,
                      onFilterTap: () => FiltersSheet.show(context),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    child: const VehicleFilterCard(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
                SliverToBoxAdapter(
                  child: CategoryChips(
                    categories: catalog.categories,
                    selectedId: catalog.categoryId,
                    onSelected: catalog.selectCategory,
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                if (catalog.status == CatalogStatus.error)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.wifi_off_rounded,
                      title: 'No pudimos cargar el catalogo',
                      message: catalog.errorMessage ?? 'Intenta nuevamente.',
                      actionLabel: 'Reintentar',
                      onAction: catalog.load,
                    ),
                  )
                else if (catalog.isLoading)
                  _LoadingSlivers(gutter: gutter)
                else ...<Widget>[
                  if (!catalog.hasActiveFilters) ...<Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        /*child: PromoBanner(
                          onPressed: () =>
                              catalog.setSort(ProductSort.priceAsc),
                        ),*/
                      ),
                    ),
                    /*const SliverToBoxAdapter(child: SizedBox(height: 28)),*/
                    /*SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        child: SectionHeader(
                          title: 'Destacados de la semana',
                          subtitle:
                              'Las referencias que mas rotan en los talleres',
                          actionLabel: 'Categorias',
                          onAction: onSeeAllCategories,
                        ),
                      ),
                    ),*/
                    /*const SliverToBoxAdapter(child: SizedBox(height: 14)),*/
                    /*SliverToBoxAdapter(
                      child: _FeaturedRow(
                        products: catalog.featured,
                        gutter: gutter,
                      ),
                    ),*/
                    /*const SliverToBoxAdapter(child: SizedBox(height: 30)),*/
                  ],

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: gutter),
                      child: _ResultsHeader(catalog: catalog),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  if (catalog.results.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Sin resultados',
                        message: _emptyMessage(catalog),
                        actionLabel: 'Limpiar filtros',
                        onAction: catalog.resetFilters,
                      ),
                    )
                  else
                    ProductGrid(
                      products: catalog.results,
                      padding: EdgeInsets.symmetric(horizontal: gutter),
                      onTapProduct: (Product p) =>
                          ProductDetailScreen.open(context, p),
                    ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _emptyMessage(CatalogController catalog) {
    if (catalog.makeId != null) {
      return 'No tenemos repuestos para ${catalog.vehicleLabel} con esos '
          'filtros. Quita el motor o el ano para ver mas opciones.';
    }
    if (catalog.query.isNotEmpty) {
      return 'No encontramos repuestos para "${catalog.query}". Prueba con el '
          'numero OEM o el nombre de la marca.';
    }
    return 'Ningun repuesto coincide con los filtros activos.';
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String name =
        context.watch<AuthController>().user?.firstName ?? 'Bienvenido';

    return SliverAppBar(
      pinned: true,
      floating: false,
      toolbarHeight: 74,
      automaticallyImplyLeading: false,
      titleSpacing: gutter,
      title: Row(
        children: <Widget>[
          const AppLogo(size: 38, showWordmark: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Buenos días, $name', style: theme.textTheme.titleMedium),
                Text(
                  '¿Qué repuesto necesitas hoy?',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'Notificaciones',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tienes notificaciones nuevas')),
          ),
          icon: Badge(
            backgroundColor: AppColors.brand,
            smallSize: 8,
            child: const Icon(Icons.notifications_none_rounded),
          ),
        ),
        SizedBox(width: gutter - 8),
      ],
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.catalog});

  final CatalogController catalog;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String title = catalog.selectedCategory?.name ?? 'Todo el catalogo';

    final String subtitle = <String>[
      Formatters.plural(catalog.totalResults, 'referencia', 'referencias'),
      if (catalog.makeId != null) 'para ${catalog.vehicleLabel}',
      if (catalog.results.length < catalog.totalResults)
        '· mostrando las primeras ${catalog.results.length}',
    ].join(' ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        PopupMenuButton<ProductSort>(
          initialValue: catalog.sort,
          onSelected: catalog.setSort,
          tooltip: 'Ordenar',
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (_) => ProductSort.values
              .map(
                (ProductSort s) => PopupMenuItem<ProductSort>(
                  value: s,
                  child: Text(s.label),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.swap_vert_rounded, size: 18),
                const SizedBox(width: 6),
                Text(
                  catalog.sort.label,
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Carrusel horizontal de productos destacados.
class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({required this.products, required this.gutter});

  final List<Product> products;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 222;
    const double coverHeight = 150;

    return SizedBox(
      height: coverHeight + 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: gutter),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) => SizedBox(
          width: cardWidth,
          child: ProductCard(
            product: products[index],
            coverHeight: coverHeight,
            onTap: () => ProductDetailScreen.open(context, products[index]),
          ),
        ),
      ),
    );
  }
}

/// Esqueletos mostrados mientras llega el catalogo.
class _LoadingSlivers extends StatelessWidget {
  const _LoadingSlivers({required this.gutter});

  final double gutter;

  @override
  Widget build(BuildContext context) {
    final int columns = context.gridColumns();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      sliver: SliverList.list(
        children: <Widget>[
          const Skeleton(height: 168, radius: AppTheme.radius),
          const SizedBox(height: 26),
          const Skeleton(width: 220, height: 22),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: columns * 2,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 320,
            ),
            itemBuilder: (_, _) =>
                const Skeleton(height: 320, radius: AppTheme.radius),
          ),
        ],
      ),
    );
  }
}
