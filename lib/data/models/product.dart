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
