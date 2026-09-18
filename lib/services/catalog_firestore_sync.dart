import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../data/db/app_database.dart';
import '../data/models/brand.dart';
import '../data/models/category.dart';
import '../data/models/product.dart';
import 'firestore_service.dart';

/// Resultado de sincronizar el catalogo local (Drift) hacia Cloud Firestore.
class FirestoreSyncReport {
  const FirestoreSyncReport({
    required this.categoriesUpserted,
    required this.brandsUpserted,
    required this.productsCreated,
    required this.productsUpdated,
    required this.errors,
    this.vehicleMakesUpserted = 0,
    this.vehicleModelsUpserted = 0,
    this.enginesUpserted = 0,
  });

  final int categoriesUpserted;
  final int brandsUpserted;
  final int productsCreated;
  final int productsUpdated;
  final int vehicleMakesUpserted;
  final int vehicleModelsUpserted;
  final int enginesUpserted;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;

  String get summary {
    final String base =
        'Firestore: $productsCreated productos creados, '
        '$productsUpdated actualizados'
        ' ($categoriesUpserted categorias, $brandsUpserted marcas, '
        '$vehicleMakesUpserted makes, $vehicleModelsUpserted models, '
        '$enginesUpserted engines).';
    if (errors.isEmpty) return base;
    return '$base ${errors.length} errores.';
  }
}

/// Copia el catalogo Drift hacia Firestore.
///
/// Fuente: tablas ya cargadas en SQLite (p. ej. desde el Excel consolidado).
/// Usa upsert (merge). No borra documentos remotos. Los fallos por registro
/// se acumulan en [FirestoreSyncReport.errors] y no abortan el lote.
class CatalogFirestoreSync {
  CatalogFirestoreSync({
    required this.db,
    this.firestore = const FirestoreService(),
  });

  final AppDatabase db;
  final FirestoreService firestore;

  Future<FirestoreSyncReport> run() async {
    int categoriesUpserted = 0;
    int brandsUpserted = 0;
    int productsCreated = 0;
    int productsUpdated = 0;
    int vehicleMakesUpserted = 0;
    int vehicleModelsUpserted = 0;
    int enginesUpserted = 0;
    final List<String> errors = <String>[];

    void addError(String error) {
      errors.add(error);
      debugPrint(error);
    }

    List<CategoryRow> categoryRows = const <CategoryRow>[];
    List<PartBrandRow> brandRows = const <PartBrandRow>[];
    List<ProductRow> productRows = const <ProductRow>[];
    List<ProductImageRow> imageRows = const <ProductImageRow>[];
    List<FitmentRow> fitmentRows = const <FitmentRow>[];
    List<VehicleMakeRow> makeRows = const <VehicleMakeRow>[];
    List<VehicleModelRow> modelRows = const <VehicleModelRow>[];
    List<EngineRow> engineRows = const <EngineRow>[];

    try {
      categoryRows = await db.select(db.categories).get();
    } catch (e) {
      addError('No se pudieron leer categorias de Drift: $e');
    }

    try {
      brandRows = await db.select(db.partBrands).get();
    } catch (e) {
      addError('No se pudieron leer marcas de Drift: $e');
    }

    try {
      productRows = await db.select(db.products).get();
    } catch (e) {
      addError('No se pudieron leer productos de Drift: $e');
    }

    try {
      imageRows = await db.select(db.productImages).get();
    } catch (e) {
      addError('No se pudieron leer product_images de Drift: $e');
    }

    try {
      fitmentRows = await db.select(db.fitments).get();
    } catch (e) {
      addError('No se pudieron leer fitments de Drift: $e');
    }

    try {
      makeRows = await db.select(db.vehicleMakes).get();
    } catch (e) {
      addError('No se pudieron leer vehicle_makes de Drift: $e');
    }

    try {
      modelRows = await db.select(db.vehicleModels).get();
    } catch (e) {
      addError('No se pudieron leer vehicle_models de Drift: $e');
    }

    try {
      engineRows = await db.select(db.engines).get();
    } catch (e) {
      addError('No se pudieron leer engines de Drift: $e');
    }

    // Conteos Drift antes de escribir en Firestore.
    debugPrint('Drift product_images: ${imageRows.length}');
    debugPrint('Drift fitments: ${fitmentRows.length}');
    debugPrint('Drift vehicle_makes: ${makeRows.length}');
    debugPrint('Drift vehicle_models: ${modelRows.length}');
    debugPrint('Drift engines: ${engineRows.length}');

    for (final CategoryRow row in categoryRows) {
      try {
        await firestore.upsertCategory(
          Category(
            id: row.id,
            name: row.name,
            description: row.description,
            sortOrder: row.sortOrder,
          ),
        );
        categoriesUpserted++;
      } catch (e) {
        addError('Categoria ${row.id}: $e');
      }
    }

    for (final PartBrandRow row in brandRows) {
      try {
        await firestore.upsertBrand(
          Brand(
            id: row.id,
            name: row.name,
            logoUrl: row.logoUrl,
          ),
        );
        brandsUpserted++;
      } catch (e) {
        addError('Marca ${row.id}: $e');
      }
    }

    if (makeRows.isNotEmpty) {
      for (final VehicleMakeRow row in makeRows) {
        try {
          await firestore.upsertVehicleMake(
            <String, dynamic>{
              'name': row.name,
              'country': row.country,
              'createdAt': FieldValue.serverTimestamp(),
            },
            id: row.id,
          );
          vehicleMakesUpserted++;
        } catch (e) {
          addError('VehicleMake ${row.id}: $e');
        }
      }
    }

    if (modelRows.isNotEmpty) {
      for (final VehicleModelRow row in modelRows) {
        try {
          await firestore.upsertVehicleModel(
            <String, dynamic>{
              'makeId': row.makeId,
              'name': row.name,
              'bodyType': row.bodyType,
              'yearFrom': row.yearFrom,
              'yearTo': row.yearTo,
              'createdAt': FieldValue.serverTimestamp(),
            },
            id: row.id,
          );
          vehicleModelsUpserted++;
        } catch (e) {
          addError('VehicleModel ${row.id}: $e');
        }
      }
    }

    if (engineRows.isNotEmpty) {
      for (final EngineRow row in engineRows) {
        try {
          await firestore.upsertEngine(
            <String, dynamic>{
              'modelId': row.modelId,
              'code': row.code,
              'name': row.name,
              'displacement': row.displacement,
              'fuel': row.fuel,
              'horsepower': row.horsepower,
              'yearFrom': row.yearFrom,
              'yearTo': row.yearTo,
              'createdAt': FieldValue.serverTimestamp(),
            },
            id: row.id,
          );
          enginesUpserted++;
        } catch (e) {
          addError('Engine ${row.id}: $e');
        }
      }
    }

    final Map<String, List<Map<String, dynamic>>> imagesByProduct =
        <String, List<Map<String, dynamic>>>{};
    for (final ProductImageRow row in imageRows) {
      imagesByProduct
          .putIfAbsent(row.productId, () => <Map<String, dynamic>>[])
          .add(<String, dynamic>{
        'id': row.id,
        'url': row.url,
        'sortOrder': row.sortOrder,
        'isPrimary': row.isPrimary,
      });
    }
    for (final List<Map<String, dynamic>> list in imagesByProduct.values) {
      list.sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            ((a['sortOrder'] as int?) ?? 0)
                .compareTo((b['sortOrder'] as int?) ?? 0),
      );
    }

