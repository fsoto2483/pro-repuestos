/// Estado de la cuenta en RepuestosPro.
///
/// Persistido en Firestore `users/{uid}.status` (`active` | `suspended`).
enum UserStatus {
  active,
  suspended,
}

extension UserStatusX on UserStatus {
  String get firestoreValue => name;

  bool get isActive => this == UserStatus.active;
  bool get isSuspended => this == UserStatus.suspended;

  String get label {
    switch (this) {
      case UserStatus.active:
        return 'Activo';
      case UserStatus.suspended:
        return 'Suspendido';
    }
  }

  /// Interpreta `status` de Firestore. Ausente o desconocido → active.
  static UserStatus fromFirestore(Object? value) {
    if (value is String && value.trim().toLowerCase() == 'suspended') {
      return UserStatus.suspended;
    }
    return UserStatus.active;
  }
}
