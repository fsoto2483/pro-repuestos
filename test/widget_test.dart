import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repuestos_pro/app.dart';
import 'package:repuestos_pro/data/models/catalog_filter.dart';
import 'package:repuestos_pro/data/models/product.dart';
import 'package:repuestos_pro/data/repositories/catalog_repository.dart';

import 'package:repuestos_pro/data/repositories/local_catalog_read_source.dart';
import 'support/test_catalog.dart';

void main() {
  late CatalogRepository repository;

  setUp(() async => repository = await testCatalogRepository());
  tearDown(() async => repository.dispose());

  Future<void> signIn(WidgetTester tester) async {
    await tester.pumpWidget(
      RepuestosProApp(
        catalogRepository: repository,
        catalogReadSource: LocalCatalogReadSource(repository),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electronico'),
      'demo@repuestospro.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contrasena'),
      'repuestos123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Ingresar'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('la app abre en la pantalla de inicio de sesion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      RepuestosProApp(
        catalogRepository: repository,
        catalogReadSource: LocalCatalogReadSource(repository),
      ),
    );
    await tester.pump();

    expect(find.text('Inicia sesion'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
  });

  testWidgets('con las credenciales de prueba se entra al catalogo', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await signIn(tester);

    expect(find.text('Catalogo'), findsWidgets);
    expect(find.text('Hola, Felipe'), findsOneWidget);
    expect(find.text('Busca por tu vehiculo'), findsOneWidget);
  });

  testWidgets('la busqueda por SKU deja una sola referencia', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final Product target = (await repository.search(
      const CatalogFilter(),
      limit: 1,
    )).single;

    await signIn(tester);

    await tester.enterText(find.byType(TextField).first, target.sku);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('1 referencia'), findsOneWidget);
  });
}
