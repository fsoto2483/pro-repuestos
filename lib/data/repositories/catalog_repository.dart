import '../../services/firestore_service.dart';
import '../db/app_database.dart';
import '../import/catalog_importer.dart';
import '../import/catalog_seeder.dart';
import '../import/catalog_sources.dart';
import '../import/catalog_tables.dart';
import '../import/import_report.dart';
import '../mappers/catalog_product_mapper.dart';
import '../models/brand.dart';
import '../models/catalog_filter.dart';
import '../models/category.dart';
import '../models/part_category.dart';
import '../models/product.dart';
import '../models/vehicle.dart';
import 'catalog_read_source.dart';

/// Unica puerta de entrada al catalogo.
///
/// Todo lo que se ve en pantalla sale de la base de datos local. Las pantallas
/// no saben que existe SQLite ni como se llaman las tablas.
class CatalogRepository {
  CatalogRepository({AppDatabase? database})
    : db = database ?? AppDatabase();

  final AppDatabase db;

  /// Llena la base con los archivos que trae la app la primera vez que se
  /// abre. Despues no vuelve a tocar nada.
  Future<ImportReport?> ensureSeeded() => CatalogSeeder(db).seedIfEmpty();

  Future<CatalogStats> stats() => db.stats();

  // ------------------------------------------------------------- catalogos

  Future<List<PartCategory>> fetchCategories() => db.categoriesWithCounts();

  Future<List<VehicleMake>> fetchMakes() => db.vehicleMakesWithCounts();

  Future<List<VehicleModel>> fetchModels(String makeId) =>
      db.modelsForMake(makeId);

  Future<List<Engine>> fetchEngines(String modelId) =>
      db.enginesForModel(modelId);

  Future<List<int>> fetchYears({required String modelId, String? engineId}) =>
      db.yearsFor(modelId: modelId, engineId: engineId);

  Future<List<PartBrand>> fetchPartBrands() => db.partBrandsWithCounts();

  // -------------------------------------------------------------- productos

  Future<List<Product>> search(CatalogFilter filter, {int limit = 240}) =>
      db.searchProducts(filter, limit: limit);

  Future<int> count(CatalogFilter filter) => db.countProducts(filter);

  Future<List<Product>> fetchFeatured({int limit = 10}) =>
      db.featuredProducts(limit: limit);

  /// Ficha completa: agrega las imagenes y la compatibilidad, que no se
  /// consultan en la grilla para no pedir de mas.
  Future<Product?> fetchProductById(String id) => db.productById(id);

  Future<List<Product>> relatedTo(Product product, {int limit = 8}) =>
      db.relatedTo(product, limit: limit);

  // ----------------------------------------------------------- carga masiva

  /// Reemplaza el catalogo con los archivos que elija el usuario.
  Future<ImportReport> importFiles(List<SourceFile> files) async {
    // ignore: avoid_print
    print('[IMPORT_DEBUG] CatalogRepository.importFiles '
        'files=${files.map((SourceFile f) => f.name).toList()}');
    if (files.isEmpty) {
      return ImportReport.failure('No seleccionaste ningun archivo.');
    }

    final CatalogStats before = await db.stats();
    // ignore: avoid_print
    print('[IMPORT_DEBUG] CatalogRepository stats.products ANTES='
        '${before.products}');

    final SheetCollection collection = const CatalogSourceReader().read(files);
    // ignore: avoid_print
    print('[IMPORT_DEBUG] SheetCollection sheets='
        '${collection.sheets.keys.map((e) => e.name).toList()} '
        'ignored=${collection.ignored} isEmpty=${collection.isEmpty}');
    for (final MapEntry<CatalogTable, ParsedSheet> e
        in collection.sheets.entries) {
      // ignore: avoid_print
      print('[IMPORT_DEBUG]   sheet ${e.key.name} source=${e.value.sourceName} '
          'rows=${e.value.rows.length}');
    }

    if (collection.isEmpty) {
      return ImportReport.failure(
        'Ninguno de los archivos coincide con una tabla del catalogo. '
        'Renombralos como categorias, productos, modelos, etc.',
      );
    }

    final ImportReport report =
        await CatalogImporter(db).import(collection.sheets);
    final CatalogStats after = await db.stats();
    // ignore: avoid_print
    print('[IMPORT_DEBUG] CatalogRepository import applied=${report.applied} '
        'fatal=${report.fatalError} stats.products DESPUES=${after.products}');
    return report;
  }

