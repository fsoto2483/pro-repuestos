import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/app_user.dart';

/// Persiste el perfil de usuario en la coleccion Firestore `users`.
///
/// Crea el documento solo la primera vez; si ya existe, no lo duplica ni
/// sobrescribe campos existentes.
class UserService {
  const UserService();

  static const String collectionName = 'users';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Garantiza un documento `users/{uid}` tras un login o registro exitoso.
  Future<void> ensureUserDocument(AppUser user) async {
    final DocumentReference<Map<String, dynamic>> doc =
        _db.collection(collectionName).doc(user.id);

    final DocumentSnapshot<Map<String, dynamic>> snap = await doc.get();
    if (snap.exists) return;

    await doc.set(<String, dynamic>{
      'uid': user.id,
      'nombre': user.fullName,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'provider': user.provider.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
