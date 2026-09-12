import 'package:flutter/foundation.dart';

/// Como inicio sesion el usuario. En la Fase 2 esto lo determinara el
/// proveedor real de autenticacion.
enum AuthProvider { password, google }

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.provider,
    this.photoUrl,
    this.workshopName,
    this.city,
  });

  final String id;
  final String fullName;
  final String email;
  final AuthProvider provider;
  final String? photoUrl;
  final String? workshopName;
  final String? city;

  /// Iniciales para el avatar cuando no hay foto: "Felipe Soto" -> "FS".
  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters(2);
    return '${parts.first.characters(1)}${parts[1].characters(1)}';
  }

  String get firstName => fullName.split(' ').first;
}

extension on String {
  String characters(int count) =>
      substring(0, count.clamp(0, length)).toUpperCase();
}
