import 'package:drift/drift.dart';

/// Esquema relacional del catalogo.
///
/// Cada clase de aqui se convierte en una tabla real de SQLite. Los nombres de
/// columna se escriben en `snake_case` a proposito: son los mismos que tendria
/// una base de datos Postgres, para que migrar a un backend mas adelante no
/// obligue a renombrar nada.

/// Categorias del catalogo: Frenos, Motor, Suspension, etc.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();

  /// Clave del icono. Se guarda el nombre y no el codigo numerico porque
  /// Flutter necesita iconos constantes para poder optimizar el tamano final.
  TextColumn get iconKey => text().withDefault(const Constant('default'))();

  /// Color en formato hexadecimal, por ejemplo `#E03131`.
  TextColumn get colorHex => text().withDefault(const Constant('#FF5A1F'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Marcas del repuesto: Bosch, Brembo, Monroe, NGK...
@DataClassName('PartBrandRow')
class PartBrands extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get country => text().withDefault(const Constant(''))();

  /// `original`, `homologada` o `alternativa`.
  TextColumn get tier => text().withDefault(const Constant('homologada'))();
  TextColumn get logoUrl => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Marcas de vehiculo: Chevrolet, Renault, Hyundai...
///
/// Es el primer nivel del filtro en cascada.
@DataClassName('VehicleMakeRow')
class VehicleMakes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get country => text().withDefault(const Constant(''))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Modelos de cada marca: Spark GT, Logan, Accent...
@DataClassName('VehicleModelRow')
class VehicleModels extends Table {
  TextColumn get id => text()();
  TextColumn get makeId =>
      text().references(VehicleMakes, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();

  /// Hatchback, sedan, SUV, pickup...
  TextColumn get bodyType => text().withDefault(const Constant(''))();
  IntColumn get yearFrom => integer()();
  IntColumn get yearTo => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Motores de cada modelo: `G4LC 1.4 16V`, `K4M 1.6 16V`...
@DataClassName('EngineRow')
class Engines extends Table {
  TextColumn get id => text()();
  TextColumn get modelId =>
      text().references(VehicleModels, #id, onDelete: KeyAction.cascade)();

  /// Codigo de fabrica del motor, por ejemplo `G4LC`.
  TextColumn get code => text()();
  TextColumn get name => text()();

  /// Cilindrada en litros.
  RealColumn get displacement => real().withDefault(const Constant(0))();

  /// Gasolina, diesel, hibrido...
  TextColumn get fuel => text().withDefault(const Constant('Gasolina'))();
  IntColumn get horsepower => integer().withDefault(const Constant(0))();
  IntColumn get yearFrom => integer()();
  IntColumn get yearTo => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Repuestos del catalogo.
@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text().unique()();
  TextColumn get oem => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get partBrandId =>
      text().references(PartBrands, #id, onDelete: KeyAction.cascade)();
  RealColumn get price => real()();
  RealColumn get previousPrice => real().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get warrantyMonths => integer().withDefault(const Constant(12))();
  RealColumn get rating => real().withDefault(const Constant(0))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  BoolColumn get isFeatured =>
      boolean().withDefault(const Constant(false))();

  /// Ficha tecnica serializada como JSON: `{"Diametro":"280 mm"}`.
  TextColumn get specsJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Imagenes de cada producto. Un producto puede tener varias.
@DataClassName('ProductImageRow')
class ProductImages extends Table {
  TextColumn get id => text()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get url => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Compatibilidad: que repuesto sirve para que modelo, motor y rango de anos.
///
/// Es la tabla que hace posible el filtro Marca > Modelo > Motor > Ano.
/// `engineId` puede quedar vacio cuando el repuesto sirve para todos los
/// motores de ese modelo (por ejemplo, una pastilla de freno).
@DataClassName('FitmentRow')
class Fitments extends Table {
  TextColumn get id => text()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  TextColumn get modelId =>
      text().references(VehicleModels, #id, onDelete: KeyAction.cascade)();
  TextColumn get engineId =>
      text().nullable().references(Engines, #id, onDelete: KeyAction.cascade)();
  IntColumn get yearFrom => integer()();
  IntColumn get yearTo => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
