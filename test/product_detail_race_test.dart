import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:repuestos_pro/data/models/catalog_filter.dart';
import 'package:repuestos_pro/data/models/product.dart';
import 'package:repuestos_pro/data/repositories/catalog_repository.dart';
import 'package:repuestos_pro/features/product/product_detail_screen.dart';
import 'package:repuestos_pro/state/cart_controller.dart';
import 'package:repuestos_pro/state/catalog_controller.dart';

import 'support/test_catalog.dart';

/// La ficha del producto se completa con dos consultas asincronas al abrirse.
/// Estas pruebas cubren los momentos en que esas consultas todavia no han
/// respondido, que es cuando se vio la pantalla en blanco.
void main() {
  late CatalogRepository repository;
  late Product product;

  setUp(() async {
    repository = await testCatalogRepository();
    product = (await repository.search(const CatalogFilter(), limit: 1)).single;
  });

  tearDown(() async => repository.dispose());

  Widget wrap(Widget child, CatalogController catalog) => MultiProvider(
    providers: <SingleChildWidget>[
      ChangeNotifierProvider<CatalogController>.value(value: catalog),
      ChangeNotifierProvider<CartController>(create: (_) => CartController()),
    ],
    child: MaterialApp(home: child),
  );

  testWidgets('se dibuja completa antes de que respondan las consultas', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final CatalogController catalog = CatalogController.local(repository);
    addTearDown(catalog.dispose);

    await tester.pumpWidget(
      wrap(ProductDetailScreen(product: product), catalog),
    );

    // Un solo frame: ni `fullProduct` ni `relatedTo` alcanzaron a responder.
    await tester.pump(Duration.zero);

    expect(find.text(product.name), findsOneWidget);
    expect(find.text('Descripcion'), findsOneWidget);
    expect(find.textContaining('Agregar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('se dibuja aunque el catalogo aun no haya cargado', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final CatalogController catalog = CatalogController.local(repository);
    addTearDown(catalog.dispose);

    // Se abre la ficha con la carga inicial a medio camino.
    final Future<void> loading = catalog.load();
    await tester.pumpWidget(
      wrap(ProductDetailScreen(product: product), catalog),
    );
    await tester.pump(Duration.zero);

    expect(find.text(product.name), findsOneWidget);

    await loading;
    await tester.pumpAndSettle();

    expect(find.text(product.name), findsOneWidget);
    expect(find.text('Compatibilidad'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cerrar la ficha antes de que respondan no revienta', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final CatalogController catalog = CatalogController.local(repository);
    addTearDown(catalog.dispose);

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => ProductDetailScreen.open(context, product),
            child: const Text('abrir'),
          ),
        ),
        catalog,
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
