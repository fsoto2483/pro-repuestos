import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/user_service.dart';
import '../models/app_user.dart';

/// Error de autenticacion con un mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  const AuthRepository({
    this.userService = const UserService(),
  });

  /// Conservadas porque [LoginScreen] las referencia (autofill de prueba).
  /// Ya no autentican contra una cuenta simulada.
  static const String demoEmail = 'demo@repuestospro.com';
  static const String demoPassword = 'repuestos123';

  final UserService userService;

  static bool _googleReady = false;

  Future<void> _ensureGoogleSignIn() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize();
    _googleReady = true;
  }

  Future<AppUser> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = credential.user;
      if (user == null) {
        throw const AuthException(
          'No se pudo iniciar sesion. Intenta de nuevo.',
        );
      }
      return _completeSignIn(user);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthException(
        e.message ?? 'No se pudo sincronizar el perfil del usuario.',
      );
    } catch (_) {
      throw const AuthException(
        'Ocurrio un error inesperado. Intenta de nuevo.',
      );
    }
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      final UserCredential credential;
      if (kIsWeb) {
        // En web, GIS no soporta authenticate(); Firebase popup es el flujo
        // recomendado y evita configurar clientId a mano.
        credential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        await _ensureGoogleSignIn();
        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();
        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final String? idToken = googleAuth.idToken;
        if (idToken == null) {
          throw const AuthException(
            'Google no devolvio un token de identidad.',
          );
        }
        credential = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }

      final User? user = credential.user;
      if (user == null) {
        throw const AuthException(
          'No se pudo iniciar sesion con Google.',
        );
      }
      return _completeSignIn(user);
    } on AuthException {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Inicio de sesion cancelado.');
      }
      throw AuthException(
        e.description ?? 'No se pudo iniciar sesion con Google.',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthException(
        e.message ?? 'No se pudo sincronizar el perfil del usuario.',
      );
    } catch (_) {
      throw const AuthException(
        'Ocurrio un error inesperado. Intenta de nuevo.',
      );
    }
  }

  Future<AppUser> registerWithPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = credential.user;
      if (user == null) {
        throw const AuthException(
          'No se pudo crear la cuenta. Intenta de nuevo.',
        );
      }

      final String name = fullName.trim();
      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      final User refreshed = FirebaseAuth.instance.currentUser ?? user;
      return _completeSignIn(refreshed);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthException(
        e.message ?? 'No se pudo sincronizar el perfil del usuario.',
      );
    } catch (_) {
      throw const AuthException(
        'Ocurrio un error inesperado. Intenta de nuevo.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleSignIn();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Si Google no estaba inicializado o no habia sesion, seguimos.
    }
    await FirebaseAuth.instance.signOut();
  }

  /// Mapea el usuario Firebase y crea el documento Firestore si no existe.
  Future<AppUser> _completeSignIn(User user) async {
    final AppUser appUser = _mapFirebaseUser(user);
    await userService.ensureUserDocument(appUser);
    return appUser;
  }

  AppUser _mapFirebaseUser(User user) {
    final bool isGoogle = user.providerData.any(
      (UserInfo info) => info.providerId == 'google.com',
    );
    final String? displayName = user.displayName?.trim();
    return AppUser(
      id: user.uid,
      fullName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : (user.email ?? 'Usuario'),
      email: user.email ?? '',
      provider: isGoogle ? AuthProvider.google : AuthProvider.password,
      photoUrl: user.photoURL,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contrasena es demasiado debil.';
      case 'invalid-email':
        return 'El correo no es valido.';
      case 'network-request-failed':
        return 'Sin conexion. Revisa tu internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Inicio de sesion cancelado.';
      case 'operation-not-allowed':
        return 'Este metodo de acceso no esta habilitado.';
      default:
        return e.message ?? 'No se pudo completar la autenticacion.';
    }
  }
}
