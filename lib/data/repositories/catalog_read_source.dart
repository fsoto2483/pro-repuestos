import '../db/app_database.dart';
import '../models/catalog_filter.dart';
import '../models/part_category.dart';
import '../models/product.dart';
import '../models/vehicle.dart';

/// Contrato de lectura del catalogo que consume [CatalogController].
abstract class CatalogReadSource {
  Future<void> warmUp();

  Future<List<PartCategory>> categories();

  Future<List<PartBrand>> brands();

  Future<List<VehicleMake>> makes();

  Future<List<VehicleModel>> models(String makeId);

  Future<List<Engine>> engines(String modelId);

  Future<List<int>> years({required String modelId, String? engineId});

  Future<List<Product>> search(CatalogFilter filter, {int limit = 240});

  Future<int> count(CatalogFilter filter);

  Future<List<Product>> featured({int limit = 10});

  Future<Product?> productById(String id);

  Future<List<Product>> relatedTo(Product product, {int limit = 8});

  Future<CatalogStats> stats();
}
