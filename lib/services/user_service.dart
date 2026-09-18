import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../data/models/app_user.dart';
import '../data/models/user_role.dart';
import '../data/models/user_status.dart';

/// Persiste y consulta perfiles en la coleccion Firestore `users`.
///
/// Documento tipico `users/{uid}`:
/// - uid, nombre, email, photoUrl, provider, role, status, createdAt, updatedAt
class UserService {
  const UserService();

  static const String collectionName = 'users';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(collectionName);

  // ignore: avoid_print
  void _audit(String tag, String message) {
    // ignore: avoid_print
    print('[$tag] $message');
  }

  void _auditFirebaseException(String phase, FirebaseException e) {
    _audit(
      'RULES_CHECK',
      'phase=$phase code=${e.code} plugin=${e.plugin} '
      'message=${e.message} full=$e',
    );
    if (e.code == 'permission-denied' ||
        (e.message?.toLowerCase().contains('permission') ?? false) ||
        (e.message?.toLowerCase().contains('missing or insufficient') ??
            false)) {
      _audit(
        'RULES_CHECK',
        'PERMISSION REJECTED — excepcion completa: '
        'FirebaseException(code=${e.code}, message=${e.message}, '
        'plugin=${e.plugin}, stackTrace=${e.stackTrace})',
      );
    }
  }

  /// Crea `users/{uid}` si no existe (rol `client`, status `active`) y
  /// siempre devuelve el perfil con rol/status leidos desde Firestore.
  Future<AppUser> ensureUserDocument(AppUser user) async {
    final String authUid = FirebaseAuth.instance.currentUser?.uid ?? '(null)';
    final DocumentReference<Map<String, dynamic>> doc = _users.doc(user.id);

    _audit(
      'AUTH_FLOW',
      'ensureUserDocument INICIO authUid=$authUid '
      'docPath=users/${user.id} email=${user.email}',
    );
    _audit(
      'RULES_CHECK',
      'Expectativa local: allow get si isOwner; '
      'allow create si isOwner + role=client + status=active + shape valido. '
      'Si falla create con permission-denied → rules desplegadas no coinciden '
      'o validacion isValidUserShape rechazo el payload.',
    );

    try {
      _audit('USER_READ', 'intento GET users/${user.id}');
      final DocumentSnapshot<Map<String, dynamic>> snap = await doc.get();
      _audit(
        'USER_READ',
        'resultado GET exists=${snap.exists} '
        'hasData=${snap.data() != null}',
      );

      if (!snap.exists) {
        final Map<String, dynamic> payload = _newUserPayload(user);
        _audit(
          'USER_CREATE',
          'intento CREATE users/${user.id} keys=${payload.keys.toList()} '
          'role=${payload['role']} status=${payload['status']} '
          'uidField=${payload['uid']} provider=${payload['provider']} '
          'nombreLen=${(payload['nombre'] as String?)?.length} '
          'email=${payload['email']} '
          'createdAtType=${payload['createdAt'].runtimeType}',
        );

        try {
          await doc.set(payload);
          _audit(
            'USER_CREATE',
            'resultado CREATE OK users/${user.id}',
          );
        } on FirebaseException catch (e) {
          _audit(
            'USER_CREATE',
            'resultado CREATE FAIL users/${user.id}',
          );
          _auditFirebaseException('USER_CREATE', e);
          rethrow;
        }

        _audit(
          'AUTH_FLOW',
          'perfil nuevo local role=client status=active '
          '(sin re-read post-create)',
        );
        return user.copyWith(
          role: UserRole.client,
          status: UserStatus.active,
        );
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(snap.data() ?? <String, dynamic>{});

      _audit(
        'USER_READ',
        'doc existente keys=${data.keys.toList()} '
        'roleRaw=${data['role']} statusRaw=${data['status']}',
      );

      // Docs legacy sin status: rellena active sin tocar el rol.
      if (!data.containsKey('status')) {
        _audit(
          'USER_CREATE',
          'backfill status=active (merge) users/${user.id}',
        );
        try {
          await doc.set(
            <String, dynamic>{
              'status': UserStatus.active.firestoreValue,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
          data['status'] = UserStatus.active.firestoreValue;
          _audit('USER_CREATE', 'backfill status OK');
        } catch (e) {
          _audit('USER_CREATE', 'backfill status FAIL: $e');
          if (e is FirebaseException) {
            _auditFirebaseException('USER_BACKFILL_STATUS', e);
          }
        }
      }

      final AppUser loaded = _fromFirestore(user.id, data, fallback: user);
      _audit(
        'AUTH_FLOW',
        'role leido=${loaded.role.firestoreValue} '
        'status leido=${loaded.status.firestoreValue} '
        'isAdmin=${loaded.isAdmin} isSuspended=${loaded.isSuspended}',
      );
      return loaded;
    } on FirebaseException catch (e) {
      _auditFirebaseException('ensureUserDocument', e);
      rethrow;
    } catch (e, st) {
      _audit('AUTH_FLOW', 'ensureUserDocument ERROR no-Firebase: $e\n$st');
      rethrow;
    }
  }

  Map<String, dynamic> _newUserPayload(AppUser user) {
    final Timestamp now = Timestamp.now();
    final String nombre = user.fullName.trim().isEmpty
        ? user.email.trim()
        : user.fullName.trim();
    final Map<String, dynamic> payload = <String, dynamic>{
      'uid': user.id,
      'nombre': nombre,
      'email': user.email.trim(),
      'provider': user.provider.name,
      'role': UserRole.client.firestoreValue,
      'status': UserStatus.active.firestoreValue,
      // Timestamp de cliente: evita falsos permission-denied con
      // serverTimestamp() en reglas (`createdAt is timestamp`).
      'createdAt': now,
      'updatedAt': now,
    };
    if (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty) {
      payload['photoUrl'] = user.photoUrl!.trim();
    }
    return payload;
  }

  /// Lee el documento del usuario autenticado (o el [uid] indicado).
  Future<AppUser?> fetchUser(String uid) async {
    if (uid.isEmpty) return null;
    _audit('USER_READ', 'fetchUser intento GET users/$uid');
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _users.doc(uid).get();
      _audit(
        'USER_READ',
        'fetchUser resultado exists=${snap.exists}',
      );
      if (!snap.exists || snap.data() == null) return null;
      final AppUser loaded = _fromFirestore(snap.id, snap.data()!);
      _audit(
        'AUTH_FLOW',
        'fetchUser role=${loaded.role.firestoreValue} '
        'status=${loaded.status.firestoreValue}',
      );
      return loaded;
    } on FirebaseException catch (e) {
      _auditFirebaseException('fetchUser', e);
      rethrow;
    }
  }

  /// Lista todos los usuarios (solo util para administradores).
  Future<List<AppUser>> listUsers() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await _users.orderBy('email').get();
    return snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              _fromFirestore(doc.id, doc.data()),
        )
        .toList();
  }