  /// Vuelve a dejar el catalogo que trae la app de fabrica.
  Future<ImportReport> restoreBundled() => CatalogSeeder(db).seed();

  Future<void> dispose() => db.close();
}

/// Catalogo remoto: fuente de verdad en Cloud Firestore.
///
/// Expone el mismo contrato de lectura que consume [CatalogController]
/// (`Product`, `PartCategory`, filtros vehiculo, etc.).
class FirestoreCatalogRepository implements CatalogReadSource {
  FirestoreCatalogRepository({
    this.firestore = const FirestoreService(),
    this.mapper = const CatalogProductMapper(),
  });

  final FirestoreService firestore;
  final CatalogProductMapper mapper;

  Map<String, PartCategory> _categoriesById = <String, PartCategory>{};
  Map<String, PartBrand> _brandsById = <String, PartBrand>{};
  Map<String, VehicleMake> _makesById = <String, VehicleMake>{};
  Map<String, VehicleModel> _modelsById = <String, VehicleModel>{};
  Map<String, Engine> _enginesById = <String, Engine>{};

  List<PartCategory> _categories = <PartCategory>[];
  List<PartBrand> _brands = <PartBrand>[];
  List<VehicleMake> _makes = <VehicleMake>[];

  /// Precarga look-ups usados por el mapper y la UI.
  @override
  Future<void> warmUp() async {
    final List<Category> remoteCats = await firestore.fetchCategories();
    final List<Brand> remoteBrands = await firestore.fetchBrands();
    final List<CatalogProduct> allProducts = await firestore.fetchProducts();

    // ignore: avoid_print
    print('[FIRESTORE_CATEGORIES] ${remoteCats.length}');
    // ignore: avoid_print
    print('[FIRESTORE_BRANDS] ${remoteBrands.length}');
    // ignore: avoid_print
    print('[FIRESTORE_PRODUCTS] ${allProducts.length}');

    final Map<String, int> productsPerCategory = <String, int>{};
    final Map<String, int> productsPerBrand = <String, int>{};
    for (final CatalogProduct p in allProducts) {
      productsPerCategory[p.categoryId] =
          (productsPerCategory[p.categoryId] ?? 0) + 1;
      productsPerBrand[p.brandId] = (productsPerBrand[p.brandId] ?? 0) + 1;
    }

    _categories = remoteCats
        .map(
          (Category c) => mapper.toPartCategory(
            c,
            productCount: productsPerCategory[c.id] ?? 0,
          ),
        )
        .toList();
    _categoriesById = <String, PartCategory>{
      for (final PartCategory c in _categories) c.id: c,
    };

    _brands = remoteBrands
        .map(
          (Brand b) => mapper.toPartBrand(
            b,
            productCount: productsPerBrand[b.id] ?? 0,
          ),
        )
        .toList();
    _brandsById = <String, PartBrand>{
      for (final PartBrand b in _brands) b.id: b,
    };

    final List<Map<String, dynamic>> makeDocs =
        await firestore.fetchVehicleMakeDocs();
    final List<Map<String, dynamic>> modelDocs =
        await firestore.fetchVehicleModelDocs();
    final List<Map<String, dynamic>> engineDocs =
        await firestore.fetchEngineDocs();

    final Map<String, int> modelsPerMake = <String, int>{};
    for (final Map<String, dynamic> m in modelDocs) {
      final String makeId = '${m['makeId'] ?? ''}';
      modelsPerMake[makeId] = (modelsPerMake[makeId] ?? 0) + 1;
    }

    _makes = makeDocs
        .map(
          (Map<String, dynamic> m) => VehicleMake(
            id: '${m['id']}',
            name: '${m['name'] ?? ''}',
            country: '${m['country'] ?? ''}',
            modelCount: modelsPerMake['${m['id']}'] ?? 0,
          ),
        )
        .toList();
    _makesById = <String, VehicleMake>{
      for (final VehicleMake m in _makes) m.id: m,
    };

    _modelsById = <String, VehicleModel>{
      for (final Map<String, dynamic> m in modelDocs)
        '${m['id']}': VehicleModel(
          id: '${m['id']}',
          makeId: '${m['makeId'] ?? ''}',
          name: '${m['name'] ?? ''}',
          bodyType: '${m['bodyType'] ?? ''}',
          yearFrom: (m['yearFrom'] as num?)?.toInt() ?? 0,
          yearTo: (m['yearTo'] as num?)?.toInt() ?? 0,
        ),
    };

    _enginesById = <String, Engine>{
      for (final Map<String, dynamic> e in engineDocs)
        '${e['id']}': Engine(
          id: '${e['id']}',
          modelId: '${e['modelId'] ?? ''}',
          code: '${e['code'] ?? ''}',
          name: '${e['name'] ?? ''}',
          displacement: (e['displacement'] as num?)?.toDouble() ?? 0,
          fuel: '${e['fuel'] ?? 'Gasolina'}',
          horsepower: (e['horsepower'] as num?)?.toInt() ?? 0,
          yearFrom: (e['yearFrom'] as num?)?.toInt() ?? 0,
          yearTo: (e['yearTo'] as num?)?.toInt() ?? 0,
        ),
    };
  }

