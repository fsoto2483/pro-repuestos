import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Banner promocional de la pantalla principal.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 520;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: AppColors.brandGradient,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brand.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: -18,
            child: Icon(
              Icons.build_circle_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, wide ? 180 : 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'TEMPORADA DE MANTENIMIENTO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                /*const Text(
                  'Hasta 20 % de descuento\nen frenos y suspension',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Repuestos originales y de marcas homologadas, con garantia escrita.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  child: const Text('Ver ofertas'),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
