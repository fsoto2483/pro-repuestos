import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product.dart';
import '../../../state/cart_controller.dart';
import '../../../state/catalog_controller.dart';
import '../../../widgets/common.dart';
import '../../../widgets/product_cover.dart';

/// Tarjeta de producto del catalogo: imagen grande, datos tecnicos, precio,
/// stock y accion de agregar.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.coverHeight = 150,
  });

  final Product product;
  final VoidCallback onTap;
  final double coverHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CatalogController catalog = context.watch<CatalogController>();
    final CartController cart = context.watch<CartController>();
    final bool isFavorite = catalog.isFavorite(product.id);
    final int inCart = cart.quantityOf(product.id);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _cover(context, isFavorite),
              Expanded(child: _body(context, theme, inCart)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cover(BuildContext context, bool isFavorite) {
    return SizedBox(
      height: coverHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ProductCover(product: product),
          Positioned(
            top: 10,
            left: 10,
            child: Wrap(
              spacing: 6,
              children: <Widget>[
                if (product.hasDiscount)
                  Pill(
                    label: '-${product.discountPercent}%',
                    color: AppColors.danger,
                    dense: true,
                  ),
                if (product.isFeatured)
                  const Pill(
                    label: 'Destacado',
                    color: AppColors.ink,
                    icon: Icons.bolt_rounded,
                    dense: true,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onPressed: () =>
                  context.read<CatalogController>().toggleFavorite(product.id),
            ),
          ),
          if (!product.isAvailable)
            Container(
              color: Colors.black.withValues(alpha: 0.55),
              alignment: Alignment.center,
              child: const Pill(
                label: 'AGOTADO',
                color: AppColors.danger,
                icon: Icons.block_rounded,
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, ThemeData theme, int inCart) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  product.brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: product.category.color,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              RatingLine(rating: product.rating, size: 11.5),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(height: 1.25),
          ),
          const SizedBox(height: 6),
          _codes(theme),
          const Spacer(),
          StockBadge(product: product, dense: true),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(child: _price(theme)),
              _AddButton(product: product, inCart: inCart),
            ],
          ),
        ],
      ),
    );
  }

  Widget _codes(ThemeData theme) {
    final TextStyle? style = theme.textTheme.bodySmall?.copyWith(fontSize: 11);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'SKU ${product.sku}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
        Text(
          'OEM ${product.oem}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ],
    );
  }

  Widget _price(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (product.hasDiscount)
          Text(
            Formatters.price(product.previousPrice!),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              decoration: TextDecoration.lineThrough,
              color: AppColors.slateLight,
            ),
          ),
        Text(
          Formatters.price(product.price),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ],
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        tooltip: isFavorite ? 'Quitar de favoritos' : 'Guardar en favoritos',
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppColors.brand : Colors.white,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.product, required this.inCart});

  final Product product;
  final int inCart;

  @override
  Widget build(BuildContext context) {
    final bool disabled = !product.isAvailable;
    return Tooltip(
      message: disabled ? 'Sin stock' : 'Agregar a la cotizacion',
      child: SizedBox(
        width: 42,
        height: 42,
        child: Material(
          color: disabled
              ? Theme.of(context).colorScheme.outlineVariant
              : AppColors.brand,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: disabled
                ? null
                : () {
                    context.read<CartController>().add(product);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('${product.name} agregado'),
                          duration: const Duration(milliseconds: 1400),
                        ),
                      );
                  },
            child: Center(
              child: inCart > 0
                  ? Text(
                      '$inCart',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    )
                  : Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 19,
                      color: disabled ? AppColors.slate : Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
