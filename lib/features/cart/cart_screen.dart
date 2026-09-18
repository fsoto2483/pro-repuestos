import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cart_item.dart';
import '../../state/cart_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/product_cover.dart';
import '../product/product_detail_screen.dart';
import 'checkout_screen.dart';

/// Cotizacion en curso: lista de repuestos, cantidades y totales.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.onExploreCatalog});

  final VoidCallback onExploreCatalog;

  @override
  Widget build(BuildContext context) {
    final CartController cart = context.watch<CartController>();
    final double gutter = context.horizontalPadding;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        titleSpacing: gutter,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Mi cotizacion',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              cart.isEmpty
                  ? 'Aun no has agregado repuestos'
                  : '${Formatters.plural(cart.distinctCount, 'referencia', 'referencias')} · '
                        '${Formatters.plural(cart.totalUnits, 'unidad', 'unidades')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          if (!cart.isEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context, cart),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Vaciar'),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            ),
          SizedBox(width: gutter - 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          maxWidth: 900,
          child: cart.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Tu cotizacion esta vacia',
                  message:
                      'Agrega repuestos desde el catalogo y arma la lista de '
                      'pedido de tu taller.',
                  actionLabel: 'Explorar catalogo',
                  onAction: onExploreCatalog,
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 24),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) =>
                      _CartTile(item: cart.items[index]),
                ),
        ),
      ),
      bottomNavigationBar: cart.isEmpty ? null : _TotalsBar(cart: cart),
    );
  }

  Future<void> _confirmClear(BuildContext context, CartController cart) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Vaciar cotizacion'),
        content: const Text(
          'Se eliminaran todos los repuestos de la lista. Esta accion no se '
          'puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) cart.clear();
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CartController cart = context.read<CartController>();

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ProductDetailScreen.open(context, item.product),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 82,
                    height: 82,
                    child: ProductCover(
                      product: item.product,
                      iconScale: 0.5,
                      showSku: false,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${item.product.brand} · SKU ${item.product.sku}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          _MiniStepper(
                            quantity: item.quantity,
                            max: item.product.stock,
                            onChanged: (int q) =>
                                cart.setQuantity(item.product, q),
                          ),
                          const Spacer(),
                          Text(
                            Formatters.price(item.subtotal),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar',
                  onPressed: () => cart.remove(item.product.id),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({
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

    Widget button(IconData icon, VoidCallback? onTap) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? theme.colorScheme.outlineVariant : null,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge,
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

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: strong
                  ? theme.textTheme.titleMedium
                  : theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate,
                    ),
            ),
          ),
          Text(
            value,
            style: strong
                ? theme.textTheme.titleLarge?.copyWith(color: AppColors.brand)
                : theme.textTheme.labelLarge,
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: ContentWidth(
          maxWidth: 900,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.horizontalPadding,
              14,
              context.horizontalPadding,
              12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                row('Subtotal', Formatters.price(cart.subtotal)),
                row('IVA (19 %)', Formatters.price(cart.iva)),
                const Divider(height: 18),
                row('Total', Formatters.price(cart.total), strong: true),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => CheckoutScreen.open(context),
                  icon: const Icon(Icons.receipt_long_rounded, size: 20),
                  label: const Text('Enviar cotizacion'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
