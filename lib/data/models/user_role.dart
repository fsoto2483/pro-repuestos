/// Rol de acceso en RepuestosPro.
///
/// Persistido en Firestore `users/{uid}.role` como string (`admin` | `client`).
enum UserRole {
  admin,
  client,
}

extension UserRoleX on UserRole {
  /// Valor guardado en Firestore.
  String get firestoreValue => name;

  bool get isAdmin => this == UserRole.admin;
  bool get isClient => this == UserRole.client;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.client:
        return 'Cliente';
    }
  }

  /// Interpreta el campo `role` de Firestore. Valores desconocidos → client.
  static UserRole fromFirestore(Object? value) {
    if (value is String && value.trim().toLowerCase() == 'admin') {
      return UserRole.admin;
    }
    return UserRole.client;
  }
}
