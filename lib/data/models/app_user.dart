import 'package:flutter/foundation.dart';

import 'user_role.dart';
import 'user_status.dart';

/// Como inicio sesion el usuario.
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
    this.role = UserRole.client,
    this.status = UserStatus.active,
  });

  final String id;
  final String fullName;
  final String email;
  final AuthProvider provider;
  final String? photoUrl;
  final String? workshopName;
  final String? city;
  final UserRole role;
  final UserStatus status;

  bool get isAdmin => role.isAdmin;
  bool get isClient => role.isClient;
  bool get isActive => status.isActive;
  bool get isSuspended => status.isSuspended;

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

  AppUser copyWith({
    String? id,
    String? fullName,
    String? email,
    AuthProvider? provider,
    String? photoUrl,
    String? workshopName,
    String? city,
    UserRole? role,
    UserStatus? status,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      provider: provider ?? this.provider,
      photoUrl: photoUrl ?? this.photoUrl,
      workshopName: workshopName ?? this.workshopName,
      city: city ?? this.city,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}

extension on String {
  String characters(int count) =>
      substring(0, count.clamp(0, length)).toUpperCase();
}
