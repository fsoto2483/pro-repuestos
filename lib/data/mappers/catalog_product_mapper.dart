import '../models/brand.dart';
import '../models/category.dart';
import '../models/part_category.dart';
import '../models/product.dart';
import '../models/vehicle.dart';

/// Convierte documentos Firestore (`CatalogProduct`, `Category`, `Brand`)
/// al modelo denormalizado que consume la UI (`Product`).
class CatalogProductMapper {
  const CatalogProductMapper();

  PartCategory toPartCategory(Category category, {int productCount = 0}) {
    return PartCategory.fromStorage(
      id: category.id,
      name: category.name,
      description: category.description,
      iconKey: category.id,
      colorHex: '#FF5A1F',
      sortOrder: category.sortOrder,
      productCount: productCount,
    );
  }

  PartBrand toPartBrand(Brand brand, {int productCount = 0}) {
    return PartBrand(
      id: brand.id,
      name: brand.name,
      productCount: productCount,
    );
  }

  /// [includeFitments] true en ficha; false en grilla para no cargar de mas.
  Product toProduct(
    CatalogProduct remote, {
    required Map<String, PartCategory> categoriesById,
    required Map<String, PartBrand> brandsById,
    Map<String, VehicleMake> makesById = const <String, VehicleMake>{},
    Map<String, VehicleModel> modelsById = const <String, VehicleModel>{},
    Map<String, Engine> enginesById = const <String, Engine>{},
    bool includeFitments = false,
  }) {
    final PartCategory category = categoriesById[remote.categoryId] ??
        PartCategory.fromStorage(
          id: remote.categoryId,
          name: remote.categoryId.isEmpty ? 'Sin categoria' : remote.categoryId,
          description: '',
          iconKey: 'default',
          colorHex: '#FF5A1F',
        );

    final PartBrand? brand = brandsById[remote.brandId];
    final String brandName = brand?.name ?? remote.brandId;

    final List<String> images = _imageUrls(remote);
    final List<Fitment> fitments = includeFitments
        ? _fitments(
            remote,
            makesById: makesById,
            modelsById: modelsById,
            enginesById: enginesById,
          )
        : const <Fitment>[];

    return Product(
      id: remote.id,
      name: remote.name,
      category: category,
      sku: remote.sku,
      oem: remote.oem,
      brandId: remote.brandId,
      brand: brandName,
      price: remote.price,
      stock: remote.stock,
      description: remote.description,
      previousPrice: remote.previousPrice,
      rating: remote.rating,
      reviewCount: remote.reviewCount,
      images: images,
      isFeatured: remote.isFeatured,
      warrantyMonths: remote.warrantyMonths,
      fitments: fitments,
    );
  }

  List<String> _imageUrls(CatalogProduct remote) {
    final List<Map<String, dynamic>> entries =
        List<Map<String, dynamic>>.from(remote.imageEntries);
    entries.sort(
      (Map<String, dynamic> a, Map<String, dynamic> b) {
        final bool aPrimary = a['isPrimary'] == true;
        final bool bPrimary = b['isPrimary'] == true;
        if (aPrimary != bPrimary) return aPrimary ? -1 : 1;
        return ((a['sortOrder'] as num?)?.toInt() ?? 0)
            .compareTo((b['sortOrder'] as num?)?.toInt() ?? 0);
      },
    );

    final List<String> urls = entries
        .map((Map<String, dynamic> e) => (e['url'] as String?)?.trim() ?? '')
        .where((String u) => u.isNotEmpty)
        .toList();

    final String? photo = remote.photoUrl?.trim();
    if (photo != null && photo.isNotEmpty && !urls.contains(photo)) {
      urls.insert(0, photo);
    }
    return urls;
  }

  List<Fitment> _fitments(
    CatalogProduct remote, {
    required Map<String, VehicleMake> makesById,
    required Map<String, VehicleModel> modelsById,
    required Map<String, Engine> enginesById,
  }) {
    final List<Fitment> out = <Fitment>[];
    for (final Map<String, dynamic> entry in remote.fitmentEntries) {
      final String modelId = (entry['modelId'] as String?)?.trim() ?? '';
      final VehicleModel? model = modelsById[modelId];
      final VehicleMake? make =
          model == null ? null : makesById[model.makeId];
      final String? engineId = (entry['engineId'] as String?)?.trim();
      final Engine? engine =
          (engineId == null || engineId.isEmpty) ? null : enginesById[engineId];

      out.add(
        Fitment(
          makeName: make?.name ?? '',
          modelName: model?.name ?? modelId,
          engineName: engine?.name,
          yearFrom: (entry['yearFrom'] as num?)?.toInt() ?? 0,
          yearTo: (entry['yearTo'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    return out;
  }
}
