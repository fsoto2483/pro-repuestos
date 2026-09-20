import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/order_status.dart';

/// Operaciones logísticas sobre `sales_orders` (conductor / despacho / entrega).
class DeliveryService {
  const DeliveryService();

  static const String collectionName = 'sales_orders';

  CollectionReference<Map<String, dynamic>> get _orders =>
      FirebaseFirestore.instance.collection(collectionName);

  /// Asigna conductor, teléfono y placa al pedido.
  Future<void> assignDelivery({
    required String orderId,
    required String assignedDriver,
    required String driverPhone,
    required String vehiclePlate,
  }) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    final Map<String, dynamic> payload = <String, dynamic>{
      'assignedDriver': assignedDriver.trim(),
      'driverPhone': driverPhone.trim(),
      'vehiclePlate': vehiclePlate.trim().toUpperCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    debugPrint('DELIVERY ASSIGN order=$orderId data=$payload');
    try {
      await _orders.doc(orderId).update(payload);
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      rethrow;
    }
  }

  /// Marca el pedido en despacho y registra [dispatchedAt].
  Future<void> markDispatched(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    final Map<String, dynamic> payload = <String, dynamic>{
      'status': OrderStatus.dispatched.value,
      'dispatchedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    debugPrint('DELIVERY DISPATCH order=$orderId');
    try {
      await _orders.doc(orderId).update(payload);
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      rethrow;
    }
  }

  /// Marca el pedido como entregado y registra [deliveredAt].
  Future<void> markDelivered(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    final Map<String, dynamic> payload = <String, dynamic>{
      'status': OrderStatus.delivered.value,
      'deliveredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    debugPrint('DELIVERY DELIVERED order=$orderId');
    try {
      await _orders.doc(orderId).update(payload);
    } on FirebaseException catch (e) {
      debugPrint('FIRESTORE CODE: ${e.code}');
      debugPrint('FIRESTORE MESSAGE: ${e.message}');
      rethrow;
    }
  }

  /// Cambia a preparación.
  Future<void> markPreparing(String orderId) async {
    if (orderId.isEmpty) {
      throw ArgumentError('orderId es obligatorio.');
    }
    await _orders.doc(orderId).update(<String, dynamic>{
      'status': OrderStatus.preparing.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
