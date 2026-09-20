import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cart_item.dart';
import '../../models/quote.dart';
import '../../models/workshop_data.dart';
import '../../services/workshop_service.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../state/quotes_controller.dart';
import '../../widgets/common.dart';
import '../profile/workshop_profile_screen.dart';
import '../quotes/quotes_screen.dart';

/// Confirma la cotización usando los datos del perfil (`users/{uid}.workshop`).
///
/// No vuelve a pedir datos del cliente: se toman del taller del usuario.
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
  final WorkshopService _workshopService = const WorkshopService();

  WorkshopData? _workshop;
  bool _loadingProfile = true;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });
    try {
      final WorkshopData? workshop = await _workshopService.getWorkshop();
      if (!mounted) return;
      setState(() {
        _workshop = workshop;
        _loadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = 'No se pudo cargar el perfil de la empresa.';
        _loadingProfile = false;
      });
    }
  }

  /// Contacto = propietario del taller, o nombre del usuario autenticado.
  String _contacto(WorkshopData? workshop) {
    final String fromWorkshop = workshop?.propietario.trim() ?? '';
    if (fromWorkshop.isNotEmpty) return fromWorkshop;
    return context.read<AuthController>().user?.fullName.trim() ?? '';
  }

  String _correo(WorkshopData? workshop) {
    final String fromWorkshop = workshop?.correo.trim() ?? '';
    if (fromWorkshop.isNotEmpty) return fromWorkshop;
    return context.read<AuthController>().user?.email.trim() ?? '';
  }

  bool _profileComplete(WorkshopData? workshop) {
    if (workshop == null) return false;
    final String razon = workshop.razonSocial.trim();
    final String ruc = workshop.ruc.trim();
    final String contacto = _contacto(workshop);
    final String telefono = workshop.telefono.trim();
    return razon.isNotEmpty &&
        ruc.isNotEmpty &&
        contacto.isNotEmpty &&
        telefono.isNotEmpty;
  }

  Future<void> _goToProfile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Complete los datos de su empresa antes de generar cotizaciones.',
        ),
      ),
    );
    await WorkshopProfileScreen.open(context);
    if (!mounted) return;
    await _loadProfile();
  }

  Future<void> _confirm() async {
    final CartController cart = context.read<CartController>();
    final QuotesController quotes = context.read<QuotesController>();
    final CatalogController catalog = context.read<CatalogController>();
    final WorkshopData? workshop = _workshop;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cotizacion esta vacia.')),
      );
      return;
    }

    if (!_profileComplete(workshop)) {
      await _goToProfile();
      return;
    }

    final Quote? saved = await quotes.confirmQuote(
      cart: cart,
      customerRazonSocial: workshop!.razonSocial,
      customerNombreComercial: workshop.nombreComercial,
      customerRuc: workshop.ruc,
      customerName: _contacto(workshop),
      customerPhone: workshop.telefono,
      customerEmail: _correo(workshop),
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

    // Sale del checkout y abre Mis Cotizaciones.
    Navigator.of(context).pop();
    if (!mounted) return;
    await QuotesScreen.open(context);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CartController cart = context.watch<CartController>();
    final QuotesController quotes = context.watch<QuotesController>();
    final double gutter = context.horizontalPadding;
    final WorkshopData? workshop = _workshop;
    final bool complete = _profileComplete(workshop);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar cotizacion'),
      ),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 720,
          child: _loadingProfile
              ? const Center(child: CircularProgressIndicator())
              : cart.isEmpty
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
                          'Datos de su empresa',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Se tomaran del perfil del taller. '
                          'No es necesario volver a ingresarlos.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_profileError != null)
                          EmptyState(
                            icon: Icons.error_outline_rounded,
                            title: 'Perfil',
                            message: _profileError!,
                            actionLabel: 'Reintentar',
                            onAction: _loadProfile,
                          )
                        else if (!complete) ...<Widget>[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radius),
                              border: Border.all(
                                color: AppColors.warning.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'Complete los datos de su empresa antes de '
                              'generar cotizaciones.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _goToProfile,
                            icon: const Icon(Icons.store_mall_directory_outlined),
                            label: const Text('Completar datos del taller'),
                          ),
                        ] else
                          _ProfileSummary(
                            razonSocial: workshop!.razonSocial,
                            nombreComercial: workshop.nombreComercial,
                            ruc: workshop.ruc,
                            contacto: _contacto(workshop),
                            telefono: workshop.telefono,
                            correo: _correo(workshop),
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
                                : 'Confirmar Cotizacion',
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.razonSocial,
    required this.nombreComercial,
    required this.ruc,
    required this.contacto,
    required this.telefono,
    required this.correo,
  });

  final String razonSocial;
  final String nombreComercial;
  final String ruc;
  final String contacto;
  final String telefono;
  final String correo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Widget line(String label, String value) {
      if (value.trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.slate,
                ),
              ),
            ),
            Expanded(
              child: Text(value, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          line('Razon Social', razonSocial),
          line('Nombre Comercial', nombreComercial),
          line('RUC', ruc),
          line('Contacto', contacto),
          line('Telefono', telefono),
          line('Correo', correo),
        ],
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
