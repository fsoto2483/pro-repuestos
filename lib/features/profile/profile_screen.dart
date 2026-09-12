import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/app_user.dart';
import '../../data/models/product.dart';
import '../../state/auth_controller.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/product_cover.dart';
import '../import/bulk_import_screen.dart';
import '../product/product_detail_screen.dart';

/// Perfil del usuario: datos de la cuenta, favoritos y opciones.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = context.watch<AuthController>();
    final CatalogController catalog = context.watch<CatalogController>();
    final CartController cart = context.watch<CartController>();
    final AppUser? user = auth.user;
    final double gutter = context.horizontalPadding;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          maxWidth: 820,
          child: ListView(
            padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 28),
            children: <Widget>[
              _ProfileHeader(user: user),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite_rounded,
                      value: '${catalog.favoriteCount}',
                      label: 'Favoritos',
                      color: AppColors.brand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.receipt_long_rounded,
                      value: '${cart.distinctCount}',
                      label: 'En cotizacion',
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.inventory_2_rounded,
                      value: '${catalog.stats?.products ?? 0}',
                      label: 'Referencias',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              if (catalog.favorites.isNotEmpty) ...<Widget>[
                const SizedBox(height: 26),
                const SectionHeader(
                  title: 'Tus favoritos',
                  subtitle: 'Repuestos que guardaste para despues',
                ),
                const SizedBox(height: 12),
                ...catalog.favorites.map(
                  (Product p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FavoriteTile(product: p),
                  ),
                ),
              ],

              const SizedBox(height: 26),
              Text('Catalogo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _OptionsCard(
                options: <_Option>[
                  _Option(
                    icon: Icons.upload_file_rounded,
                    title: 'Carga masiva',
                    subtitle:
                        '${catalog.stats?.products ?? 0} referencias · '
                        'actualiza desde Excel o CSV',
                    onTap: () => BulkImportScreen.open(context),
                  ),
                ],
              ),

              const SizedBox(height: 26),
              Text('Cuenta', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _OptionsCard(
                options: <_Option>[
                  const _Option(
                    icon: Icons.store_mall_directory_rounded,
                    title: 'Datos del taller',
                    subtitle: 'Razon social, NIT y direccion de despacho',
                  ),
                  const _Option(
                    icon: Icons.local_shipping_rounded,
                    title: 'Mis pedidos',
                    subtitle: 'Historial y seguimiento de despachos',
                  ),
                  const _Option(
                    icon: Icons.percent_rounded,
                    title: 'Lista de precios',
                    subtitle: 'Descuentos por volumen de tu taller',
                  ),
                  const _Option(
                    icon: Icons.support_agent_rounded,
                    title: 'Soporte tecnico',
                    subtitle: 'Ayuda para identificar la referencia correcta',
                  ),
                ],
              ),

              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context, auth),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Cerrar sesion'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'REPUESTOS PRO · version 1.0.0 (Fase 1)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    AuthController auth,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Volveras a la pantalla de inicio de sesion.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await auth.signOut();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.brandGradient,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[AppColors.brand, AppColors.brandDark],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    Pill(
                      label: user.provider == AuthProvider.google
                          ? 'Cuenta Google'
                          : 'Correo y contrasena',
                      color: AppColors.brand,
                      icon: user.provider == AuthProvider.google
                          ? Icons.g_mobiledata_rounded
                          : Icons.mail_rounded,
                      dense: true,
                    ),
                    if (user.workshopName != null)
                      Pill(
                        label: user.workshopName!,
                        color: Colors.white,
                        filled: false,
                        icon: Icons.handyman_rounded,
                        dense: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ProductDetailScreen.open(context, product),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: ProductCover(
                      product: product,
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
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${product.brand} · SKU ${product.sku}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar de favoritos',
                  onPressed: () =>
                      context.read<CatalogController>().toggleFavorite(
                        product.id,
                      ),
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.brand,
                    size: 20,
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

class _Option {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Sin `onTap` la opcion avisa que llega en una fase posterior.
  final VoidCallback? onTap;
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({required this.options});

  final List<_Option> options;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < options.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1, indent: 62),
            ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  options[i].icon,
                  size: 19,
                  color: AppColors.brand,
                ),
              ),
              title: Text(options[i].title, style: theme.textTheme.titleSmall),
              subtitle: Text(
                options[i].subtitle,
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap:
                  options[i].onTap ??
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '"${options[i].title}" llega en la siguiente fase',
                      ),
                    ),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
