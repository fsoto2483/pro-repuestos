import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/user_service.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../models/user_status.dart';

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
    // ignore: avoid_print
    print('[AUTH_FLOW] signInWithPassword START email=${email.trim()}');
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
      // ignore: avoid_print
      print('[AUTH_FLOW] signInWithPassword Auth OK uid=${user.uid}');
      return await _completeSignIn(user);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('[AUTH_FLOW] signInWithPassword Auth FAIL code=${e.code} $e');
      throw AuthException(_mapFirebaseAuthError(e));
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(
        '[RULES_CHECK] signInWithPassword FirebaseException '
        'code=${e.code} message=${e.message} full=$e',
      );
      throw AuthException(_mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('signInWithPassword: $e\n$st');
      throw AuthException(_unexpectedMessage(e));
    }
  }

  Future<AppUser> signInWithGoogle() async {
    // ignore: avoid_print
    print('[AUTH_FLOW] signInWithGoogle START');
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
      // ignore: avoid_print
      print('[AUTH_FLOW] signInWithGoogle Auth OK uid=${user.uid}');
      return await _completeSignIn(user);
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
      // ignore: avoid_print
      print('[AUTH_FLOW] signInWithGoogle Auth FAIL code=${e.code} $e');
      throw AuthException(_mapFirebaseAuthError(e));
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(
        '[RULES_CHECK] signInWithGoogle FirebaseException '
        'code=${e.code} message=${e.message} full=$e',
      );
      throw AuthException(_mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('signInWithGoogle: $e\n$st');
      throw AuthException(_unexpectedMessage(e));
    }
  }

  Future<AppUser> registerWithPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // ignore: avoid_print
    print('[AUTH_FLOW] registerWithPassword START email=${email.trim()}');
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
      // ignore: avoid_print
      print(
        '[AUTH_FLOW] registerWithPassword Auth OK uid=${user.uid} '
        '(cuenta Auth creada; sigue perfil Firestore)',
      );

      final String name = fullName.trim();
      if (name.isNotEmpty) {
        try {
          await user.updateDisplayName(name);
          await user.reload();
        } catch (e) {
          // El perfil Auth se puede completar despues; no bloquea el registro.
          debugPrint('registerWithPassword displayName: $e');
        }
      }

      final User refreshed = FirebaseAuth.instance.currentUser ?? user;
      return await _completeSignIn(refreshed);
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('[AUTH_FLOW] registerWithPassword Auth FAIL code=${e.code} $e');
      throw AuthException(_mapFirebaseAuthError(e));
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(
        '[RULES_CHECK] registerWithPassword FirebaseException '
        'code=${e.code} message=${e.message} full=$e',
      );
      throw AuthException(_mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('registerWithPassword: $e\n$st');
      throw AuthException(_unexpectedMessage(e));
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

  /// Mapea el usuario Firebase, asegura el doc en `users` y carga rol/status.
  ///
  /// Si la cuenta esta suspendida, cierra la sesion de Firebase Auth y falla
  /// con un mensaje claro para el usuario.
  Future<AppUser> _completeSignIn(User user) async {
    // ignore: avoid_print
    print(
      '[AUTH_FLOW] _completeSignIn START uid=${user.uid} '
      'email=${user.email} providers='
      '${user.providerData.map((UserInfo p) => p.providerId).toList()}',
    );
    try {
      final AppUser mapped = _mapFirebaseUser(user);
      // ignore: avoid_print
      print(
        '[AUTH_FLOW] mapped AppUser id=${mapped.id} '
        'roleDefault=${mapped.role.firestoreValue} '
        'statusDefault=${mapped.status.firestoreValue}',
      );
      final AppUser appUser = await userService.ensureUserDocument(mapped);
      // ignore: avoid_print
      print(
        '[AUTH_FLOW] _completeSignIn perfil OK '
        'role=${appUser.role.firestoreValue} '
        'status=${appUser.status.firestoreValue}',
      );

      if (appUser.isSuspended) {
        // ignore: avoid_print
        print('[AUTH_FLOW] usuario SUSPENDED → signOut');
        await signOut();
        throw const AuthException(
          'Tu cuenta ha sido suspendida. Contacta al administrador.',
        );
      }

      return appUser;
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(
        '[RULES_CHECK] _completeSignIn FAIL '
        'code=${e.code} message=${e.message} plugin=${e.plugin} full=$e '
        'stack=${e.stackTrace}',
      );
      // Auth quedo abierta pero el perfil Firestore fallo: cerrar para no
      // dejar una sesion a medias.
      try {
        await signOut();
      } catch (_) {}
      throw AuthException(_mapFirebaseError(e));
    } catch (e, st) {
      // ignore: avoid_print
      print('[AUTH_FLOW] _completeSignIn ERROR: $e\n$st');
      try {
        await signOut();
      } catch (_) {}
      throw AuthException(_unexpectedMessage(e));
    }
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

  String _mapFirebaseError(FirebaseException e) {
    // Auditoria: incluir excepcion completa en el mensaje visible.
    final String full =
        'FirebaseException(code=${e.code}, message=${e.message}, '
        'plugin=${e.plugin})';
    switch (e.code) {
      case 'permission-denied':
        return 'permission-denied al sincronizar users/{uid}. $full';
      case 'unavailable':
      case 'network-request-failed':
        return 'Sin conexion con Firestore. $full';
      default:
        return 'Error Firestore al sincronizar perfil. $full';
    }
  }

  String _unexpectedMessage(Object e) {
    final String detail = e.toString();
    if (detail.isEmpty || detail == 'Exception') {
      return 'Ocurrio un error inesperado. Intenta de nuevo.';
    }
    return 'No se pudo completar el acceso. $detail';
  }
}