  @override
  Future<List<PartCategory>> categories() async {
    if (_categories.isEmpty) await warmUp();
    return _categories;
  }

  @override
  Future<List<PartBrand>> brands() async {
    if (_brands.isEmpty) await warmUp();
    return _brands;
  }

  @override
  Future<List<VehicleMake>> makes() async {
    if (_makes.isEmpty) await warmUp();
    return _makes;
  }

  @override
  Future<List<VehicleModel>> models(String makeId) async {
    if (_modelsById.isEmpty) await warmUp();
    return _modelsById.values
        .where((VehicleModel m) => m.makeId == makeId)
        .toList()
      ..sort(
        (VehicleModel a, VehicleModel b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }

  @override
  Future<List<Engine>> engines(String modelId) async {
    if (_enginesById.isEmpty) await warmUp();
    return _enginesById.values
        .where((Engine e) => e.modelId == modelId)
        .toList()
      ..sort(
        (Engine a, Engine b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }

  @override
  Future<List<int>> years({required String modelId, String? engineId}) async {
    if (_modelsById.isEmpty) await warmUp();
    final VehicleModel? model = _modelsById[modelId];
    if (model == null) return const <int>[];
    int from = model.yearFrom;
    int to = model.yearTo;
    if (engineId != null) {
      final Engine? engine = _enginesById[engineId];
      if (engine != null) {
        from = engine.yearFrom;
        to = engine.yearTo;
      }
    }
    if (from <= 0 || to <= 0 || to < from) return const <int>[];
    return <int>[for (int y = to; y >= from; y--) y];
  }

  @override
  Future<List<Product>> search(CatalogFilter filter, {int limit = 240}) async {
    if (_categoriesById.isEmpty) await warmUp();

    List<CatalogProduct> remote = await firestore.fetchProducts(
      brandId: filter.partBrandId,
      categoryId: filter.categoryId,
    );

    Iterable<CatalogProduct> filtered = remote;

    final String q = filter.query.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((CatalogProduct p) {
        final PartBrand? brand = _brandsById[p.brandId];
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.oem.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            (brand?.name.toLowerCase().contains(q) ?? false);
      });
    }

    if (filter.onlyAvailable) {
      filtered = filtered.where((CatalogProduct p) => p.stock > 0);
    }

    if (filter.makeId != null) {
      filtered = filtered.where(
        (CatalogProduct p) => _matchesVehicle(p, filter),
      );
    }

    List<CatalogProduct> list = filtered.toList();
    list = _sortProducts(list, filter.sort);

    if (list.length > limit) {
      list = list.sublist(0, limit);
    }

    return list
        .map(
          (CatalogProduct p) => mapper.toProduct(
            p,
            categoriesById: _categoriesById,
            brandsById: _brandsById,
          ),
        )
        .toList();
  }

  @override
  Future<int> count(CatalogFilter filter) async {
    final List<Product> found = await search(filter, limit: 100000);
    return found.length;
  }

  @override
  Future<List<Product>> featured({int limit = 10}) async {
    if (_categoriesById.isEmpty) await warmUp();
    final List<CatalogProduct> remote = await firestore.fetchProducts();
    final List<CatalogProduct> featured = remote
        .where((CatalogProduct p) => p.isFeatured)
        .toList();
    featured.sort(
      (CatalogProduct a, CatalogProduct b) =>
          b.rating.compareTo(a.rating),
    );
    return featured
        .take(limit)
        .map(
          (CatalogProduct p) => mapper.toProduct(
            p,
            categoriesById: _categoriesById,
            brandsById: _brandsById,
          ),
        )
        .toList();
  }

  @override
  Future<Product?> productById(String id) async {
    if (_categoriesById.isEmpty) await warmUp();
    final CatalogProduct? remote = await firestore.fetchProductById(id);
    if (remote == null) return null;
    return mapper.toProduct(
      remote,
      categoriesById: _categoriesById,
      brandsById: _brandsById,
      makesById: _makesById,
      modelsById: _modelsById,
      enginesById: _enginesById,
      includeFitments: true,
    );
  }

  @override
  Future<List<Product>> relatedTo(Product product, {int limit = 8}) async {
    final List<Product> sameCategory = await search(
      CatalogFilter(categoryId: product.categoryId),
      limit: limit + 1,
    );
    return sameCategory
        .where((Product p) => p.id != product.id)
        .take(limit)
        .toList();
  }

  @override
  Future<CatalogStats> stats() async {
    if (_categories.isEmpty) await warmUp();
    final List<CatalogProduct> products = await firestore.fetchProducts();
    return CatalogStats(
      categories: _categories.length,
      partBrands: _brands.length,
      makes: _makes.length,
      models: _modelsById.length,
      engines: _enginesById.length,
      products: products.length,
      images: products.fold<int>(
        0,
        (int sum, CatalogProduct p) => sum + p.imageEntries.length,
      ),
      fitments: products.fold<int>(
        0,
        (int sum, CatalogProduct p) => sum + p.fitmentEntries.length,
      ),
    );
  }

  bool _matchesVehicle(CatalogProduct product, CatalogFilter filter) {
    for (final Map<String, dynamic> f in product.fitmentEntries) {
      final String modelId = '${f['modelId'] ?? ''}';
      final VehicleModel? model = _modelsById[modelId];
      if (model == null) continue;
      if (filter.makeId != null && model.makeId != filter.makeId) continue;
      if (filter.modelId != null && modelId != filter.modelId) continue;
      final String? engineId = f['engineId'] as String?;
      if (filter.engineId != null &&
          engineId != null &&
          engineId.isNotEmpty &&
          engineId != filter.engineId) {
        continue;
      }
      if (filter.year != null) {
        final int from = (f['yearFrom'] as num?)?.toInt() ?? 0;
        final int to = (f['yearTo'] as num?)?.toInt() ?? 0;
        if (filter.year! < from || filter.year! > to) continue;
      }
      return true;
    }
    return false;
  }

  List<CatalogProduct> _sortProducts(
    List<CatalogProduct> list,
    ProductSort sort,
  ) {
    final List<CatalogProduct> copy = List<CatalogProduct>.from(list);
    switch (sort) {
      case ProductSort.priceAsc:
        copy.sort(
          (CatalogProduct a, CatalogProduct b) => a.price.compareTo(b.price),
        );
      case ProductSort.priceDesc:
        copy.sort(
          (CatalogProduct a, CatalogProduct b) => b.price.compareTo(a.price),
        );
      case ProductSort.rating:
        copy.sort(
          (CatalogProduct a, CatalogProduct b) => b.rating.compareTo(a.rating),
        );
      case ProductSort.name:
        copy.sort(
          (CatalogProduct a, CatalogProduct b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case ProductSort.relevance:
        copy.sort((CatalogProduct a, CatalogProduct b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
    }
    return copy;
  }

  // CRUD crudo (admin / sync)
  Future<List<Brand>> getBrands() => firestore.fetchBrands();

  Future<List<Category>> getCategories() => firestore.fetchCategories();

  Future<List<CatalogProduct>> getProducts({
    String? brandId,
    String? categoryId,
  }) {
    return firestore.fetchProducts(
      brandId: brandId,
      categoryId: categoryId,
    );
  }

  Future<CatalogProduct?> getProductById(String id) =>
      firestore.fetchProductById(id);

  Future<CatalogProduct> createProduct(CatalogProduct product) =>
      firestore.createProduct(product);

  Future<CatalogProduct> updateProduct(CatalogProduct product) =>
      firestore.updateProduct(product);

  Future<void> deleteProduct(String id) => firestore.deleteProduct(id);
}
