import 'package:flutter/material.dart';

import '../../core/theme/category_icons.dart';

/// Categoria del catalogo (Frenos, Motor, Suspension, ...).
///
/// El color y el icono viajan con la categoria porque toda la identidad visual
/// del catalogo se construye a partir de ellos.
@immutable
class PartCategory {
  const PartCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.sortOrder = 0,
    this.productCount = 0,
  });

  /// Construye la categoria desde lo que devuelve la base de datos, donde el
  /// icono es una clave de texto y el color un hexadecimal.
  factory PartCategory.fromStorage({
    required String id,
    required String name,
    required String description,
    required String iconKey,
    required String colorHex,
    int sortOrder = 0,
    int productCount = 0,
  }) {
    return PartCategory(
      id: id,
      name: name,
      description: description,
      icon: categoryIconFor(iconKey),
      color: colorFromHex(colorHex),
      sortOrder: sortOrder,
      productCount: productCount,
    );
  }

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int sortOrder;
  final int productCount;

  /// Degradado suave derivado del color de la categoria.
  List<Color> get gradient => <Color>[
    Color.lerp(color, Colors.white, 0.12)!,
    Color.lerp(color, Colors.black, 0.28)!,
  ];

  PartCategory withCount(int count) => PartCategory(
    id: id,
    name: name,
    description: description,
    icon: icon,
    color: color,
    sortOrder: sortOrder,
    productCount: count,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PartCategory && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
