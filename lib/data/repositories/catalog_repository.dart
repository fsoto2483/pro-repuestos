import '../db/app_database.dart';
import '../import/catalog_importer.dart';
import '../import/catalog_seeder.dart';
import '../import/catalog_sources.dart';
import '../import/import_report.dart';
import '../models/catalog_filter.dart';
import '../models/part_category.dart';
import '../models/product.dart';
import '../models/vehicle.dart';

/// Puerta de entrada al catalogo local (Drift / SQLite).
///
/// Se usa para carga masiva, restore y quotes. La UI de catalogo lee desde
/// [FirestoreCatalogRepository] via [CatalogReadSource].
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
    if (files.isEmpty) {
      return ImportReport.failure('No seleccionaste ningun archivo.');
    }

    final SheetCollection collection = const CatalogSourceReader().read(files);

    if (collection.isEmpty) {
      return ImportReport.failure(
        'Ninguno de los archivos coincide con una tabla del catalogo. '
        'Renombralos como categorias, productos, modelos, etc.',
      );
    }

    return CatalogImporter(db).import(collection.sheets);
  }

  /// Vuelve a dejar el catalogo que trae la app de fabrica.
  Future<ImportReport> restoreBundled() => CatalogSeeder(db).seed();

  Future<void> dispose() => db.close();
}
