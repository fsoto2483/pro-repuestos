import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'part_category.dart';
import 'vehicle.dart';

/// Estado de inventario derivado de la cantidad disponible.
enum StockStatus { inStock, lowStock, outOfStock }

extension StockStatusLabel on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.inStock:
        return 'Disponible';
      case StockStatus.lowStock:
        return 'Ultimas unidades';
      case StockStatus.outOfStock:
        return 'Agotado';
    }
  }
}

/// Un repuesto listo para mostrar en pantalla.
///
/// Ya trae resuelta la categoria y el nombre de la marca, que en la base de
/// datos viven en tablas aparte. La consulta hace el cruce una sola vez y la
/// interfaz no necesita volver a buscar nada.
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.oem,
    required this.brandId,
    required this.brand,
    required this.price,
    required this.stock,
    required this.description,
    this.previousPrice,
    this.rating = 0,
    this.reviewCount = 0,
    this.images = const <String>[],
    this.isFeatured = false,
    this.warrantyMonths = 12,
    this.fitments = const <Fitment>[],
    this.specs = const <String, String>{},
  });

  final String id;
  final String name;
  final PartCategory category;
  final String sku;
  final String oem;
  final String brandId;
  final String brand;
  final double price;
  final double? previousPrice;
  final int stock;
  final String description;
  final double rating;
  final int reviewCount;

  /// Todas las fotos del producto, la principal de primera.
  final List<String> images;

  final bool isFeatured;
  final int warrantyMonths;

  /// Compatibilidad ya resuelta. Solo se llena en la ficha del producto; en el
  /// listado se deja vacia para no cargar datos que no se ven.
  final List<Fitment> fitments;

  final Map<String, String> specs;

  String get categoryId => category.id;

  String? get imageUrl => images.isEmpty ? null : images.first;

  StockStatus get stockStatus {
    if (stock <= 0) return StockStatus.outOfStock;
    if (stock <= 5) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  bool get isAvailable => stock > 0;

  bool get hasDiscount => previousPrice != null && previousPrice! > price;

  int get discountPercent => hasDiscount
      ? (((previousPrice! - price) / previousPrice!) * 100).round()
      : 0;

  Product copyWith({List<Fitment>? fitments, List<String>? images}) => Product(
    id: id,
    name: name,
    category: category,
    sku: sku,
    oem: oem,
    brandId: brandId,
    brand: brand,
    price: price,
    stock: stock,
    description: description,
    previousPrice: previousPrice,
    rating: rating,
    reviewCount: reviewCount,
    images: images ?? this.images,
    isFeatured: isFeatured,
    warrantyMonths: warrantyMonths,
    fitments: fitments ?? this.fitments,
    specs: specs,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// Documento de producto en la coleccion Firestore `products` (FASE 2).
///
/// Convive con [Product], que es el modelo denormalizado de la UI local
/// (Drift). Este DTO refleja el documento remoto sin cruce de tablas.
@immutable
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.oem,
    required this.brandId,
    required this.categoryId,
    required this.price,
    required this.stock,
    required this.description,
    this.photoUrl,
    this.previousPrice,
    this.isFeatured = false,
    this.warrantyMonths = 12,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt,
    this.updatedAt,
    this.imageEntries = const <Map<String, dynamic>>[],
    this.fitmentEntries = const <Map<String, dynamic>>[],
  });

  factory CatalogProduct.fromMap(String id, Map<String, dynamic> data) {
    return CatalogProduct(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      sku: (data['sku'] as String?)?.trim() ?? '',
      oem: (data['oem'] as String?)?.trim() ?? '',
      brandId: (data['brandId'] as String?)?.trim() ?? '',
      categoryId: (data['categoryId'] as String?)?.trim() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      description: (data['description'] as String?)?.trim() ?? '',
      photoUrl: data['photoUrl'] as String?,
      previousPrice: (data['previousPrice'] as num?)?.toDouble(),
      isFeatured: data['isFeatured'] as bool? ?? false,
      warrantyMonths: (data['warrantyMonths'] as num?)?.toInt() ?? 12,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: _readProductTimestamp(data['createdAt']),
      updatedAt: _readProductTimestamp(data['updatedAt']),
      imageEntries: _readMapList(data['images']),
      fitmentEntries: _readMapList(data['fitments']),
    );
  }

  final String id;
  final String name;
  final String sku;
  final String oem;
  final String brandId;
  final String categoryId;
  final double price;
  final int stock;
  final String description;
  final String? photoUrl;
  final double? previousPrice;
  final bool isFeatured;
  final int warrantyMonths;
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Entradas crudas de `images` / `fitments` tal como vienen de Firestore.
  final List<Map<String, dynamic>> imageEntries;
  final List<Map<String, dynamic>> fitmentEntries;

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return <String, dynamic>{
      'name': name,
      'sku': sku,
      'oem': oem,
      'brandId': brandId,
      'categoryId': categoryId,
      'price': price,
      'stock': stock,
      'description': description,
      'photoUrl': photoUrl,
      'previousPrice': previousPrice,
      'isFeatured': isFeatured,
      'warrantyMonths': warrantyMonths,
      'rating': rating,
      'reviewCount': reviewCount,
      if (!isUpdate && createdAt == null)
        'createdAt': FieldValue.serverTimestamp()
      else if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CatalogProduct copyWith({
    String? id,
    String? name,
    String? sku,
    String? oem,
    String? brandId,
    String? categoryId,
    double? price,
    int? stock,
    String? description,
    String? photoUrl,
    double? previousPrice,
    bool? isFeatured,
    int? warrantyMonths,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? imageEntries,
    List<Map<String, dynamic>>? fitmentEntries,
  }) {
    return CatalogProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      oem: oem ?? this.oem,
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      previousPrice: previousPrice ?? this.previousPrice,
      isFeatured: isFeatured ?? this.isFeatured,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageEntries: imageEntries ?? this.imageEntries,
      fitmentEntries: fitmentEntries ?? this.fitmentEntries,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CatalogProduct && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

DateTime? _readProductTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

List<Map<String, dynamic>> _readMapList(Object? raw) {
  if (raw is! List<dynamic>) return const <Map<String, dynamic>>[];
  return raw
      .whereType<Map<dynamic, dynamic>>()
      .map(
        (Map<dynamic, dynamic> e) =>
            e.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
      )
      .toList();
}
