import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'delivery.dart';
import 'order_status.dart';
import 'quote_item.dart';

export 'delivery.dart';
export 'order_status.dart';
export 'quote_item.dart';

/// Orden de venta persistida en `sales_orders/{orderId}`.
@immutable
class SalesOrder {
  const SalesOrder({
    required this.id,
    required this.orderNumber,
    required this.quoteId,
    required this.customerId,
    required this.customerName,
    required this.customerRuc,
    required this.customerPhone,
    required this.status,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.quoteNumber = '',
    this.razonSocial = '',
    this.nombreComercial = '',
    this.email = '',
    this.trackingNotes = '',
    this.assignedTo = '',
    this.assignedDriver = '',
    this.driverPhone = '',
    this.vehiclePlate = '',
    this.dispatchedAt,
    this.deliveredAt,
    this.items = const <QuoteItem>[],
  });

  final String id;
  final String orderNumber;
  final String quoteId;
  final String quoteNumber;
  final String customerId;

  /// Nombre de contacto / cliente.
  final String customerName;
  final String customerRuc;
  final String customerPhone;

  /// Compatibilidad con pedidos existentes.
  final String razonSocial;
  final String nombreComercial;
  final String email;

  final List<QuoteItem> items;
  final double subtotal;
  final double igv;
  final double total;

  final String status;
  final String trackingNotes;
  final String assignedTo;

  final String assignedDriver;
  final String driverPhone;
  final String vehiclePlate;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  OrderStatus get statusEnum => OrderStatus.fromString(status);

  Delivery get delivery => Delivery(
        assignedDriver: assignedDriver,
        driverPhone: driverPhone,
        vehiclePlate: vehiclePlate,
        dispatchedAt: dispatchedAt,
        deliveredAt: deliveredAt,
      );

  /// Razón social preferida para listados (legacy + nuevo).
  String get displayRazonSocial =>
      razonSocial.trim().isNotEmpty ? razonSocial : customerName;

  String get displayRuc =>
      customerRuc.trim().isNotEmpty ? customerRuc : '';

  String get ruc => customerRuc;
  String get contactName => customerName;
  String get phone => customerPhone;

  factory SalesOrder.fromMap(String id, Map<String, dynamic> map) {
    final List<QuoteItem> items = <QuoteItem>[];
    final Object? rawItems = map['items'];
    if (rawItems is List) {
      for (final Object? entry in rawItems) {
        if (entry is Map) {
          items.add(QuoteItem.fromMap(Map<String, dynamic>.from(entry)));
        }
      }
    }

    final String contact = _str(
      map['customerName'] ?? map['contactName'],
    );
    final String ruc = _str(map['customerRuc'] ?? map['ruc']);
    final String phone = _str(map['customerPhone'] ?? map['phone']);
    final String razon = _str(map['razonSocial']);

    final DateTime now = DateTime.now();
    return SalesOrder(
      id: id,
      orderNumber: _str(map['orderNumber']),
      quoteId: _str(map['quoteId']),
      quoteNumber: _str(map['quoteNumber']),
      customerId: _str(map['customerId']),
      customerName: contact,
      customerRuc: ruc,
      customerPhone: phone,
      razonSocial: razon.isNotEmpty ? razon : contact,
      nombreComercial: _str(map['nombreComercial']),
      email: _str(map['email']),
      status: OrderStatus.fromString(_str(map['status'])).value,
      trackingNotes: _str(map['trackingNotes']),
      assignedTo: _str(map['assignedTo']),
      assignedDriver: _str(map['assignedDriver']),
      driverPhone: _str(map['driverPhone']),
      vehiclePlate: _str(map['vehiclePlate']),
      dispatchedAt: _date(map['dispatchedAt']),
      deliveredAt: _date(map['deliveredAt']),
      subtotal: _double(map['subtotal']),
      igv: _double(map['igv']),
      total: _double(map['total']),
      createdAt: _date(map['createdAt']) ?? now,
      updatedAt: _date(map['updatedAt']) ?? now,
      items: items,
    );
  }

  Map<String, dynamic> toMap({bool useServerTimestamps = false}) {
    return <String, dynamic>{
      'orderNumber': orderNumber.trim(),
      'quoteId': quoteId.trim(),
      'quoteNumber': quoteNumber.trim(),
      'customerId': customerId.trim(),
      'customerName': customerName.trim(),
      'customerRuc': customerRuc.trim(),
      'customerPhone': customerPhone.trim(),
      // Compatibilidad con documentos legacy.
      'razonSocial':
          (razonSocial.trim().isNotEmpty ? razonSocial : customerName).trim(),
      'nombreComercial': nombreComercial.trim(),
      'ruc': customerRuc.trim(),
      'contactName': customerName.trim(),
      'phone': customerPhone.trim(),
      'email': email.trim().toLowerCase(),
      'status': status.trim().isEmpty
          ? OrderStatus.pending.value
          : status.trim(),
      'trackingNotes': trackingNotes.trim(),
      'assignedTo': assignedTo.trim(),
      'assignedDriver': assignedDriver.trim(),
      'driverPhone': driverPhone.trim(),
      'vehiclePlate': vehiclePlate.trim().toUpperCase(),
      'dispatchedAt': dispatchedAt == null
          ? null
          : Timestamp.fromDate(dispatchedAt!),
      'deliveredAt':
          deliveredAt == null ? null : Timestamp.fromDate(deliveredAt!),
      'subtotal': subtotal,
      'igv': igv,
      'total': total,
      'createdAt': useServerTimestamps
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt),
      'updatedAt': useServerTimestamps
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updatedAt),
      'items': items.map((QuoteItem i) => i.toMap()).toList(),
    };
  }

  static String _str(Object? value) =>
      (value is String ? value : value?.toString() ?? '').trim();

  static double _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
