import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';

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

  /// Crea `users/{uid}` si no existe (rol `client`, status `active`) y
  /// siempre devuelve el perfil con rol/status leidos desde Firestore.
  Future<AppUser> ensureUserDocument(AppUser user) async {
    final DocumentReference<Map<String, dynamic>> doc = _users.doc(user.id);
    final DocumentSnapshot<Map<String, dynamic>> snap = await doc.get();

    if (!snap.exists) {
      await doc.set(_newUserPayload(user));
      return user.copyWith(
        role: UserRole.client,
        status: UserStatus.active,
      );
    }

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(snap.data() ?? <String, dynamic>{});

    // Docs legacy sin status: rellena active sin tocar el rol.
    if (!data.containsKey('status')) {
      try {
        await doc.set(
          <String, dynamic>{
            'status': UserStatus.active.firestoreValue,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        data['status'] = UserStatus.active.firestoreValue;
      } on FirebaseException catch (e) {
        debugPrint(
          'UserService.ensureUserDocument backfill status: '
          'code=${e.code} message=${e.message}',
        );
      }
    }

    return _fromFirestore(user.id, data, fallback: user);
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
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestore(snap.id, snap.data()!);
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
