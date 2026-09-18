import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repuestos_pro/data/models/catalog_filter.dart';
import 'package:repuestos_pro/data/models/product.dart';
import 'package:repuestos_pro/data/repositories/catalog_repository.dart';
import 'package:repuestos_pro/features/cart/cart_screen.dart';
import 'package:repuestos_pro/features/product/product_detail_screen.dart';
import 'package:repuestos_pro/state/cart_controller.dart';
import 'package:repuestos_pro/state/catalog_controller.dart';

import 'support/test_catalog.dart';

/// Regresion: las pantallas con barra inferior fija (detalle y cotizacion)
/// dejaban el cuerpo con altura cero porque la barra se estiraba hasta cubrir
/// toda la pantalla. Estas pruebas verifican que el contenido se dibuje.
void main() {
  late CatalogRepository repository;
  late Product product;

  setUp(() async {
    repository = await testCatalogRepository();
    product = (await repository.search(const CatalogFilter(), limit: 1)).single;
  });

  tearDown(() async => repository.dispose());

  Widget wrap(Widget child) => MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<CatalogController>(
        create: (_) => CatalogController.local(repository),
      ),
      ChangeNotifierProvider<CartController>(
        create: (_) => CartController()..add(product),
      ),
    ],
    child: MaterialApp(home: child),
  );

  for (final (String label, Size size) in <(String, Size)>[
    ('escritorio', Size(1400, 2000)),
    ('movil', Size(420, 900)),
  ]) {
    testWidgets('el detalle del producto se dibuja en $label', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(wrap(ProductDetailScreen(product: product)));
      await tester.pump();

      expect(find.text(product.name), findsOneWidget);
      expect(find.textContaining('Agregar'), findsOneWidget);

      // En movil el resto queda debajo del pliegue, por eso se desplaza.
      await tester.scrollUntilVisible(
        find.text('Ficha tecnica'),
        320,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Ficha tecnica'), findsOneWidget);
    });
  }

  testWidgets('la cotizacion lista los productos agregados', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(CartScreen(onExploreCatalog: () {})));
    await tester.pump();

    expect(find.text(product.name), findsOneWidget);
    expect(find.text('1 referencia · 1 unidad'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('los precios usan el formato colombiano', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(CartScreen(onExploreCatalog: () {})));
    await tester.pump();

    expect(find.textContaining(RegExp(r'^\$ \d{1,3}\.\d{3}$')), findsWidgets);
  });
}
