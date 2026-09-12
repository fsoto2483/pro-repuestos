import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';

enum AuthStatus { signedOut, authenticating, signedIn }

/// Estado de la sesion. La app escucha esta clase para decidir si muestra el
/// login o el catalogo.
class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.signedOut;
  AppUser? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _status == AuthStatus.authenticating;
  bool get isSignedIn => _status == AuthStatus.signedIn && _user != null;

  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) => _run(
    () => _repository.signInWithPassword(email: email, password: password),
  );

  Future<bool> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) => _run(
    () => _repository.registerWithPassword(
      fullName: fullName,
      email: email,
      password: password,
    ),
  );

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _errorMessage = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Envuelve cualquier operacion de login con el mismo manejo de carga y de
  /// error, para no repetir ese codigo en cada metodo.
  Future<bool> _run(Future<AppUser> Function() action) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await action();
      _status = AuthStatus.signedIn;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.signedOut;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrio un error inesperado. Intenta de nuevo.';
      _status = AuthStatus.signedOut;
      notifyListeners();
      return false;
    }
  }
}
