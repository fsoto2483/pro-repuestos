import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'quote_item.dart';

export 'quote_item.dart';

/// Cotización persistida en `quotes/{quoteId}`.
@immutable
class Quote {
  const Quote({
    required this.id,
    required this.quoteNumber,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleEngine,
    required this.status,
    required this.subtotal,
    required this.igv,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.items = const <QuoteItem>[],
  });

  final String id;
  final String quoteNumber;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleYear;
  final String vehicleEngine;
  final String status;
  final double subtotal;
  final double igv;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuoteItem> items;

  int get itemCount => items.length;

  factory Quote.fromMap(String id, Map<String, dynamic> map) {
    final List<QuoteItem> items = <QuoteItem>[];
    final Object? rawItems = map['items'];
    if (rawItems is List) {
      for (final Object? entry in rawItems) {
        if (entry is Map) {
          items.add(QuoteItem.fromMap(Map<String, dynamic>.from(entry)));
        }
      }
    }

    final DateTime now = DateTime.now();
    return Quote(
      id: id,
      quoteNumber: _str(map['quoteNumber']),
      userId: _str(map['userId']),
      customerName: _str(map['customerName']),
      customerPhone: _str(map['customerPhone']),
      customerEmail: _str(map['customerEmail']),
      vehicleBrand: _str(map['vehicleBrand']),
      vehicleModel: _str(map['vehicleModel']),
      vehicleYear: _str(map['vehicleYear']),
      vehicleEngine: _str(map['vehicleEngine']),
      status: _str(map['status']).isEmpty ? 'saved' : _str(map['status']),
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
      'quoteNumber': quoteNumber.trim(),
      'userId': userId.trim(),
      'customerName': customerName.trim(),
      'customerPhone': customerPhone.trim(),
      'customerEmail': customerEmail.trim().toLowerCase(),
      'vehicleBrand': vehicleBrand.trim(),
      'vehicleModel': vehicleModel.trim(),
      'vehicleYear': vehicleYear.trim(),
      'vehicleEngine': vehicleEngine.trim(),
      'status': status.trim().isEmpty ? 'saved' : status.trim(),
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

  Quote copyWith({
    String? id,
    String? quoteNumber,
    String? userId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleYear,
    String? vehicleEngine,
    String? status,
    double? subtotal,
    double? igv,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<QuoteItem>? items,
  }) {
    return Quote(
      id: id ?? this.id,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleEngine: vehicleEngine ?? this.vehicleEngine,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      igv: igv ?? this.igv,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
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
