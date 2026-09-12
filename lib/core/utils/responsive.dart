import 'package:flutter/widgets.dart';

/// Tamanos de pantalla soportados.
///
/// La app corre en Android, Web y Windows, asi que cada pantalla decide su
/// distribucion a partir de estos rangos en lugar de asumir un movil.
enum ScreenSize { mobile, tablet, desktop }

class Breakpoints {
  const Breakpoints._();

  static const double tablet = 720;
  static const double desktop = 1100;

  /// Ancho maximo del contenido para que en monitores grandes el catalogo no
  /// quede estirado de lado a lado.
  static const double maxContentWidth = 1240;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize {
    final double width = screenWidth;
    if (width >= Breakpoints.desktop) return ScreenSize.desktop;
    if (width >= Breakpoints.tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  /// En pantallas anchas usamos una barra lateral; en moviles, la barra
  /// inferior de navegacion.
  bool get usesSideNavigation => screenWidth >= Breakpoints.tablet;

  /// Margen horizontal coherente en todas las pantallas.
  double get horizontalPadding {
    switch (screenSize) {
      case ScreenSize.mobile:
        return 16;
      case ScreenSize.tablet:
        return 24;
      case ScreenSize.desktop:
        return 32;
    }
  }

  /// Numero de columnas de la grilla de productos.
  int gridColumns({double cardTarget = 280}) {
    final double usable =
        (screenWidth.clamp(0, Breakpoints.maxContentWidth) as double) -
        horizontalPadding * 2;
    final int columns = (usable / cardTarget).floor();
    return columns.clamp(2, 5);
  }
}

/// Centra y limita el ancho del contenido en pantallas grandes.
///
/// `heightFactor: 1` hace que solo ocupe el alto que necesite su hijo. Es
/// clave cuando se usa dentro de una barra inferior: sin eso se estiraria
/// hasta cubrir la pantalla completa y dejaria el cuerpo sin espacio.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Breakpoints.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
