import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/part_category.dart';
import '../../state/catalog_controller.dart';
import '../../widgets/common.dart';
import '../catalog/widgets/category_card.dart';
import 'category_products_screen.dart';

/// Cuadricula visual con las 7 categorias del catalogo.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CatalogController catalog = context.watch<CatalogController>();
    final double gutter = context.horizontalPadding;
    final int columns = switch (context.screenSize) {
      ScreenSize.mobile => 2,
      ScreenSize.tablet => 3,
      ScreenSize.desktop => 4,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                floating: true,
                titleSpacing: gutter,
                automaticallyImplyLeading: false,
                toolbarHeight: 70,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Categorias',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'Explora el catalogo por sistema del vehiculo',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              if (catalog.isLoading)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: 168,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, _) =>
                          const Skeleton(height: 168, radius: AppTheme.radius),
                      childCount: 6,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 28),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: 168,
                    ),
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final PartCategory category = catalog.categories[index];
                      return CategoryCard(
                        category: category,
                        productCount: catalog.countForCategory(category.id),
                        compact: context.isMobile,
                        onTap: () =>
                            CategoryProductsScreen.open(context, category),
                      );
                    }, childCount: catalog.categories.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
