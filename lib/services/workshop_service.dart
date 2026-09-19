import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/workshop_data.dart';

/// Lee y persiste `users/{uid}.workshop` en Firestore.
class WorkshopService {
  const WorkshopService();

  static const String collectionName = 'users';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection(collectionName).doc(uid);

  String get _requireUid {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw StateError('Debes iniciar sesion para gestionar el taller.');
    }
    return user.uid;
  }

  /// Devuelve los datos del taller del usuario autenticado, o `null` si no hay.
  Future<WorkshopData?> getWorkshop() async {
    final String uid = _requireUid;
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _userDoc(uid).get();
    if (!snap.exists || snap.data() == null) return null;

    final Object? raw = snap.data()!['workshop'];
    if (raw is! Map) return null;

    return WorkshopData.fromMap(Map<String, dynamic>.from(raw));
  }

  /// Guarda el objeto `workshop` con merge (no altera role/status ni el resto).
  Future<void> saveWorkshop(WorkshopData data) async {
    final String uid = _requireUid;
    await _userDoc(uid).set(
      <String, dynamic>{
        'workshop': data.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
