import '../models/app_user.dart';

/// Error de autenticacion con un mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Autenticacion simulada de la Fase 1.
///
/// No hay Firebase, Supabase ni backend: las credenciales se validan contra
/// una cuenta de demostracion. La firma de los metodos ya es la misma que
/// usaria un proveedor real, asi que en la Fase 2 solo se cambia el cuerpo.
class AuthRepository {
  const AuthRepository();

  static const String demoEmail = 'demo@repuestospro.com';
  static const String demoPassword = 'repuestos123';

  static const Duration _latency = Duration(milliseconds: 900);

  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);

    final String normalized = email.trim().toLowerCase();
    if (normalized != demoEmail) {
      throw const AuthException(
        'No encontramos una cuenta con ese correo. Usa la cuenta de prueba.',
      );
    }
    if (password != demoPassword) {
      throw const AuthException('La contrasena no es correcta.');
    }

    return const AppUser(
      id: 'u-demo',
      fullName: 'Felipe Soto',
      email: demoEmail,
      provider: AuthProvider.password,
      workshopName: 'Taller Motor Norte',
      city: 'Bogota',
    );
  }

  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(_latency);
    return const AppUser(
      id: 'u-google',
      fullName: 'Felipe Soto',
      email: 'felipe.soto@gmail.com',
      provider: AuthProvider.google,
      workshopName: 'Taller Motor Norte',
      city: 'Bogota',
    );
  }

  Future<AppUser> registerWithPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_latency);
    return AppUser(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      provider: AuthProvider.password,
    );
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