    final Map<String, List<Map<String, dynamic>>> fitmentsByProduct =
        <String, List<Map<String, dynamic>>>{};
    for (final FitmentRow row in fitmentRows) {
      fitmentsByProduct
          .putIfAbsent(row.productId, () => <Map<String, dynamic>>[])
          .add(<String, dynamic>{
        'id': row.id,
        'modelId': row.modelId,
        'engineId': row.engineId,
        'yearFrom': row.yearFrom,
        'yearTo': row.yearTo,
      });
    }

    for (final ProductRow row in productRows) {
      try {
        final CatalogProduct? existing =
            await firestore.fetchProductById(row.id);
        final bool existed = existing != null;

        final List<Map<String, dynamic>> images =
            imagesByProduct[row.id] ?? const <Map<String, dynamic>>[];
        final List<Map<String, dynamic>> fitments =
            fitmentsByProduct[row.id] ?? const <Map<String, dynamic>>[];

        String? photoUrl;
        for (final Map<String, dynamic> image in images) {
          if (image['isPrimary'] == true) {
            photoUrl = image['url'] as String?;
            break;
          }
        }
        photoUrl ??= images.isEmpty ? null : images.first['url'] as String?;

        await firestore.upsertProduct(
          CatalogProduct(
            id: row.id,
            name: row.name,
            sku: row.sku,
            oem: row.oem,
            brandId: row.partBrandId,
            categoryId: row.categoryId,
            price: row.price,
            stock: row.stock,
            description: row.description,
            photoUrl: photoUrl,
            previousPrice: row.previousPrice,
            isFeatured: row.isFeatured,
            warrantyMonths: row.warrantyMonths,
          ),
          images: images,
          fitments: fitments,
        );

        if (existed) {
          productsUpdated++;
        } else {
          productsCreated++;
        }
      } catch (e) {
        addError('Producto ${row.id}: $e');
      }
    }

    debugPrint('Categorias: $categoriesUpserted');
    debugPrint('Marcas: $brandsUpserted');
    debugPrint('Productos: $productsUpdated');
    debugPrint('VehicleMakes: $vehicleMakesUpserted');
    debugPrint('VehicleModels: $vehicleModelsUpserted');
    debugPrint('Engines: $enginesUpserted');
    debugPrint('Errores: ${errors.length}');

    return FirestoreSyncReport(
      categoriesUpserted: categoriesUpserted,
      brandsUpserted: brandsUpserted,
      productsCreated: productsCreated,
      productsUpdated: productsUpdated,
      vehicleMakesUpserted: vehicleMakesUpserted,
      vehicleModelsUpserted: vehicleModelsUpserted,
      enginesUpserted: enginesUpserted,
      errors: errors,
    );
  }
}
