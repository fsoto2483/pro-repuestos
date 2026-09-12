import 'package:flutter/foundation.dart';

/// Marca de vehiculo: Chevrolet, Renault, Hyundai...
@immutable
class VehicleMake {
  const VehicleMake({
    required this.id,
    required this.name,
    this.country = '',
    this.modelCount = 0,
  });

  final String id;
  final String name;
  final String country;
  final int modelCount;

  @override
  bool operator ==(Object other) => other is VehicleMake && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Modelo de un vehiculo, por ejemplo Spark GT 2011-2017.
@immutable
class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.makeId,
    required this.name,
    required this.yearFrom,
    required this.yearTo,
    this.bodyType = '',
  });

  final String id;
  final String makeId;
  final String name;
  final String bodyType;
  final int yearFrom;
  final int yearTo;

  String get yearRange => '$yearFrom-$yearTo';

  List<int> get years =>
      <int>[for (int y = yearTo; y >= yearFrom; y--) y];

  @override
  bool operator ==(Object other) => other is VehicleModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Motor disponible para un modelo.
@immutable
class Engine {
  const Engine({
    required this.id,
    required this.modelId,
    required this.code,
    required this.name,
    required this.yearFrom,
    required this.yearTo,
    this.displacement = 0,
    this.fuel = 'Gasolina',
    this.horsepower = 0,
  });

  final String id;
  final String modelId;
  final String code;
  final String name;
  final double displacement;
  final String fuel;
  final int horsepower;
  final int yearFrom;
  final int yearTo;

  String get summary {
    final List<String> parts = <String>[
      if (displacement > 0) '${displacement.toStringAsFixed(1)} L',
      fuel,
      if (horsepower > 0) '$horsepower hp',
    ];
    return parts.join(' · ');
  }

  @override
  bool operator ==(Object other) => other is Engine && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Marca del repuesto: Bosch, Brembo, Monroe...
@immutable
class PartBrand {
  const PartBrand({
    required this.id,
    required this.name,
    this.country = '',
    this.tier = 'homologada',
    this.productCount = 0,
  });

  final String id;
  final String name;
  final String country;
  final String tier;
  final int productCount;

  bool get isOriginal => tier == 'original';

  @override
  bool operator ==(Object other) => other is PartBrand && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Una linea de compatibilidad ya resuelta y lista para mostrar.
@immutable
class Fitment {
  const Fitment({
    required this.makeName,
    required this.modelName,
    required this.yearFrom,
    required this.yearTo,
    this.engineName,
  });

  final String makeName;
  final String modelName;
  final String? engineName;
  final int yearFrom;
  final int yearTo;

  /// "Chevrolet Spark GT 1.2 2011-2017"
  String get label {
    final String engine = engineName == null ? '' : ' $engineName';
    return '$makeName $modelName$engine $yearFrom-$yearTo';
  }
}
