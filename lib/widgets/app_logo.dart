import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Marca de REPUESTOS PRO: simbolo + texto.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 40,
    this.showWordmark = true,
    this.onDark = false,
  });

  final double size;
  final bool showWordmark;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = onDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.brand, AppColors.brandDark],
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.35),
                blurRadius: size * 0.4,
                offset: Offset(0, size * 0.15),
              ),
            ],
          ),
          child: Icon(
            Icons.settings_rounded,
            color: Colors.white,
            size: size * 0.56,
          ),
        ),
        if (showWordmark) ...<Widget>[
          SizedBox(width: size * 0.3),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'REPUESTOS',
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: size * 0.03,
                  height: 1.05,
                  color: titleColor,
                ),
              ),
              Text(
                'PRO',
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: size * 0.16,
                  height: 1.05,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
