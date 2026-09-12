import 'package:flutter/material.dart';

/// Iconos disponibles para las categorias.
///
/// La base de datos guarda solo la clave de texto (`frenos`, `motor`...) y
/// aqui se traduce a un icono. Se hace asi porque Flutter necesita que los
/// iconos sean constantes para poder descartar los que no se usan al compilar;
/// construir un `IconData` desde un numero guardado en la base de datos
/// romperia esa optimizacion.
const Map<String, IconData> kCategoryIcons = <String, IconData>{
  'frenos': Icons.disc_full_rounded,
  'direccion': Icons.trip_origin_rounded,
  'suspension': Icons.waves_rounded,
  'motor': Icons.settings_suggest_rounded,
  'transmision': Icons.settings_input_component_rounded,
  'electrico': Icons.bolt_rounded,
  'lubricantes': Icons.water_drop_rounded,
  'filtros': Icons.filter_alt_rounded,
  'refrigeracion': Icons.ac_unit_rounded,
  'carroceria': Icons.directions_car_filled_rounded,
  'llantas': Icons.tire_repair_rounded,
  'default': Icons.build_circle_rounded,
};

IconData categoryIconFor(String key) =>
    kCategoryIcons[key] ?? kCategoryIcons['default']!;

/// Convierte `#E03131` en un `Color`. Si el texto no es valido devuelve el
/// color de respaldo en lugar de reventar.
Color colorFromHex(String hex, {Color fallback = const Color(0xFFFF5A1F)}) {
  String value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  final int? parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

String colorToHex(Color color) {
  final int argb = color.toARGB32();
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
