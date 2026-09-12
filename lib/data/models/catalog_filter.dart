import 'package:flutter/foundation.dart';

enum ProductSort { relevance, priceAsc, priceDesc, rating, name }

extension ProductSortLabel on ProductSort {
  String get label {
    switch (this) {
      case ProductSort.relevance:
        return 'Relevancia';
      case ProductSort.priceAsc:
        return 'Menor precio';
      case ProductSort.priceDesc:
        return 'Mayor precio';
      case ProductSort.rating:
        return 'Mejor calificados';
      case ProductSort.name:
        return 'Nombre A-Z';
    }
  }
}

/// Todo lo que el usuario puede acotar del catalogo en un solo objeto.
///
/// Se pasa completo a la base de datos, que arma la consulta SQL. Al ser
/// inmutable, cada cambio produce un filtro nuevo y es facil saber cuando hay
/// que volver a consultar.
@immutable
class CatalogFilter {
  const CatalogFilter({
    this.query = '',
    this.categoryId,
    this.makeId,
    this.modelId,
    this.engineId,
    this.year,
    this.partBrandId,
    this.onlyAvailable = false,
    this.sort = ProductSort.relevance,
  });

  final String query;
  final String? categoryId;

  /// Marca del vehiculo (Chevrolet, Renault...), primer nivel del filtro.
  final String? makeId;
  final String? modelId;
  final String? engineId;
  final int? year;

  /// Marca del repuesto (Bosch, Brembo...), independiente del vehiculo.
  final String? partBrandId;

  final bool onlyAvailable;
  final ProductSort sort;

  bool get hasVehicle => makeId != null;

  bool get isEmpty =>
      query.isEmpty &&
      categoryId == null &&
      makeId == null &&
      partBrandId == null &&
      !onlyAvailable &&
      sort == ProductSort.relevance;

  /// Cuantos filtros hay activos, sin contar la busqueda por texto.
  int get activeCount {
    int count = 0;
    if (categoryId != null) count++;
    if (makeId != null) count++;
    if (modelId != null) count++;
    if (engineId != null) count++;
    if (year != null) count++;
    if (partBrandId != null) count++;
    if (onlyAvailable) count++;
    if (sort != ProductSort.relevance) count++;
    return count;
  }

  /// `copyWith` no sirve para borrar campos, porque `null` significa "no
  /// cambiar". Por eso cada campo que se puede limpiar tiene su bandera
  /// `clearX`. Al cambiar de marca, por ejemplo, hay que borrar el modelo.
  CatalogFilter copyWith({
    String? query,
    String? categoryId,
    bool clearCategory = false,
    String? makeId,
    bool clearMake = false,
    String? modelId,
    bool clearModel = false,
    String? engineId,
    bool clearEngine = false,
    int? year,
    bool clearYear = false,
    String? partBrandId,
    bool clearPartBrand = false,
    bool? onlyAvailable,
    ProductSort? sort,
  }) {
    return CatalogFilter(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      makeId: clearMake ? null : (makeId ?? this.makeId),
      modelId: clearModel ? null : (modelId ?? this.modelId),
      engineId: clearEngine ? null : (engineId ?? this.engineId),
      year: clearYear ? null : (year ?? this.year),
      partBrandId: clearPartBrand ? null : (partBrandId ?? this.partBrandId),
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CatalogFilter &&
      other.query == query &&
      other.categoryId == categoryId &&
      other.makeId == makeId &&
      other.modelId == modelId &&
      other.engineId == engineId &&
      other.year == year &&
      other.partBrandId == partBrandId &&
      other.onlyAvailable == onlyAvailable &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    query,
    categoryId,
    makeId,
    modelId,
    engineId,
    year,
    partBrandId,
    onlyAvailable,
    sort,
  );
}
