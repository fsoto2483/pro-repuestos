import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';

import '../models/catalog_filter.dart';
import '../models/part_category.dart';
import '../models/product.dart';
import '../models/vehicle.dart';
import 'connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

void _quoteLog(String message) {
  // ignore: avoid_print
  print(message);
  developer.log(message, name: 'QUOTE_DEBUG');
}

/// Resumen de cuantos registros hay en cada tabla.
class CatalogStats {
  const CatalogStats({
    required this.categories,
    required this.partBrands,
    required this.makes,
    required this.models,
    required this.engines,
    required this.products,
    required this.images,
    required this.fitments,
  });

  final int categories;
  final int partBrands;
  final int makes;
  final int models;
  final int engines;
  final int products;
  final int images;
  final int fitments;

  bool get isEmpty => products == 0;

  int get total =>
      categories +
      partBrands +
      makes +
      models +
      engines +
      products +
      images +
      fitments;
}

@DriftDatabase(
  tables: <Type>[
    Categories,
    PartBrands,
    VehicleMakes,
    VehicleModels,
    Engines,
    Products,
    ProductImages,
    Fitments,
    Quotes,
    QuoteItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _shared;

  /// Instancia compartida del catalogo local (Drift).
  static AppDatabase get instance => AppDatabase();

  factory AppDatabase() {
    return _shared ??= AppDatabase._();
  }

  AppDatabase._() : super(openCatalogConnection());

  /// Constructor usado en las pruebas, donde la base vive solo en memoria.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      _quoteLog('[QUOTE_DEBUG] migration.onCreate schemaVersion=$schemaVersion');
      await m.createAll();
      _quoteLog('[QUOTE_DEBUG] migration.onCreate createAll OK');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      _quoteLog('[QUOTE_DEBUG] migration.onUpgrade from=$from to=$to');
      if (from < 2) {
        _quoteLog('[QUOTE_DEBUG] creando tablas quotes / quote_items');
        await m.createTable(quotes);
        await m.createTable(quoteItems);
        _quoteLog('[QUOTE_DEBUG] tablas quotes creadas OK');
      }
    },
    beforeOpen: (OpeningDetails details) async {
      _quoteLog(
        '[QUOTE_DEBUG] beforeOpen wasCreated=${details.wasCreated} '
        'hadUpgrade=${details.hadUpgrade} '
        'versionNow=${details.versionNow} '
        'versionBefore=${details.versionBefore}',
      );
      // Sin esto SQLite acepta filas huerfanas y la compatibilidad podria
      // apuntar a modelos que ya no existen.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ------------------------------------------------------------- catalogos

  Future<CatalogStats> stats() async {
    Future<int> count(String table) async {
      final QueryRow row = await customSelect(
        'SELECT COUNT(*) AS c FROM $table',
      ).getSingle();
      return row.read<int>('c');
    }

    return CatalogStats(
      categories: await count('categories'),
      partBrands: await count('part_brands'),
      makes: await count('vehicle_makes'),
      models: await count('vehicle_models'),
      engines: await count('engines'),
      products: await count('products'),
      images: await count('product_images'),
      fitments: await count('fitments'),
    );
  }

  Future<List<PartCategory>> categoriesWithCounts() async {
    final List<QueryRow> rows = await customSelect(
      '''
      SELECT c.*, (
        SELECT COUNT(*) FROM products p WHERE p.category_id = c.id
      ) AS product_count
      FROM categories c
      ORDER BY c.sort_order ASC, c.name ASC
      ''',
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        categories,
        products,
      },
    ).get();

    return rows.map(_categoryFromRow).toList();
  }

  Future<List<VehicleMake>> vehicleMakesWithCounts() async {
    final List<QueryRow> rows = await customSelect(
      '''
      SELECT m.*, (
        SELECT COUNT(*) FROM vehicle_models vm WHERE vm.make_id = m.id
      ) AS model_count
      FROM vehicle_makes m
      ORDER BY m.name ASC
      ''',
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        vehicleMakes,
        vehicleModels,
      },
    ).get();

    return rows
        .map(
          (QueryRow r) => VehicleMake(
            id: r.read<String>('id'),
            name: r.read<String>('name'),
            country: r.read<String>('country'),
            modelCount: r.read<int>('model_count'),
          ),
        )
        .toList();
  }

  Future<List<VehicleModel>> modelsForMake(String makeId) async {
    final List<VehicleModelRow> rows =
        await (select(vehicleModels)
              ..where((VehicleModels t) => t.makeId.equals(makeId))
              ..orderBy(<OrderClauseGenerator<VehicleModels>>[
                (VehicleModels t) => OrderingTerm.asc(t.name),
              ]))
            .get();

    return rows
        .map(
          (VehicleModelRow r) => VehicleModel(
            id: r.id,
            makeId: r.makeId,
            name: r.name,
            bodyType: r.bodyType,
            yearFrom: r.yearFrom,
            yearTo: r.yearTo,
          ),
        )
        .toList();
  }

  Future<List<Engine>> enginesForModel(String modelId) async {
    final List<EngineRow> rows =
        await (select(engines)
              ..where((Engines t) => t.modelId.equals(modelId))
              ..orderBy(<OrderClauseGenerator<Engines>>[
                (Engines t) => OrderingTerm.asc(t.displacement),
              ]))
            .get();

    return rows
        .map(
          (EngineRow r) => Engine(
            id: r.id,
            modelId: r.modelId,
            code: r.code,
            name: r.name,
            displacement: r.displacement,
            fuel: r.fuel,
            horsepower: r.horsepower,
            yearFrom: r.yearFrom,
            yearTo: r.yearTo,
          ),
        )
        .toList();
  }

  /// Anos disponibles para un modelo, acotados al motor cuando se eligio uno.
  Future<List<int>> yearsFor({
    required String modelId,
    String? engineId,
  }) async {
    final VehicleModelRow? model = await (select(
      vehicleModels,
    )..where((VehicleModels t) => t.id.equals(modelId))).getSingleOrNull();
    if (model == null) return const <int>[];

    int from = model.yearFrom;
    int to = model.yearTo;

    if (engineId != null) {
      final EngineRow? engine = await (select(
        engines,
      )..where((Engines t) => t.id.equals(engineId))).getSingleOrNull();
      if (engine != null) {
        from = engine.yearFrom > from ? engine.yearFrom : from;
        to = engine.yearTo < to ? engine.yearTo : to;
      }
    }

    return <int>[for (int y = to; y >= from; y--) y];
  }

  Future<List<PartBrand>> partBrandsWithCounts() async {
    final List<QueryRow> rows = await customSelect(
      '''
      SELECT b.*, (
        SELECT COUNT(*) FROM products p WHERE p.part_brand_id = b.id
      ) AS product_count
      FROM part_brands b
      ORDER BY b.name ASC
      ''',
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        partBrands,
        products,
      },
    ).get();

    return rows
        .map(
          (QueryRow r) => PartBrand(
            id: r.read<String>('id'),
            name: r.read<String>('name'),
            country: r.read<String>('country'),
            tier: r.read<String>('tier'),
            productCount: r.read<int>('product_count'),
          ),
        )
        .toList();
  }

  // -------------------------------------------------------------- productos

  Future<List<Product>> searchProducts(
    CatalogFilter filter, {
    int limit = 200,
    int offset = 0,
  }) async {
    final _WhereClause clause = _buildWhere(filter);

    final List<QueryRow> rows = await customSelect(
      '''
      $_productSelect
      ${clause.sql}
      ORDER BY ${_orderBy(filter.sort)}
      LIMIT ? OFFSET ?
      ''',
      variables: <Variable<Object>>[
        ...clause.variables,
        Variable<int>(limit),
        Variable<int>(offset),
      ],
      readsFrom: _productReads,
    ).get();

    return rows.map(_productFromRow).toList();
  }

  Future<int> countProducts(CatalogFilter filter) async {
    final _WhereClause clause = _buildWhere(filter);
    final QueryRow row = await customSelect(
      '''
      SELECT COUNT(*) AS c
      FROM products p
      JOIN categories c2 ON c2.id = p.category_id
      JOIN part_brands b ON b.id = p.part_brand_id
      ${clause.sql}
      ''',
      variables: clause.variables,
      readsFrom: _productReads,
    ).getSingle();
    return row.read<int>('c');
  }

  Future<List<Product>> featuredProducts({int limit = 10}) async {
    final List<QueryRow> rows = await customSelect(
      '''
      $_productSelect
      WHERE p.is_featured = 1
      ORDER BY p.rating DESC
      LIMIT ?
      ''',
      variables: <Variable<Object>>[Variable<int>(limit)],
      readsFrom: _productReads,
    ).get();
    return rows.map(_productFromRow).toList();
  }

  /// Producto completo: incluye todas sus imagenes y su compatibilidad.
  Future<Product?> productById(String id) async {
    final List<QueryRow> rows = await customSelect(
      '$_productSelect WHERE p.id = ?',
      variables: <Variable<Object>>[Variable<String>(id)],
      readsFrom: _productReads,
    ).get();
    if (rows.isEmpty) return null;

    final Product base = _productFromRow(rows.first);
    return base.copyWith(
      images: await imagesFor(id),
      fitments: await fitmentsFor(id),
    );
  }

  Future<List<String>> imagesFor(String productId) async {
    final List<ProductImageRow> rows =
        await (select(productImages)
              ..where((ProductImages t) => t.productId.equals(productId))
              ..orderBy(<OrderClauseGenerator<ProductImages>>[
                (ProductImages t) => OrderingTerm.desc(t.isPrimary),
                (ProductImages t) => OrderingTerm.asc(t.sortOrder),
              ]))
            .get();
    return rows.map((ProductImageRow r) => r.url).toList();
  }

  Future<List<Fitment>> fitmentsFor(String productId) async {
    final List<QueryRow> rows = await customSelect(
      '''
      SELECT mk.name AS make_name, vm.name AS model_name,
             e.name AS engine_name, f.year_from, f.year_to
      FROM fitments f
      JOIN vehicle_models vm ON vm.id = f.model_id
      JOIN vehicle_makes mk ON mk.id = vm.make_id
      LEFT JOIN engines e ON e.id = f.engine_id
      WHERE f.product_id = ?
      ORDER BY mk.name ASC, vm.name ASC, f.year_from DESC
      ''',
      variables: <Variable<Object>>[Variable<String>(productId)],
      readsFrom: <ResultSetImplementation<dynamic, dynamic>>{
        fitments,
        vehicleModels,
        vehicleMakes,
        engines,
      },
    ).get();

    return rows
        .map(
          (QueryRow r) => Fitment(
            makeName: r.read<String>('make_name'),
            modelName: r.read<String>('model_name'),
            engineName: r.readNullable<String>('engine_name'),
            yearFrom: r.read<int>('year_from'),
            yearTo: r.read<int>('year_to'),
          ),
        )
        .toList();
  }

  Future<List<Product>> relatedTo(Product product, {int limit = 8}) async {
    final List<QueryRow> rows = await customSelect(
      '''
      $_productSelect
      WHERE p.category_id = ? AND p.id != ?
      ORDER BY p.is_featured DESC, p.rating DESC
      LIMIT ?
      ''',
      variables: <Variable<Object>>[
        Variable<String>(product.categoryId),
        Variable<String>(product.id),
        Variable<int>(limit),
      ],
      readsFrom: _productReads,
    ).get();
    return rows.map(_productFromRow).toList();
  }

  // ---------------------------------------------------------- carga masiva

  /// Reemplaza todo el catalogo en una sola transaccion.
  ///
  /// O entra todo o no entra nada: si una fila falla, la base queda como
  /// estaba. Se borra en orden inverso a las dependencias para no violar las
  /// llaves foraneas.
  Future<void> replaceCatalog({
    required List<CategoriesCompanion> categoryRows,
    required List<PartBrandsCompanion> partBrandRows,
    required List<VehicleMakesCompanion> makeRows,
    required List<VehicleModelsCompanion> modelRows,
    required List<EnginesCompanion> engineRows,
    required List<ProductsCompanion> productRows,
    required List<ProductImagesCompanion> imageRows,
    required List<FitmentsCompanion> fitmentRows,
  }) async {
    _quoteLog(
      '[IMPORT_DEBUG] AppDatabase.replaceCatalog() INICIO '
      'productsToInsert=${productRows.length}',
    );
    await transaction(() async {
      _quoteLog('[IMPORT_DEBUG] transaction ABIERTA → delete tablas catalogo');
      await delete(fitments).go();
      await delete(productImages).go();
      await delete(products).go();
      await delete(engines).go();
      await delete(vehicleModels).go();
      await delete(vehicleMakes).go();
      await delete(partBrands).go();
      await delete(categories).go();
      _quoteLog(
        '[IMPORT_DEBUG] deletes OK → insertAll batch '
        'products=${productRows.length}',
      );

      await batch((Batch b) {
        b.insertAll(categories, categoryRows);
        b.insertAll(partBrands, partBrandRows);
        b.insertAll(vehicleMakes, makeRows);
        b.insertAll(vehicleModels, modelRows);
        b.insertAll(engines, engineRows);
        b.insertAll(products, productRows);
        b.insertAll(productImages, imageRows);
        b.insertAll(fitments, fitmentRows);
      });
      _quoteLog(
        '[IMPORT_DEBUG] batch insertAll OK (commit al salir del '
        'transaction sin excepcion)',
      );
    });
    _quoteLog(
      '[IMPORT_DEBUG] AppDatabase.replaceCatalog() FIN — transaction '
      'completada (commit implicito de Drift)',
    );
  }

  Future<void> clearCatalog() => replaceCatalog(
    categoryRows: const <CategoriesCompanion>[],
    partBrandRows: const <PartBrandsCompanion>[],
    makeRows: const <VehicleMakesCompanion>[],
    modelRows: const <VehicleModelsCompanion>[],
    engineRows: const <EnginesCompanion>[],
    productRows: const <ProductsCompanion>[],
    imageRows: const <ProductImagesCompanion>[],
    fitmentRows: const <FitmentsCompanion>[],
  );

  // ----------------------------------------------------------- cotizaciones

  /// Diagnostico temporal: schema y existencia de tablas.
  Future<void> debugQuoteSchema() async {
    final QueryRow version = await customSelect(
      'PRAGMA user_version',
    ).getSingle();
    _quoteLog(
      '[QUOTE_DEBUG] AppDatabase PRAGMA user_version='
      '${version.data.values.first} schemaVersion=$schemaVersion',
    );

    final List<QueryRow> tables = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    ).get();
    final List<String> names = tables
        .map((QueryRow r) => r.read<String>('name'))
        .toList();
    _quoteLog('[QUOTE_DEBUG] tablas SQLite: $names');
    _quoteLog(
      '[QUOTE_DEBUG] existe quotes=${names.contains('quotes')} '
      'quote_items=${names.contains('quote_items')}',
    );
  }

  Future<void> insertQuote({
    required QuotesCompanion quote,
    required List<QuoteItemsCompanion> items,
  }) async {
    _quoteLog('[QUOTE_DEBUG] AppDatabase.insertQuote INICIO '
        'items=${items.length}');
    await transaction(() async {
      try {
        _quoteLog('[QUOTE_DEBUG] AppDatabase INSERT quotes...');
        await into(quotes).insert(quote);
        _quoteLog('[QUOTE_DEBUG] AppDatabase INSERT quotes OK');
      } catch (e, st) {
        _quoteLog('[QUOTE_DEBUG] AppDatabase INSERT quotes FALLO: $e');
        _quoteLog('[QUOTE_DEBUG] STACK:\n$st');
        rethrow;
      }
      try {
        _quoteLog('[QUOTE_DEBUG] AppDatabase INSERT quote_items '
            'count=${items.length}...');
        await batch((Batch b) {
          b.insertAll(quoteItems, items);
        });
        _quoteLog('[QUOTE_DEBUG] AppDatabase INSERT quote_items OK');
      } catch (e, st) {
        _quoteLog('[QUOTE_DEBUG] AppDatabase INSERT quote_items FALLO: $e');
        _quoteLog('[QUOTE_DEBUG] STACK:\n$st');
        rethrow;
      }
    });
    _quoteLog('[QUOTE_DEBUG] AppDatabase.insertQuote FIN OK');
  }

  Future<List<QuoteRow>> listQuotes({String? userId}) async {
    final query = select(quotes)
      ..orderBy(<OrderClauseGenerator<Quotes>>[
        (Quotes t) => OrderingTerm.desc(t.createdAt),
      ]);
    if (userId != null && userId.isNotEmpty) {
      query.where((Quotes t) => t.userId.equals(userId));
    }
    return query.get();
  }

  Future<QuoteRow?> quoteById(String id) {
    return (select(quotes)..where((Quotes t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<QuoteItemRow>> quoteItemsFor(String quoteId) {
    return (select(quoteItems)
          ..where((QuoteItems t) => t.quoteId.equals(quoteId))
          ..orderBy(<OrderClauseGenerator<QuoteItems>>[
            (QuoteItems t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
  }

  // ------------------------------------------------------------- internos

  Set<ResultSetImplementation<dynamic, dynamic>> get _productReads =>
      <ResultSetImplementation<dynamic, dynamic>>{
        products,
        categories,
        partBrands,
        productImages,
        fitments,
        vehicleModels,
      };

  static const String _productSelect = '''
    SELECT p.id, p.sku, p.oem, p.name, p.description, p.price,
           p.previous_price, p.stock, p.warranty_months, p.rating,
           p.review_count, p.is_featured, p.specs_json, p.category_id,
           c2.name AS category_name, c2.description AS category_description,
           c2.icon_key AS category_icon, c2.color_hex AS category_color,
           c2.sort_order AS category_sort,
           b.id AS brand_id, b.name AS brand_name,
           (SELECT i.url FROM product_images i
             WHERE i.product_id = p.id
             ORDER BY i.is_primary DESC, i.sort_order ASC
             LIMIT 1) AS image_url
    FROM products p
    JOIN categories c2 ON c2.id = p.category_id
    JOIN part_brands b ON b.id = p.part_brand_id
  ''';

  _WhereClause _buildWhere(CatalogFilter filter) {
    final List<String> conditions = <String>[];
    final List<Variable<Object>> variables = <Variable<Object>>[];

    final String query = filter.query.trim();
    if (query.isNotEmpty) {
      conditions.add(
        '(p.name LIKE ? OR p.sku LIKE ? OR p.oem LIKE ? '
        'OR b.name LIKE ? OR p.description LIKE ?)',
      );
      final String like = '%$query%';
      for (int i = 0; i < 5; i++) {
        variables.add(Variable<String>(like));
      }
    }

    if (filter.categoryId != null) {
      conditions.add('p.category_id = ?');
      variables.add(Variable<String>(filter.categoryId!));
    }

    if (filter.partBrandId != null) {
      conditions.add('p.part_brand_id = ?');
      variables.add(Variable<String>(filter.partBrandId!));
    }

    if (filter.onlyAvailable) {
      conditions.add('p.stock > 0');
    }

    // El filtro por vehiculo se resuelve con EXISTS sobre la tabla de
    // compatibilidad, para no duplicar productos que sirven en varios modelos.
    if (filter.makeId != null) {
      final StringBuffer sub = StringBuffer(
        'EXISTS (SELECT 1 FROM fitments f '
        'JOIN vehicle_models vm ON vm.id = f.model_id '
        'WHERE f.product_id = p.id AND vm.make_id = ?',
      );
      variables.add(Variable<String>(filter.makeId!));

      if (filter.modelId != null) {
        sub.write(' AND f.model_id = ?');
        variables.add(Variable<String>(filter.modelId!));
      }
      if (filter.engineId != null) {
        // Un `engine_id` vacio significa "sirve para todos los motores".
        sub.write(' AND (f.engine_id IS NULL OR f.engine_id = ?)');
        variables.add(Variable<String>(filter.engineId!));
      }
      if (filter.year != null) {
        sub.write(' AND ? BETWEEN f.year_from AND f.year_to');
        variables.add(Variable<int>(filter.year!));
      }
      sub.write(')');
      conditions.add(sub.toString());
    }

    return _WhereClause(
      conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}',
      variables,
    );
  }

  static String _orderBy(ProductSort sort) {
    switch (sort) {
      case ProductSort.relevance:
        return 'p.is_featured DESC, p.rating DESC, p.name COLLATE NOCASE ASC';
      case ProductSort.priceAsc:
        return 'p.price ASC';
      case ProductSort.priceDesc:
        return 'p.price DESC';
      case ProductSort.rating:
        return 'p.rating DESC, p.review_count DESC';
      case ProductSort.name:
        return 'p.name COLLATE NOCASE ASC';
    }
  }

  static PartCategory _categoryFromRow(QueryRow row) =>
      PartCategory.fromStorage(
        id: row.read<String>('id'),
        name: row.read<String>('name'),
        description: row.read<String>('description'),
        iconKey: row.read<String>('icon_key'),
        colorHex: row.read<String>('color_hex'),
        sortOrder: row.read<int>('sort_order'),
        productCount: row.read<int>('product_count'),
      );

  static Product _productFromRow(QueryRow row) {
    final String? image = row.readNullable<String>('image_url');

    return Product(
      id: row.read<String>('id'),
      name: row.read<String>('name'),
      sku: row.read<String>('sku'),
      oem: row.read<String>('oem'),
      description: row.read<String>('description'),
      price: row.read<double>('price'),
      previousPrice: row.readNullable<double>('previous_price'),
      stock: row.read<int>('stock'),
      warrantyMonths: row.read<int>('warranty_months'),
      rating: row.read<double>('rating'),
      reviewCount: row.read<int>('review_count'),
      isFeatured: row.read<bool>('is_featured'),
      brandId: row.read<String>('brand_id'),
      brand: row.read<String>('brand_name'),
      images: image == null ? const <String>[] : <String>[image],
      specs: _decodeSpecs(row.read<String>('specs_json')),
      category: PartCategory.fromStorage(
        id: row.read<String>('category_id'),
        name: row.read<String>('category_name'),
        description: row.read<String>('category_description'),
        iconKey: row.read<String>('category_icon'),
        colorHex: row.read<String>('category_color'),
        sortOrder: row.read<int>('category_sort'),
      ),
    );
  }

  static Map<String, String> _decodeSpecs(String raw) {
    if (raw.trim().isEmpty) return const <String, String>{};
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return const <String, String>{};
      return decoded.map(
        (Object? k, Object? v) => MapEntry<String, String>('$k', '$v'),
      );
    } on FormatException {
      return const <String, String>{};
    }
  }
}

class _WhereClause {
  const _WhereClause(this.sql, this.variables);

  final String sql;
  final List<Variable<Object>> variables;
}
