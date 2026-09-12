import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repuestos_pro/data/db/app_database.dart';
import 'package:repuestos_pro/data/import/catalog_importer.dart';
import 'package:repuestos_pro/data/import/catalog_sources.dart';
import 'package:repuestos_pro/data/import/catalog_tables.dart';
import 'package:repuestos_pro/data/import/import_report.dart';
import 'package:repuestos_pro/data/models/catalog_filter.dart';
import 'package:repuestos_pro/data/models/product.dart';
import 'package:repuestos_pro/data/models/vehicle.dart';

/// Lee los mismos CSV que se empaquetan con la aplicacion.
Map<CatalogTable, ParsedSheet> _bundledSheets() {
  final Map<CatalogTable, ParsedSheet> sheets = <CatalogTable, ParsedSheet>{};
  for (final CatalogTable table in CatalogTable.loadOrder) {
    final File file = File('assets/data/${table.fileName}');
    if (!file.existsSync()) continue;
    sheets[table] = CatalogSourceReader.parseCsv(
      table.fileName,
      file.readAsStringSync(),
    );
  }
  return sheets;
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('Catalogo que trae la aplicacion', () {
    test('los CSV entran completos y sin errores', () async {
      final ImportReport report = await CatalogImporter(
        db,
      ).import(_bundledSheets());

      expect(report.fatalError, isNull);
      expect(report.errors, isEmpty, reason: report.summary);
      expect(report.applied, isTrue);

      final CatalogStats stats = await db.stats();
      expect(stats.categories, 7);
      expect(stats.products, greaterThan(300));
      expect(stats.makes, greaterThan(5));
      expect(stats.fitments, greaterThan(stats.products));
    });

    test('todo producto queda con categoria, marca y compatibilidad', () async {
      await CatalogImporter(db).import(_bundledSheets());

      final List<Product> products = await db.searchProducts(
        const CatalogFilter(),
        limit: 1000,
      );

      expect(products, isNotEmpty);
      for (final Product product in products.take(40)) {
        expect(product.sku, isNotEmpty);
        expect(product.oem, isNotEmpty);
        expect(product.brand, isNotEmpty);
        expect(product.category.name, isNotEmpty);
        expect(product.price, greaterThan(0));
      }

      final Product first = products.first;
      final Product? full = await db.productById(first.id);
      expect(full, isNotNull);
      expect(full!.fitments, isNotEmpty);
      expect(full.specs, isNotEmpty);
    });
  });

  group('Filtros en cascada', () {
    setUp(() async => CatalogImporter(db).import(_bundledSheets()));

    test('marca, modelo, motor y ano se van encadenando', () async {
      final List<VehicleMake> makes = await db.vehicleMakesWithCounts();
      final VehicleMake make = makes.firstWhere(
        (VehicleMake m) => m.name == 'Chevrolet',
      );

      final List<VehicleModel> models = await db.modelsForMake(make.id);
      expect(models, isNotEmpty);
      expect(models.every((VehicleModel m) => m.makeId == make.id), isTrue);

      final VehicleModel model = models.first;
      final List<Engine> engines = await db.enginesForModel(model.id);
      expect(engines, isNotEmpty);

      final List<int> years = await db.yearsFor(
        modelId: model.id,
        engineId: engines.first.id,
      );
      expect(years, isNotEmpty);
      expect(years.first, greaterThanOrEqualTo(years.last));

      final int byMake = await db.countProducts(
        CatalogFilter(makeId: make.id),
      );
      final int byModel = await db.countProducts(
        CatalogFilter(makeId: make.id, modelId: model.id),
      );
      final int byEngine = await db.countProducts(
        CatalogFilter(
          makeId: make.id,
          modelId: model.id,
          engineId: engines.first.id,
        ),
      );

      expect(byMake, greaterThan(0));
      expect(byModel, lessThanOrEqualTo(byMake));
      expect(byEngine, lessThanOrEqualTo(byModel));
    });

    test('los productos filtrados sirven para el vehiculo elegido', () async {
      final VehicleMake make = (await db.vehicleMakesWithCounts()).firstWhere(
        (VehicleMake m) => m.name == 'Renault',
      );
      final VehicleModel model = (await db.modelsForMake(make.id)).first;

      final List<Product> found = await db.searchProducts(
        CatalogFilter(makeId: make.id, modelId: model.id),
        limit: 20,
      );
      expect(found, isNotEmpty);

      for (final Product product in found) {
        final List<Fitment> fitments = await db.fitmentsFor(product.id);
        expect(
          fitments.any((Fitment f) => f.modelName == model.name),
          isTrue,
          reason: '${product.sku} no deberia aparecer para ${model.name}',
        );
      }
    });

    test('la busqueda por texto encuentra por SKU y por OEM', () async {
      final Product product = (await db.searchProducts(
        const CatalogFilter(),
        limit: 1,
      )).single;

      for (final String needle in <String>[product.sku, product.oem]) {
        final List<Product> found = await db.searchProducts(
          CatalogFilter(query: needle),
        );
        expect(
          found.map((Product p) => p.id),
          contains(product.id),
          reason: 'No se encontro con "$needle"',
        );
      }
    });
  });

  group('Validacion de la carga masiva', () {
    ParsedSheet sheet(String name, List<String> lines) =>
        CatalogSourceReader.parseCsv(name, lines.join('\n'));

    test('una fila sin campo obligatorio se descarta y se reporta', () async {
      final ImportReport report = await CatalogImporter(db).import(
        <CatalogTable, ParsedSheet>{
          CatalogTable.categories: sheet('categorias.csv', <String>[
            'id,nombre,descripcion',
            'frenos,Frenos,Pastillas y discos',
            ',Sin id,Se descarta',
            'motor,,Se descarta por nombre',
          ]),
        },
      );

      expect(report.applied, isTrue);
      expect(report.errors.length, 2);
      expect(await db.stats().then((CatalogStats s) => s.categories), 1);
    });

    test('un producto que apunta a una categoria inexistente no entra',
        () async {
      final ImportReport report = await CatalogImporter(db).import(
        <CatalogTable, ParsedSheet>{
          CatalogTable.categories: sheet('categorias.csv', <String>[
            'id,nombre',
            'frenos,Frenos',
          ]),
          CatalogTable.partBrands: sheet('marcas_repuesto.csv', <String>[
            'id,nombre',
            'bosch,Bosch',
          ]),
          CatalogTable.products: sheet('productos.csv', <String>[
            'id,sku,oem,nombre,categoria_id,marca_repuesto_id,precio,stock',
            'p1,SKU-1,OEM-1,Pastillas,frenos,bosch,189000,5',
            'p2,SKU-2,OEM-2,Bujia,inventada,bosch,45000,3',
          ]),
        },
      );

      expect(report.applied, isTrue);
      expect(await db.stats().then((CatalogStats s) => s.products), 1);
      expect(
        report.errors.single.message,
        contains('inventada'),
      );
    });

    test('falta una columna obligatoria: no se guarda nada', () async {
      await CatalogImporter(db).import(_bundledSheets());
      final int before = await db.stats().then((CatalogStats s) => s.products);

      final ImportReport report = await CatalogImporter(db).import(
        <CatalogTable, ParsedSheet>{
          CatalogTable.categories: sheet('categorias.csv', <String>[
            'identificador,titulo',
            'frenos,Frenos',
          ]),
        },
      );

      expect(report.applied, isFalse);
      expect(report.fatalError, contains('id'));
      expect(await db.stats().then((CatalogStats s) => s.products), before);
    });

    test('el precio se entiende con separador de miles y con simbolo',
        () async {
      await CatalogImporter(db).import(<CatalogTable, ParsedSheet>{
        CatalogTable.categories: sheet('categorias.csv', <String>[
          'id,nombre',
          'frenos,Frenos',
        ]),
        CatalogTable.partBrands: sheet('marcas_repuesto.csv', <String>[
          'id,nombre',
          'bosch,Bosch',
        ]),
        CatalogTable.products: sheet('productos.csv', <String>[
          'id,sku,oem,nombre,categoria_id,marca_repuesto_id,precio,stock',
          'p1,SKU-1,OEM-1,Con puntos,frenos,bosch,189.000,5',
          'p2,SKU-2,OEM-2,Con simbolo,frenos,bosch,\$ 245.900,5',
          'p3,SKU-3,OEM-3,Con decimales,frenos,bosch,"1234,50",5',
        ]),
      });

      final List<Product> products = await db.searchProducts(
        const CatalogFilter(sort: ProductSort.priceAsc),
      );
      expect(
        products.map((Product p) => p.price),
        <double>[1234.5, 189000, 245900],
      );
    });

    test('una tabla que no viene en el archivo conserva lo que ya estaba',
        () async {
      await CatalogImporter(db).import(_bundledSheets());
      final CatalogStats before = await db.stats();

      // Solo se manda la lista de marcas de repuesto, recortada.
      await CatalogImporter(db).import(<CatalogTable, ParsedSheet>{
        CatalogTable.partBrands: sheet('marcas_repuesto.csv', <String>[
          'id,nombre',
          'bosch,Bosch',
        ]),
      });

      final CatalogStats after = await db.stats();
      expect(after.categories, before.categories);
      expect(after.makes, before.makes);
      expect(after.partBrands, 1);
      // Los productos de las marcas eliminadas se van con ellas.
      expect(after.products, lessThan(before.products));
      expect(after.products, greaterThan(0));
    });
  });
}
