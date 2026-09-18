import '../db/app_database.dart';
import '../models/catalog_filter.dart';
import '../models/part_category.dart';
import '../models/product.dart';
import '../models/vehicle.dart';
import 'catalog_read_source.dart';
import 'catalog_repository.dart';

/// Adaptador Drift para pruebas y herramientas locales.
///
/// La app en produccion usa `FirestoreCatalogRepository`.
class LocalCatalogReadSource implements CatalogReadSource {
  LocalCatalogReadSource(this._repo);

  final CatalogRepository _repo;

  @override
  Future<void> warmUp() async {}

  @override
  Future<List<PartCategory>> categories() => _repo.fetchCategories();

  @override
  Future<List<PartBrand>> brands() => _repo.fetchPartBrands();

  @override
  Future<List<VehicleMake>> makes() => _repo.fetchMakes();

  @override
  Future<List<VehicleModel>> models(String makeId) => _repo.fetchModels(makeId);

  @override
  Future<List<Engine>> engines(String modelId) => _repo.fetchEngines(modelId);

  @override
  Future<List<int>> years({required String modelId, String? engineId}) =>
      _repo.fetchYears(modelId: modelId, engineId: engineId);

  @override
  Future<List<Product>> search(CatalogFilter filter, {int limit = 240}) =>
      _repo.search(filter, limit: limit);

  @override
  Future<int> count(CatalogFilter filter) => _repo.count(filter);

  @override
  Future<List<Product>> featured({int limit = 10}) =>
      _repo.fetchFeatured(limit: limit);

  @override
  Future<Product?> productById(String id) => _repo.fetchProductById(id);

  @override
  Future<List<Product>> relatedTo(Product product, {int limit = 8}) =>
      _repo.relatedTo(product, limit: limit);

  @override
  Future<CatalogStats> stats() => _repo.stats();
}
