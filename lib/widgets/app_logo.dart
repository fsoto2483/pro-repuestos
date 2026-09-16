import 'package:flutter/material.dart';

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
    final bool isDesktop =
        MediaQuery.of(context).size.width > 900;

    return Image.asset(
      'assets/images/logo_lcc.png',
      height: isDesktop ? 70 : size,
      fit: BoxFit.contain,
    );
  }
}