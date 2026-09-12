import 'package:flutter/material.dart';

/// Paleta de marca de REPUESTOS PRO.
///
/// Mantener todos los colores aqui evita "numeros magicos" repartidos por la
/// interfaz y permite cambiar la identidad visual desde un solo archivo.
class AppColors {
  const AppColors._();

  /// Naranja industrial: color principal de la marca.
  static const Color brand = Color(0xFFFF5A1F);
  static const Color brandDark = Color(0xFFD8410D);
  static const Color brandSoft = Color(0xFFFFE9E0);

  /// Grafito profundo usado en cabeceras, paneles y modo oscuro.
  static const Color ink = Color(0xFF0D1117);
  static const Color inkSoft = Color(0xFF161C24);
  static const Color steel = Color(0xFF212B36);

  /// Grises de apoyo.
  static const Color slate = Color(0xFF637381);
  static const Color slateLight = Color(0xFF919EAB);
  static const Color line = Color(0xFFE3E8EF);
  static const Color canvas = Color(0xFFF4F6F8);

  /// Semanticos.
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  /// Degradado usado en el panel de marca del login.
  static const List<Color> brandGradient = <Color>[
    Color(0xFF1B1F27),
    Color(0xFF0D1117),
  ];
}
