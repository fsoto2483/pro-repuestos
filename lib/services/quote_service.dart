import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/quote.dart';
import 'sales_order_service.dart';

/// Persistencia de cotizaciones en la colección `quotes`.
class QuoteService {
  const QuoteService();

  static const String collectionName = 'quotes';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _quotes =>
      _db.collection(collectionName);

  String get _requireUid {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw StateError('Debes iniciar sesion para gestionar cotizaciones.');
    }
    return user.uid;
  }

  /// Crea una cotización en `quotes/{quoteId}` con `quoteNumber` automático.
  Future<Quote> createQuote({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required List<QuoteItem> items,
    required double subtotal,
    required double igv,
    required double total,
    String customerRazonSocial = '',
    String customerNombreComercial = '',
    String customerRuc = '',
    String vehicleBrand = '',
    String vehicleModel = '',
    String vehicleYear = '',
    String vehicleEngine = '',
    String status = 'pending',
  }) async {
    if (items.isEmpty) {
      throw StateError('No se puede guardar una cotizacion vacia.');
    }

    final String uid = _requireUid;
    final DocumentReference<Map<String, dynamic>> doc = _quotes.doc();
    final String quoteNumber = _generateQuoteNumber();
    final DateTime now = DateTime.now();

    final String razon = customerRazonSocial.trim();
    final String comercial = customerNombreComercial.trim();
    final String ruc = customerRuc.trim();
    final String contacto = customerName.trim();
    final String telefono = customerPhone.trim();
    final String correo = customerEmail.trim().toLowerCase();
    final String crmStatus = QuoteStatus.fromString(status).value;

    final Map<String, dynamic> customer = <String, dynamic>{
      'razonSocial': razon,
      'nombreComercial': comercial,
      'ruc': ruc,
      'contacto': contacto,
      'telefono': telefono,
      'correo': correo,
    };

    final Map<String, dynamic> data = <String, dynamic>{
      'quoteNumber': quoteNumber,
      'userId': uid,
      'customer': customer,
      'customerName': contacto,
      'customerPhone': telefono,
      'customerEmail': correo,
      'customerDocument': ruc,
      'customerRazonSocial': razon,
      'customerNombreComercial': comercial,
      'vehicleBrand': vehicleBrand.trim(),
      'vehicleModel': vehicleModel.trim(),
      'vehicleYear': vehicleYear.trim(),
      'vehicleEngine': vehicleEngine.trim(),
      'status': crmStatus,
      'notes': '',
      'assignedTo': '',
      'orderId': '',
      'lastContactAt': null,
      'subtotal': subtotal,
      'igv': igv,
      'total': total,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
      'items': items.map((QuoteItem i) => i.toMap()).toList(),
    };

    await doc.set(data);
    debugPrint('QUOTE SAVED: ${doc.id}');
    debugPrint('CLIENTE GUARDADO: $customer');

    final Quote? saved = await getQuote(doc.id);
    return saved ??
        Quote(
          id: doc.id,
          quoteNumber: quoteNumber,
          userId: uid,
          customerName: contacto,
          customerPhone: telefono,
          customerEmail: correo,
          customerDocument: ruc,
          customerRazonSocial: razon,
          customerNombreComercial: comercial,
          vehicleBrand: vehicleBrand.trim(),
          vehicleModel: vehicleModel.trim(),
          vehicleYear: vehicleYear.trim(),
          vehicleEngine: vehicleEngine.trim(),
          status: crmStatus,
          notes: '',
          assignedTo: '',
          subtotal: subtotal,
          igv: igv,
          total: total,
          createdAt: now,
          updatedAt: now,
          items: items,
        );
  }

  Future<Quote> updateQuote(Quote quote) async {
    if (quote.id.isEmpty) {
      throw ArgumentError('quote.id es obligatorio para actualizar.');
    }

    final String uid = _requireUid;
    final DocumentSnapshot<Map<String, dynamic>> existing =
        await _quotes.doc(quote.id).get();
    if (!existing.exists || existing.data() == null) {
      throw StateError('La cotizacion no existe.');
    }

    final String ownerId = (existing.data()!['userId'] ?? '').toString();
    if (ownerId != uid) {
      throw StateError('No puedes actualizar cotizaciones de otro usuario.');
    }

    final Map<String, dynamic> data = quote.toMap(useServerTimestamps: false);
    data['userId'] = ownerId;
    data['quoteNumber'] =
        existing.data()!['quoteNumber'] ?? quote.quoteNumber;
    data['createdAt'] = existing.data()!['createdAt'] ??
        Timestamp.fromDate(quote.createdAt);
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _quotes.doc(quote.id).update(data);

    final Quote? saved = await getQuote(quote.id);
    if (saved == null) {
      throw StateError('La cotizacion se actualizo pero no se pudo releer.');
    }
    return saved;
  }

  Future<void> deleteQuote(String quoteId) async {
    if (quoteId.isEmpty) {
      throw ArgumentError('quoteId es obligatorio.');
    }
    final String uid = _requireUid;
    final DocumentSnapshot<Map<String, dynamic>> existing =
        await _quotes.doc(quoteId).get();
    if (!existing.exists || existing.data() == null) {
      return;
    }
    final String ownerId = (existing.data()!['userId'] ?? '').toString();
    if (ownerId != uid) {
      throw StateError('No puedes eliminar cotizaciones de otro usuario.');
    }
    await _quotes.doc(quoteId).delete();
  }

  Future<Quote?> getQuote(String quoteId) async {
    if (quoteId.isEmpty) return null;
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _quotes.doc(quoteId).get();
    if (!snap.exists || snap.data() == null) return null;
    return Quote.fromMap(snap.id, snap.data()!);
  }

  /// Lee desde `FirebaseFirestore.instance.collection('quotes')`.
  Future<List<Quote>> getUserQuotes([String? userId]) async {
    final String uid =
        (userId == null || userId.isEmpty) ? _requireUid : userId;

    final QuerySnapshot<Map<String, dynamic>> snap = await _db
        .collection(collectionName)
        .where('userId', isEqualTo: uid)
        .get();

    final List<Quote> quotes = snap.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Quote.fromMap(doc.id, doc.data()),
        )
        .toList()
      ..sort((Quote a, Quote b) => b.createdAt.compareTo(a.createdAt));

    debugPrint('QUOTE LOADED: ${quotes.length}');
    return quotes;
  }

  /// Stream en tiempo real desde `quotes` filtrado por `userId`.
  Stream<List<Quote>> watchUserQuotes([String? userId]) {
    final String uid =
        (userId == null || userId.isEmpty) ? _requireUid : userId;

    return _db
        .collection(collectionName)
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<Quote> quotes = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                Quote.fromMap(doc.id, doc.data()),
          )
          .toList()
        ..sort((Quote a, Quote b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('QUOTE LOADED: ${quotes.length}');
      return quotes;
    });
  }

  /// Stream de todas las cotizaciones (admin). Orden: createdAt DESC.
  Stream<List<Quote>> getAllQuotes() {
    return _quotes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<Quote> quotes = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                Quote.fromMap(doc.id, doc.data()),
          )
          .toList();
      debugPrint('QUOTE ALL LOADED: ${quotes.length}');
      return quotes;
    });
  }

  Future<void> updateQuoteStatus(String quoteId, String status) async {
    if (quoteId.isEmpty) {
      throw ArgumentError('quoteId es obligatorio.');
    }
    final String crmStatus = QuoteStatus.fromString(status).value;
    final Map<String, dynamic> payload = <String, dynamic>{
      'status': crmStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _runQuoteUpdate(
      quoteId: quoteId,
      payload: payload,
      op: 'updateQuoteStatus',
      statusBefore: null,
      statusAfter: crmStatus,
    );
    await _maybeCreateOrderFromWon(quoteId, crmStatus);
  }

  Future<void> updateQuoteNotes(String quoteId, String notes) async {
    if (quoteId.isEmpty) {
      throw ArgumentError('quoteId es obligatorio.');
    }
    final Map<String, dynamic> payload = <String, dynamic>{
      'notes': notes.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _runQuoteUpdate(
      quoteId: quoteId,
      payload: payload,
      op: 'updateQuoteNotes',
      statusBefore: null,
      statusAfter: null,
    );
  }

  Future<void> updateLastContact(String quoteId) async {
    if (quoteId.isEmpty) {
      throw ArgumentError('quoteId es obligatorio.');
    }
    final Map<String, dynamic> payload = <String, dynamic>{
      'lastContactAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _runQuoteUpdate(
      quoteId: quoteId,
      payload: payload,
      op: 'updateLastContact',
      statusBefore: null,
      statusAfter: null,
    );
  }

  /// Guarda seguimiento CRM (estado + notas + lastContactAt) en una escritura.
  Future<void> saveQuoteFollowUp({
    required String quoteId,
    required String status,
    required String notes,
  }) async {
    if (quoteId.isEmpty) {
      throw ArgumentError('quoteId es obligatorio.');
    }
    final String crmStatus = QuoteStatus.fromString(status).value;
    final Quote? before = await getQuote(quoteId);
    final Map<String, dynamic> payload = <String, dynamic>{
      'status': crmStatus,
      'notes': notes.trim(),
      'lastContactAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _runQuoteUpdate(
      quoteId: quoteId,
      payload: payload,
      op: 'saveQuoteFollowUp',
      statusBefore: before?.status,
      statusAfter: crmStatus,
    );
    await _maybeCreateOrderFromWon(quoteId, crmStatus);
  }

  Future<void> _runQuoteUpdate({
    required String quoteId,
    required Map<String, dynamic> payload,
    required String op,
    required String? statusBefore,
    required String? statusAfter,
  }) async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    debugPrint('AUTH UID: ${authUser?.uid}');
    bool isAdmin = false;
    try {
      if (authUser != null) {
        final DocumentSnapshot<Map<String, dynamic>> userSnap =
            await _db.collection('users').doc(authUser.uid).get();
        final Object? role = userSnap.data()?['role'];
        isAdmin = role == 'admin';
        debugPrint('USER ROLE DOC: $role');
      }
    } catch (e) {
      debugPrint('USER ROLE LOOKUP ERROR: $e');
    }
    debugPrint('IS ADMIN: $isAdmin');
    if (statusBefore != null) {
      debugPrint('QUOTE STATUS BEFORE: $statusBefore');
    }
    if (statusAfter != null) {
      debugPrint('QUOTE STATUS AFTER: $statusAfter');
    }
    debugPrint('FIRESTORE UPDATE START op=$op');
    debugPrint('DOCUMENT: quotes/$quoteId');
    debugPrint('DATA: $payload');
    try {
      await _quotes.doc(quoteId).update(payload);
      debugPrint('FIRESTORE UPDATE OK op=$op quotes/$quoteId');
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      debugPrint('FIRESTORE OP FAILED: $op quotes/$quoteId');
      rethrow;
    }
  }

  /// Si la cotización pasa a Venta Cerrada, genera el pedido (una sola vez).
  Future<void> _maybeCreateOrderFromWon(
    String quoteId,
    String crmStatus,
  ) async {
    if (QuoteStatus.fromString(crmStatus) != QuoteStatus.won) return;
    debugPrint('ORDER AUTO-CREATE START quoteId=$quoteId');
    try {
      final Quote? quote = await getQuote(quoteId);
      if (quote == null) {
        debugPrint('ORDER AUTO-CREATE SKIP: quote not found');
        return;
      }
      await const SalesOrderService().createOrderFromQuote(quote);
      debugPrint('ORDER AUTO-CREATE OK quoteId=$quoteId');
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      debugPrint('FIRESTORE OP FAILED: createOrderFromQuote quoteId=$quoteId');
      debugPrint('ORDER AUTO-CREATE ERROR: $e');
      rethrow;
    } catch (e, s) {
      debugPrint('ORDER AUTO-CREATE ERROR: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  String _generateQuoteNumber() {
    final DateTime now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final String date = '${now.year}${two(now.month)}${two(now.day)}';
    final String time =
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final String suffix =
        (now.millisecond % 1000).toString().padLeft(3, '0');
    return 'COT-$date-$time$suffix';
  }
}
