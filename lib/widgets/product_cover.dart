import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models/part_category.dart';
import '../data/models/product.dart';

/// Portada del producto.
///
/// Si la tabla `imagenes_productos` trae una foto para el producto se muestra
/// esa. Mientras no la haya, se dibuja una portada generada a partir de la
/// categoria: degradado, patron tecnico e icono. Asi el catalogo se ve
/// consistente aunque falten fotos, y cada foto que se agregue al archivo
/// aparece sin tocar codigo.
class ProductCover extends StatelessWidget {
  const ProductCover({
    super.key,
    required this.product,
    this.iconScale = 0.42,
    this.showSku = true,
  });

  final Product product;
  final double iconScale;
  final bool showSku;

  @override
  Widget build(BuildContext context) {
    final PartCategory category = product.category;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double side = math.min(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 200,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 200,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: category.gradient,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(painter: _TechPatternPainter(seed: product.id)),
              Center(
                child: Icon(
                  category.icon,
                  size: side * iconScale,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              // La foto va encima de la portada generada, que queda de fondo
              // mientras descarga y tambien si la URL esta rota.
              if (product.imageUrl != null)
                Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  frameBuilder:
                      (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                ),
              if (showSku)
                Positioned(
                  left: 12,
                  bottom: 10,
                  child: Text(
                    product.sku,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Patron sutil de lineas y arcos que da textura "tecnica" a la portada.
class _TechPatternPainter extends CustomPainter {
  _TechPatternPainter({required this.seed});

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(seed.hashCode);

    final Paint stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.2;

    const double step = 22;
    for (double x = -size.height; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripe,
      );
    }

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.12);

    final Offset center = Offset(
      size.width * (0.62 + random.nextDouble() * 0.2),
      size.height * (0.2 + random.nextDouble() * 0.2),
    );
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, size.width * 0.12 * i, ring);
    }

    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          Colors.white.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.25, size.height * 0.85),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(_TechPatternPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
