import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/brand.dart';
import '../data/models/category.dart';
import '../data/models/product.dart';

/// Acceso de bajo nivel a las colecciones del catalogo en Cloud Firestore.
///
/// Colecciones: `brands`, `categories`, `products`.
class FirestoreService {
  const FirestoreService();

  static const String brandsCollection = 'brands';
  static const String categoriesCollection = 'categories';
  static const String productsCollection = 'products';
  static const String vehicleMakesCollection = 'vehicleMakes';
  static const String vehicleModelsCollection = 'vehicleModels';
  static const String enginesCollection = 'engines';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _brands =>
      _db.collection(brandsCollection);

  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection(categoriesCollection);

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection(productsCollection);

  CollectionReference<Map<String, dynamic>> get _vehicleMakes =>
      _db.collection(vehicleMakesCollection);

  CollectionReference<Map<String, dynamic>> get _vehicleModels =>
      _db.collection(vehicleModelsCollection);

  CollectionReference<Map<String, dynamic>> get _engines =>
      _db.collection(enginesCollection);

  // ---------------------------------------------------------------- brands

  Future<List<Brand>> fetchBrands() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await _brands.orderBy('name').get();
    return snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Brand.fromMap(doc.id, doc.data()),
        )
        .toList();
  }

  Future<Brand?> fetchBrandById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _brands.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return Brand.fromMap(snap.id, snap.data()!);
  }

  // ------------------------------------------------------------- categories

  Future<List<Category>> fetchCategories() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await _categories.orderBy('sortOrder').get();
    return snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Category.fromMap(doc.id, doc.data()),
        )
        .toList();
  }

  Future<Category?> fetchCategoryById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _categories.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return Category.fromMap(snap.id, snap.data()!);
  }

  // --------------------------------------------------------------- products

  Future<List<CatalogProduct>> fetchProducts({
    String? brandId,
    String? categoryId,
  }) async {
    Query<Map<String, dynamic>> query = _products;

    if (brandId != null && brandId.isNotEmpty) {
      query = query.where('brandId', isEqualTo: brandId);
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    // Se ordena en cliente para no exigir indices compuestos en FASE 2.
    final QuerySnapshot<Map<String, dynamic>> snap = await query.get();
    final List<CatalogProduct> products = snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              CatalogProduct.fromMap(doc.id, doc.data()),
        )
        .toList();
    products.sort(
      (CatalogProduct a, CatalogProduct b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    // ignore: avoid_print
    print('[FIRESTORE_DEBUG] fetchProducts count=${products.length}');
    return products;
  }

  Future<CatalogProduct?> fetchProductById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _products.doc(id).get();
    if (!snap.exists || snap.data() == null) {
      // ignore: avoid_print
      print(
        '[FIRESTORE_DEBUG] fetchProductById id=$id name=(null)',
      );
      return null;
    }
    final CatalogProduct product =
        CatalogProduct.fromMap(snap.id, snap.data()!);
    // ignore: avoid_print
    print(
      '[FIRESTORE_DEBUG] fetchProductById id=$id name=${product.name}',
    );
    return product;
  }

  Future<int> countProducts() async {
    final AggregateQuerySnapshot snap = await _products.count().get();
    return snap.count ?? 0;
  }

  // ---------------------------------------------------------- vehicle catalog

  Future<List<Map<String, dynamic>>> fetchVehicleMakeDocs() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await _vehicleMakes.orderBy('name').get();
    return snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              <String, dynamic>{'id': doc.id, ...doc.data()},
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchVehicleModelDocs({
    String? makeId,
  }) async {
    Query<Map<String, dynamic>> query = _vehicleModels;
    if (makeId != null && makeId.isNotEmpty) {
      query = query.where('makeId', isEqualTo: makeId);
    }
    final QuerySnapshot<Map<String, dynamic>> snap = await query.get();
    final List<Map<String, dynamic>> rows = snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              <String, dynamic>{'id': doc.id, ...doc.data()},
        )
        .toList();
    rows.sort(
      (Map<String, dynamic> a, Map<String, dynamic> b) =>
          '${a['name']}'.toLowerCase().compareTo('${b['name']}'.toLowerCase()),
    );
    return rows;
  }

  Future<List<Map<String, dynamic>>> fetchEngineDocs({
    String? modelId,
  }) async {
    Query<Map<String, dynamic>> query = _engines;
    if (modelId != null && modelId.isNotEmpty) {
      query = query.where('modelId', isEqualTo: modelId);
    }
    final QuerySnapshot<Map<String, dynamic>> snap = await query.get();
    final List<Map<String, dynamic>> rows = snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              <String, dynamic>{'id': doc.id, ...doc.data()},
        )
        .toList();
    rows.sort(
      (Map<String, dynamic> a, Map<String, dynamic> b) =>
          '${a['name']}'.toLowerCase().compareTo('${b['name']}'.toLowerCase()),
    );
    return rows;
  }

  /// Crea un producto. Si [product.id] esta vacio, Firestore genera el id.
  Future<CatalogProduct> createProduct(CatalogProduct product) async {
    final DocumentReference<Map<String, dynamic>> ref = product.id.isEmpty
        ? _products.doc()
        : _products.doc(product.id);

    await ref.set(product.toMap());
    final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
    final Map<String, dynamic>? data = snap.data();
    if (data == null) {
      return product.copyWith(id: ref.id);
    }
    return CatalogProduct.fromMap(snap.id, data);
  }

  Future<CatalogProduct> updateProduct(CatalogProduct product) async {
    if (product.id.isEmpty) {
      throw ArgumentError('No se puede editar un producto sin id.');
    }
    final DocumentReference<Map<String, dynamic>> ref =
        _products.doc(product.id);
    await ref.update(product.toMap(isUpdate: true));
    final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
    if (!snap.exists || snap.data() == null) {
      throw StateError('El producto ${product.id} no existe en Firestore.');
    }
    return CatalogProduct.fromMap(snap.id, snap.data()!);
  }

  Future<void> deleteProduct(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('No se puede eliminar un producto sin id.');
    }
    await _products.doc(id).delete();
  }

  /// Elimina todos los documentos de [productsCollection] en batches de 500.
  ///
  /// Usado por el modo "Reemplazar catalogo completo" de la carga masiva.
  /// Devuelve la cantidad de documentos eliminados.
  Future<int> deleteAllProducts() async {
    final QuerySnapshot<Map<String, dynamic>> snap = await _products.get();
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snap.docs);

    int deleted = 0;
    while (docs.isNotEmpty) {
      final int take = docs.length < 500 ? docs.length : 500;
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> chunk =
          docs.sublist(0, take);
      docs.removeRange(0, take);

      final WriteBatch batch = _db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      deleted += chunk.length;
    }
    return deleted;
  }

  // ---------------------------------------------------------------- upserts

  /// Crea o actualiza una marca. No borra campos omitidos gracias a [merge].
  Future<void> upsertBrand(Brand brand) async {
    if (brand.id.isEmpty) {
      throw ArgumentError('No se puede hacer upsert de una marca sin id.');
    }
    await _brands.doc(brand.id).set(
      brand.toMap(),
      SetOptions(merge: true),
    );
  }

  /// Crea o actualiza una categoria. No borra campos omitidos gracias a [merge].
  Future<void> upsertCategory(Category category) async {
    if (category.id.isEmpty) {
      throw ArgumentError('No se puede hacer upsert de una categoria sin id.');
    }
    await _categories.doc(category.id).set(
      category.toMap(),
      SetOptions(merge: true),
    );
  }

  /// Crea o actualiza un producto. No borra campos omitidos gracias a [merge].
  ///
  /// [images] y [fitments] se escriben como arrays embebidos en el documento.
  Future<void> upsertProduct(
    CatalogProduct product, {
    List<Map<String, dynamic>> images = const <Map<String, dynamic>>[],
    List<Map<String, dynamic>> fitments = const <Map<String, dynamic>>[],
  }) async {
    if (product.id.isEmpty) {
      throw ArgumentError('No se puede hacer upsert de un producto sin id.');
    }
    await _products.doc(product.id).set(
      <String, dynamic>{
        ...product.toMap(),
        'images': images,
        'fitments': fitments,
      },
      SetOptions(merge: true),
    );
  }

  /// Crea o actualiza una marca de vehiculo en `vehicleMakes`.
  Future<void> upsertVehicleMake(Map<String, dynamic> data, {required String id}) async {
    if (id.isEmpty) {
      throw ArgumentError('No se puede hacer upsert de un vehicleMake sin id.');
    }
    await _vehicleMakes.doc(id).set(data, SetOptions(merge: true));
  }

  /// Crea o actualiza un modelo de vehiculo en `vehicleModels`.
  Future<void> upsertVehicleModel(Map<String, dynamic> data, {required String id}) async {
    if (id.isEmpty) {
      throw ArgumentError('No se puede hacer upsert de un vehicleModel sin id.');
    }
    await _vehicleModels.doc(id).set(data, SetOptions(merge: true));
  }

  /// Crea o actualiza un motor en `engines`.
  Future<void> upsertEngine(Map<String, dynamic> data, {required String id}) async {
    if (id.isEmpty) {
      throw ArgumentError('No se puede hacer upsert de un engine sin id.');
    }
    await _engines.doc(id).set(data, SetOptions(merge: true));
  }
}
