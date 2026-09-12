import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../../data/models/product.dart';
import 'product_card.dart';

/// Grilla responsive de productos.
///
/// El alto de cada tarjeta se calcula a partir del ancho disponible para que
/// no queden espacios vacios ni desbordes en ningun tamano de pantalla.
class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.onTapProduct,
    this.padding = EdgeInsets.zero,
    this.sliver = true,
  });

  final List<Product> products;
  final ValueChanged<Product> onTapProduct;
  final EdgeInsets padding;

  /// `true` dentro de un `CustomScrollView`; `false` para usarla como caja.
  final bool sliver;

  static const double _spacing = 14;
  static const double _bodyHeight = 190;

  @override
  Widget build(BuildContext context) {
    final int columns = context.gridColumns();

    // El contenido siempre esta limitado por `ContentWidth`, asi que el ancho
    // real disponible es el menor entre la pantalla y ese maximo.
    final double containerWidth = math.min(
      context.screenWidth,
      Breakpoints.maxContentWidth,
    );
    final double available =
        containerWidth - padding.horizontal - _spacing * (columns - 1);
    final double coverHeight = (available / columns / 1.3).clamp(120, 200);

    final SliverGridDelegate delegate =
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: _spacing,
          crossAxisSpacing: _spacing,
          mainAxisExtent: coverHeight + _bodyHeight,
        );

    Widget builder(BuildContext context, int index) {
      final Product product = products[index];
      return ProductCard(
        product: product,
        coverHeight: coverHeight,
        onTap: () => onTapProduct(product),
      );
    }

    if (sliver) {
      return SliverPadding(
        padding: padding,
        sliver: SliverGrid(
          gridDelegate: delegate,
          delegate: SliverChildBuilderDelegate(
            builder,
            childCount: products.length,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: delegate,
      itemCount: products.length,
      itemBuilder: builder,
    );
  }
}
