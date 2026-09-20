import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/quote.dart';
import '../models/sales_order.dart';

/// Persistencia de órdenes de venta en `sales_orders`.
class SalesOrderService {
  const SalesOrderService();

  static const String collectionName = 'sales_orders';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection(collectionName);

  CollectionReference<Map<String, dynamic>> get _quotes =>
      _db.collection('quotes');

  String get _requireUid {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid.isEmpty) {
      throw StateError('Debes iniciar sesion para gestionar pedidos.');
    }
    return user.uid;
  }

  /// Alias de [createOrderFromQuote] (fase logística).
  Future<SalesOrder> createOrder(Quote quote) => createOrderFromQuote(quote);

  /// Crea una OV desde una cotización ganada (idempotente por quoteId).
  Future<SalesOrder> createOrderFromQuote(Quote quote) async {
    if (quote.id.isEmpty) {
      throw ArgumentError('quote.id es obligatorio.');
    }

    final SalesOrder? existing = await findByQuoteId(quote.id);
    if (existing != null) {
      debugPrint('ORDER EXISTS for quote ${quote.id}: ${existing.id}');
      return existing;
    }

    if (quote.orderId.isNotEmpty) {
      final SalesOrder? byRef = await getOrder(quote.orderId);
      if (byRef != null) return byRef;
    }

    final DocumentReference<Map<String, dynamic>> doc = _orders.doc();
    final String orderNumber = _generateOrderNumber();
    final DateTime now = DateTime.now();

    final Map<String, dynamic> data = <String, dynamic>{
      'orderNumber': orderNumber,
      'quoteId': quote.id,
      'quoteNumber': quote.quoteNumber,
      'customerId': quote.userId,
      'customerName': quote.customerName,
      'customerRuc': quote.customerDocument,
      'customerPhone': quote.customerPhone,
      'razonSocial': quote.customerRazonSocial,
      'nombreComercial': quote.customerNombreComercial,
      'ruc': quote.customerDocument,
      'contactName': quote.customerName,
      'phone': quote.customerPhone,
      'email': quote.customerEmail,
      'status': OrderStatus.confirmed.value,
      'trackingNotes': '',
      'assignedTo': '',
      'assignedDriver': '',
      'driverPhone': '',
      'vehiclePlate': '',
      'dispatchedAt': null,
      'deliveredAt': null,
      'subtotal': quote.subtotal,
      'igv': quote.igv,
      'total': quote.total,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': FieldValue.serverTimestamp(),
      'items': quote.items.map((QuoteItem i) => i.toMap()).toList(),
    };

    debugPrint('FIRESTORE CREATE sales_orders/${doc.id}');
    try {
      await doc.set(data);
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      rethrow;
    }

    try {
      await _quotes.doc(quote.id).update(<String, dynamic>{
        'orderId': doc.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      rethrow;
    }

    debugPrint('ORDER CREATED: ${doc.id} from quote ${quote.id}');

    final SalesOrder? saved = await getOrder(doc.id);
    return saved ??
        SalesOrder(
          id: doc.id,
          orderNumber: orderNumber,
          quoteId: quote.id,
          quoteNumber: quote.quoteNumber,
          customerId: quote.userId,
          customerName: quote.customerName,
          customerRuc: quote.customerDocument,
          customerPhone: quote.customerPhone,
          razonSocial: quote.customerRazonSocial,
          nombreComercial: quote.customerNombreComercial,
          email: quote.customerEmail,
          status: OrderStatus.confirmed.value,
          subtotal: quote.subtotal,
          igv: quote.igv,
          total: quote.total,
          createdAt: now,
          updatedAt: now,
          items: quote.items,
        );
  }

  Future<SalesOrder?> getOrder(String orderId) async {
    if (orderId.isEmpty) return null;
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _orders.doc(orderId).get();
    if (!snap.exists || snap.data() == null) return null;
    return SalesOrder.fromMap(snap.id, snap.data()!);
  }

  Future<SalesOrder?> findByQuoteId(String quoteId) async {
    if (quoteId.isEmpty) return null;
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _orders
          .where('quoteId', isEqualTo: quoteId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final QueryDocumentSnapshot<Map<String, dynamic>> doc = snap.docs.first;
      return SalesOrder.fromMap(doc.id, doc.data());
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      rethrow;
    }
  }

  Stream<List<SalesOrder>> getUserOrders([String? userId]) {
    final String uid =
        (userId == null || userId.isEmpty) ? _requireUid : userId;

    return _orders
        .where('customerId', isEqualTo: uid)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<SalesOrder> orders = snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                SalesOrder.fromMap(doc.id, doc.data()),
          )
          .toList()
        ..sort(
          (SalesOrder a, SalesOrder b) => b.createdAt.compareTo(a.createdAt),
        );
      return orders;
    });
  }

  Stream<List<SalesOrder>> getAllOrders() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      return snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                SalesOrder.fromMap(doc.id, doc.data()),
          )
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    final OrderStatus next = OrderStatus.fromString(status);
    final Map<String, dynamic> payload = <String, dynamic>{
      'status': next.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (next == OrderStatus.dispatched) {
      payload['dispatchedAt'] = FieldValue.serverTimestamp();
    }
    if (next == OrderStatus.delivered) {
      payload['deliveredAt'] = FieldValue.serverTimestamp();
    }
    await _orders.doc(orderId).update(payload);
  }

  Future<void> updateTrackingNotes(String orderId, String notes) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    await _orders.doc(orderId).update(<String, dynamic>{
      'trackingNotes': notes.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveOrderFollowUp({
    required String orderId,
    required String status,
    required String trackingNotes,
  }) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    final OrderStatus next = OrderStatus.fromString(status);
    final Map<String, dynamic> payload = <String, dynamic>{
      'status': next.value,
      'trackingNotes': trackingNotes.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (next == OrderStatus.dispatched) {
      payload['dispatchedAt'] = FieldValue.serverTimestamp();
    }
    if (next == OrderStatus.delivered) {
      payload['deliveredAt'] = FieldValue.serverTimestamp();
    }
    await _orders.doc(orderId).update(payload);
  }

  Future<void> deleteOrder(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    _requireUid;
    final DocumentSnapshot<Map<String, dynamic>> existing =
        await _orders.doc(orderId).get();
    if (!existing.exists || existing.data() == null) return;

    final String quoteId = (existing.data()!['quoteId'] ?? '').toString();
    await _orders.doc(orderId).delete();

    if (quoteId.isNotEmpty) {
      try {
        await _quotes.doc(quoteId).update(<String, dynamic>{
          'orderId': '',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('ORDER DELETE: no se pudo limpiar quote.orderId: $e');
      }
    }
  }

  String _generateOrderNumber() {
    final DateTime now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final String date = '${now.year}${two(now.month)}${two(now.day)}';
    final String time =
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final String suffix =
        (now.millisecond % 1000).toString().padLeft(3, '0');
    return 'OV-$date-$time$suffix';
  }
}
