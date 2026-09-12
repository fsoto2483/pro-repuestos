import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/part_category.dart';
import '../../data/models/product.dart';
import '../../data/models/vehicle.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/product_cover.dart';
import '../catalog/widgets/product_card.dart';

/// Ficha completa del repuesto: imagen grande, datos tecnicos, compatibilidad
/// y accion de agregar a la cotizacion.
///
/// La grilla no trae ni las fotos adicionales ni la compatibilidad, para no
/// pedirle de mas a la base en cada scroll. Esta pantalla completa el producto
/// al abrirse.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  static Future<void> open(BuildContext context, Product product) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  late Product _product = widget.product;
  List<Product> _relatedProducts = <Product>[];

  @override
  void initState() {
    super.initState();
    unawaited(_loadDetails());
  }

  Future<void> _loadDetails() async {
    final CatalogController catalog = context.read<CatalogController>();

    // Si la consulta falla, la ficha se queda con lo que ya traia la tarjeta:
    // nombre, precio, SKU y stock. Se pierde la compatibilidad, no la pantalla.
    try {
      final Product? full = await catalog.fullProduct(widget.product.id);
      final List<Product> related = await catalog.relatedTo(widget.product);
      if (!mounted) return;
      setState(() {
        if (full != null) _product = full;
        _relatedProducts = related;
      });
    } catch (e) {
      debugPrint('ProductDetailScreen._loadDetails: $e');
    }
  }

  void _addToCart() {
    context.read<CartController>().setQuantity(_product, _quantity);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$_quantity x ${_product.name} en tu cotizacion',
          ),
          action: SnackBarAction(
            label: 'Deshacer',
            textColor: AppColors.brand,
            onPressed: () => context.read<CartController>().remove(_product.id),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = context.usesSideNavigation;

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.category.name),
        actions: <Widget>[
          Consumer<CatalogController>(
            builder: (BuildContext context, CatalogController catalog, _) {
              final bool fav = catalog.isFavorite(_product.id);
              return IconButton(
                tooltip: fav ? 'Quitar de favoritos' : 'Guardar en favoritos',
                onPressed: () => catalog.toggleFavorite(_product.id),
                icon: Icon(
                  fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: fav ? AppColors.brand : null,
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Compartir ficha',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ficha ${_product.sku} lista para enviar')),
            ),
            icon: const Icon(Icons.ios_share_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ContentWidth(
          child: wide ? _wideLayout(context) : _narrowLayout(context),
        ),
      ),
      bottomNavigationBar: _BuyBar(
        product: _product,
        quantity: _quantity,
        onQuantityChanged: (int q) => setState(() => _quantity = q),
        onAdd: _addToCart,
      ),
    );
  }

  Widget _narrowLayout(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        8,
        context.horizontalPadding,
        24,
      ),
      children: <Widget>[
        _hero(context, height: 280),
        const SizedBox(height: 20),
        ..._details(context),
      ],
    );
  }

  Widget _wideLayout(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.horizontalPadding,
        8,
        context.horizontalPadding,
        24,
      ),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 420, child: _hero(context, height: 420)),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _details(context, includeRelated: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        ..._related(context),
      ],
    );
  }

  Widget _hero(BuildContext context, {required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ProductCover(
              product: _product,
              iconScale: 0.46,
              showSku: false,
            ),
            if (_product.hasDiscount)
              Positioned(
                top: 16,
                left: 16,
                child: Pill(
                  label: '-${_product.discountPercent}% de descuento',
                  color: AppColors.danger,
                ),
              ),
            if (!_product.isAvailable)
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
      ),
    );
  }

  List<Widget> _details(BuildContext context, {bool includeRelated = true}) {
    final ThemeData theme = Theme.of(context);
    final PartCategory category = _product.category;

    return <Widget>[
      Row(
        children: <Widget>[
          Pill(
            label: _product.brand,
            color: category.color,
            filled: false,
          ),
          const SizedBox(width: 8),
          RatingLine(
            rating: _product.rating,
            reviewCount: _product.reviewCount,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(_product.name, style: theme.textTheme.headlineSmall),
      const SizedBox(height: 12),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 10,
        runSpacing: 2,
        children: <Widget>[
          Text(
            Formatters.price(_product.price),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.brand,
            ),
          ),
          if (_product.hasDiscount)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                Formatters.price(_product.previousPrice!),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.slateLight,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      Text('IVA incluido · Precio por unidad', style: theme.textTheme.bodySmall),
      const SizedBox(height: 16),
      StockBadge(product: _product, showUnits: true),
      const SizedBox(height: 20),

      _CodesCard(product: _product),
      const SizedBox(height: 20),

      Text('Descripcion', style: theme.textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(
        _product.description,
        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate),
      ),
      const SizedBox(height: 22),

      Text('Ficha tecnica', style: theme.textTheme.titleMedium),
      const SizedBox(height: 10),
      _SpecsTable(specs: _product.specs),
      const SizedBox(height: 22),

      Text('Compatibilidad', style: theme.textTheme.titleMedium),
      const SizedBox(height: 4),
      Text(
        'Verifica siempre el numero OEM antes de comprar.',
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 10),
      if (_product.fitments.isEmpty)
        Text(
          'Sin compatibilidad registrada para esta referencia.',
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _product.fitments
              .map(
                (Fitment fitment) => Chip(
                  avatar: const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 16,
                    color: AppColors.slate,
                  ),
                  label: Text(fitment.label),
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              )
              .toList(),
        ),
      const SizedBox(height: 22),

      _GuaranteeRow(warrantyMonths: _product.warrantyMonths),

      if (includeRelated) ...<Widget>[
        const SizedBox(height: 32),
        ..._related(context),
      ],
    ];
  }

  List<Widget> _related(BuildContext context) {
    final List<Product> related = _relatedProducts;
    if (related.isEmpty) return const <Widget>[];

    return <Widget>[
      SectionHeader(
        title: 'Tambien te puede servir',
        subtitle: 'Referencias de ${_product.category.name}',
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 340,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: related.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (BuildContext context, int index) => SizedBox(
            width: 222,
            child: ProductCard(
              product: related[index],
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ProductDetailScreen(product: related[index]),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _CodesCard extends StatelessWidget {
  const _CodesCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget cell(String label, String value, IconData icon) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 14, color: AppColors.slate),
              const SizedBox(width: 5),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            maxLines: 1,
            style: theme.textTheme.titleSmall?.copyWith(letterSpacing: 0.3),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          cell('SKU', product.sku, Icons.qr_code_2_rounded),
          const SizedBox(width: 12),
          cell('OEM', product.oem, Icons.precision_manufacturing_rounded),
        ],
      ),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  const _SpecsTable({required this.specs});

  final Map<String, String> specs;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<MapEntry<String, String>> entries = specs.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < entries.length; i++)
            Container(
              color: i.isEven
                  ? Colors.transparent
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Text(
                      entries[i].key,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      entries[i].value,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GuaranteeRow extends StatelessWidget {
  const _GuaranteeRow({required this.warrantyMonths});

  final int warrantyMonths;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget item(IconData icon, String title, String subtitle) => Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, color: AppColors.brand, size: 22),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: <Widget>[
          item(
            Icons.verified_user_rounded,
            warrantyMonths > 0 ? 'Garantia' : 'Producto sellado',
            warrantyMonths > 0 ? '$warrantyMonths meses' : 'Original de fabrica',
          ),
          item(
            Icons.local_shipping_rounded,
            'Despacho',
            'Mismo dia en ciudad',
          ),
          item(
            Icons.assignment_return_rounded,
            'Cambios',
            'Hasta 8 dias',
          ),
        ],
      ),
    );
  }
}

/// Barra inferior fija con selector de cantidad y boton de agregar.
class _BuyBar extends StatelessWidget {
  const _BuyBar({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAdd,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool disabled = !product.isAvailable;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: ContentWidth(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: 12,
            ),
            child: Row(
              children: <Widget>[
                if (!disabled) ...<Widget>[
                  _QuantityStepper(
                    quantity: quantity,
                    max: product.stock,
                    onChanged: onQuantityChanged,
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: FilledButton.icon(
                    onPressed: disabled ? null : onAdd,
                    icon: Icon(
                      disabled
                          ? Icons.notifications_active_rounded
                          : Icons.shopping_cart_rounded,
                      size: 20,
                    ),
                    label: Text(
                      disabled
                          ? 'Avisarme cuando llegue'
                          : 'Agregar ${Formatters.price(product.price * quantity)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget button(IconData icon, VoidCallback? onTap) => SizedBox(
      width: 38,
      height: 46,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        visualDensity: VisualDensity.compact,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          button(
            Icons.remove_rounded,
            quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ),
          button(
            Icons.add_rounded,
            quantity < max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}
