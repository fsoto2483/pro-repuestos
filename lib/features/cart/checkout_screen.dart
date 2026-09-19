import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/app_user.dart';
import '../../data/models/cart_item.dart';
import '../../models/quote.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../state/quotes_controller.dart';
import '../../widgets/common.dart';

/// Confirma la cotización: datos del cliente + resumen + guardado en Firestore.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _companyCtrl;

  @override
  void initState() {
    super.initState();
    final AppUser? user = context.read<AuthController>().user;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _companyCtrl = TextEditingController(text: user?.workshopName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final CartController cart = context.read<CartController>();
    final QuotesController quotes = context.read<QuotesController>();
    final CatalogController catalog = context.read<CatalogController>();

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cotizacion esta vacia.')),
      );
      return;
    }

    final Quote? saved = await quotes.confirmQuote(
      cart: cart,
      customerName: _nameCtrl.text,
      customerPhone: _phoneCtrl.text,
      customerEmail: _emailCtrl.text,
      vehicleBrand: catalog.selectedMake?.name ?? '',
      vehicleModel: catalog.selectedModel?.name ?? '',
      vehicleYear: '',
      vehicleEngine: catalog.selectedEngine?.name ?? '',
    );

    if (!mounted) return;

    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quotes.error ?? 'No se pudo guardar la cotizacion.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cotización guardada correctamente')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CartController cart = context.watch<CartController>();
    final QuotesController quotes = context.watch<QuotesController>();
    final double gutter = context.horizontalPadding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar cotizacion'),
      ),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 720,
          child: cart.isEmpty
              ? EmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Sin productos',
                  message: 'Vuelve al carrito y agrega referencias.',
                  actionLabel: 'Volver',
                  onAction: () => Navigator.of(context).pop(),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 28),
                  children: <Widget>[
                    Text(
                      'Datos del cliente',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Ingresa el nombre'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Telefono',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Ingresa el telefono'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (String? v) {
                              final String value = (v ?? '').trim();
                              if (value.isEmpty) return 'Ingresa el correo';
                              if (!value.contains('@')) {
                                return 'Correo no valido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _companyCtrl,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Empresa',
                              prefixIcon: Icon(Icons.storefront_outlined),
                            ),
                            validator: (String? v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Ingresa la empresa'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Resumen de la cotizacion',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...cart.items.map(
                      (CartItem item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SummaryLine(item: item),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _TotalsCard(cart: cart),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: quotes.saving ? null : _confirm,
                      icon: quotes.saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        quotes.saving
                            ? 'Guardando...'
                            : 'Guardar Cotización',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.product.name, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${item.product.sku} · ${item.product.brand}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('x${item.quantity}', style: theme.textTheme.labelLarge),
              Text(
                Formatters.price(item.subtotal),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget row(String label, String value, {bool strong = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: strong
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.slate),
                ),
              ),
              Text(
                value,
                style: strong
                    ? theme.textTheme.titleLarge
                        ?.copyWith(color: AppColors.brand)
                    : theme.textTheme.labelLarge,
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
      child: Column(
        children: <Widget>[
          row('Subtotal', Formatters.price(cart.subtotal)),
          row('IGV', Formatters.price(cart.iva)),
          const Divider(height: 18),
          row('Total', Formatters.price(cart.total), strong: true),
        ],
      ),
    );
  }
}