  /// Cambia el rol de un usuario. Requiere permisos de admin en reglas.
  Future<void> setUserRole(String uid, UserRole role) async {
    if (uid.isEmpty) {
      throw ArgumentError('uid requerido');
    }
    final User? current = FirebaseAuth.instance.currentUser;
    if (current == null) {
      throw StateError('Debes iniciar sesion para cambiar roles.');
    }
    if (current.uid == uid && role != UserRole.admin) {
      throw StateError('No puedes quitarte el rol de administrador a ti mismo.');
    }

    await _users.doc(uid).update(<String, dynamic>{
      'role': role.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cambia el estado active/suspended. Requiere permisos de admin en reglas.
  Future<void> updateUserStatus(String uid, UserStatus status) async {
    if (uid.isEmpty) {
      throw ArgumentError('uid requerido');
    }
    final User? current = FirebaseAuth.instance.currentUser;
    if (current == null) {
      throw StateError('Debes iniciar sesion para cambiar el estado.');
    }
    if (current.uid == uid && status == UserStatus.suspended) {
      throw StateError('No puedes suspender tu propia cuenta.');
    }

    await _users.doc(uid).update(<String, dynamic>{
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  AppUser _fromFirestore(
    String id,
    Map<String, dynamic> data, {
    AppUser? fallback,
  }) {
    final String? nombre = (data['nombre'] as String?)?.trim();
    final String email =
        (data['email'] as String?)?.trim() ?? fallback?.email ?? '';
    final String providerRaw =
        (data['provider'] as String?)?.trim().toLowerCase() ?? '';
    final AuthProvider provider = providerRaw == 'google'
        ? AuthProvider.google
        : (fallback?.provider ?? AuthProvider.password);

    return AppUser(
      id: id,
      fullName: (nombre != null && nombre.isNotEmpty)
          ? nombre
          : (fallback?.fullName ?? email),
      email: email,
      provider: provider,
      photoUrl: data['photoUrl'] as String? ?? fallback?.photoUrl,
      workshopName: data['workshopName'] as String? ?? fallback?.workshopName,
      city: data['city'] as String? ?? fallback?.city,
      role: UserRoleX.fromFirestore(data['role']),
      status: UserStatusX.fromFirestore(data['status']),
    );
  }
}
