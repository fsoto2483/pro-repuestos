import 'package:flutter_test/flutter_test.dart';
import 'package:repuestos_pro/data/models/product.dart';
import 'package:repuestos_pro/data/models/vehicle.dart';
import 'package:repuestos_pro/data/repositories/catalog_repository.dart';
import 'package:repuestos_pro/state/catalog_controller.dart';

import 'support/test_catalog.dart';

void main() {
  late CatalogRepository repository;
  late CatalogController catalog;

  setUp(() async {
    repository = await testCatalogRepository();
    catalog = CatalogController.local(repository);
    await catalog.load();
  });

  tearDown(() async {
    catalog.dispose();
    await repository.dispose();
  });

  test('el catalogo abre con datos y sin filtros', () {
    expect(catalog.status, CatalogStatus.ready);
    expect(catalog.categories.length, 7);
    expect(catalog.makes, isNotEmpty);
    expect(catalog.partBrands, isNotEmpty);
    expect(catalog.featured, isNotEmpty);
    expect(catalog.results, isNotEmpty);
    expect(catalog.hasActiveFilters, isFalse);
  });

  test('cada nivel del vehiculo habilita el siguiente', () async {
    expect(catalog.models, isEmpty);
    expect(catalog.engines, isEmpty);
    expect(catalog.years, isEmpty);

    final VehicleMake chevrolet = catalog.makes.firstWhere(
      (VehicleMake m) => m.name == 'Chevrolet',
    );
    await catalog.selectMake(chevrolet.id);
    expect(catalog.models, isNotEmpty);
    expect(catalog.engines, isEmpty, reason: 'el motor espera al modelo');

    await catalog.selectModel(catalog.models.first.id);
    expect(catalog.engines, isNotEmpty);
    expect(catalog.years, isNotEmpty);

    await catalog.selectEngine(catalog.engines.first.id);
    catalog.selectYear(catalog.years.first);

    expect(catalog.vehicleLabel, startsWith('Chevrolet '));
    expect(catalog.vehicleLabel, endsWith('${catalog.years.first}'));
  });

  test('cambiar de marca limpia modelo, motor y ano', () async {
    final VehicleMake chevrolet = catalog.makes.firstWhere(
      (VehicleMake m) => m.name == 'Chevrolet',
    );
    await catalog.selectMake(chevrolet.id);
    await catalog.selectModel(catalog.models.first.id);
    await catalog.selectEngine(catalog.engines.first.id);
    catalog.selectYear(catalog.years.first);

    final VehicleMake renault = catalog.makes.firstWhere(
      (VehicleMake m) => m.name == 'Renault',
    );
    await catalog.selectMake(renault.id);

    expect(catalog.modelId, isNull);
    expect(catalog.engineId, isNull);
    expect(catalog.year, isNull);
    expect(catalog.engines, isEmpty);
    expect(catalog.years, isEmpty);
    expect(catalog.models, isNotEmpty);
    expect(
      catalog.models.every((VehicleModel m) => m.makeId == renault.id),
      isTrue,
    );
  });

  test('filtrar por vehiculo reduce los resultados', () async {
    final int sinFiltro = catalog.totalResults;

    final VehicleMake make = catalog.makes.first;
    await catalog.selectMake(make.id);
    final int porMarca = catalog.totalResults;

    await catalog.selectModel(catalog.models.first.id);
    final int porModelo = catalog.totalResults;

    expect(porMarca, lessThan(sinFiltro));
    expect(porModelo, lessThanOrEqualTo(porMarca));
    expect(porModelo, greaterThan(0));
  });

  test('la categoria se combina con el vehiculo', () async {
    final VehicleMake make = catalog.makes.first;
    await catalog.selectMake(make.id);
    final int porMarca = catalog.totalResults;

    catalog.selectCategory('frenos');
    await Future<void>.delayed(Duration.zero);

    expect(catalog.totalResults, lessThan(porMarca));
    expect(
      catalog.results.every((Product p) => p.category.id == 'frenos'),
      isTrue,
    );
    expect(catalog.makeId, make.id, reason: 'el vehiculo no se debe perder');
  });

  test('quitar el vehiculo devuelve el catalogo completo', () async {
    final int total = catalog.totalResults;

    await catalog.selectMake(catalog.makes.first.id);
    expect(catalog.totalResults, lessThan(total));

    catalog.clearVehicle();
    await Future<void>.delayed(Duration.zero);

    expect(catalog.makeId, isNull);
    expect(catalog.models, isEmpty);
    expect(catalog.totalResults, total);
  });
}
