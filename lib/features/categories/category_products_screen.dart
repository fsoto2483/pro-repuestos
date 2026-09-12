import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/part_category.dart';
import '../../data/models/product.dart';
import '../../state/catalog_controller.dart';
import '../../widgets/common.dart';
import '../catalog/widgets/product_grid.dart';
import '../catalog/widgets/search_bar_field.dart';
import '../product/product_detail_screen.dart';

/// Productos de una categoria, con su propio buscador local.
class CategoryProductsScreen extends StatefulWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final PartCategory category;

  static Future<void> open(BuildContext context, PartCategory category) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryProductsScreen(category: category),
      ),
    );
  }

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String _query = '';
  List<Product> _products = <Product>[];
  bool _loading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final List<Product> found = await context
        .read<CatalogController>()
        .productsInCategory(widget.category.id, query: _query);
    if (!mounted) return;
    setState(() {
      _products = found;
      _loading = false;
    });
  }

  /// La busqueda consulta la base, asi que se espera a que deje de escribir.
  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 280),
      () => unawaited(_load()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = context.horizontalPadding;
    final List<Product> products = _products;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 190,
                foregroundColor: Colors.white,
                backgroundColor: widget.category.gradient.last,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
                  title: Text(
                    widget.category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                    ),
                  ),
                  background: _Header(category: widget.category),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 8),
                  child: SearchBarField(
                    value: _query,
                    hintText: 'Buscar en ${widget.category.name}',
                    onChanged: _onQueryChanged,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 14),
                  child: Text(
                    Formatters.plural(
                      products.length,
                      'referencia disponible',
                      'referencias disponibles',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    accent: widget.category.color,
                    title: 'Sin coincidencias',
                    message:
                        'No hay repuestos de ${widget.category.name} que '
                        'coincidan con "$_query".',
                    actionLabel: 'Ver toda la categoria',
                    onAction: () => _onQueryChanged(''),
                  ),
                )
              else
                ProductGrid(
                  products: products,
                  padding: EdgeInsets.fromLTRB(gutter, 0, gutter, 28),
                  onTapProduct: (Product p) =>
                      ProductDetailScreen.open(context, p),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.category});

  final PartCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: category.gradient,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -20,
            top: 10,
            child: Icon(
              category.icon,
              size: 150,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            left: 20,
            right: 120,
            bottom: 54,
            child: Text(
              category.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
