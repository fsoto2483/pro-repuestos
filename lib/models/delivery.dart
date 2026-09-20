import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Datos logísticos de despacho embebidos en `sales_orders`.
@immutable
class Delivery {
  const Delivery({
    this.assignedDriver = '',
    this.driverPhone = '',
    this.vehiclePlate = '',
    this.dispatchedAt,
    this.deliveredAt,
  });

  final String assignedDriver;
  final String driverPhone;
  final String vehiclePlate;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;

  bool get hasDriver => assignedDriver.trim().isNotEmpty;

  factory Delivery.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return const Delivery();
    return Delivery(
      assignedDriver: _str(map['assignedDriver']),
      driverPhone: _str(map['driverPhone']),
      vehiclePlate: _str(map['vehiclePlate']),
      dispatchedAt: _date(map['dispatchedAt']),
      deliveredAt: _date(map['deliveredAt']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'assignedDriver': assignedDriver.trim(),
        'driverPhone': driverPhone.trim(),
        'vehiclePlate': vehiclePlate.trim().toUpperCase(),
        'dispatchedAt':
            dispatchedAt == null ? null : Timestamp.fromDate(dispatchedAt!),
        'deliveredAt':
            deliveredAt == null ? null : Timestamp.fromDate(deliveredAt!),
      };

  Delivery copyWith({
    String? assignedDriver,
    String? driverPhone,
    String? vehiclePlate,
    DateTime? dispatchedAt,
    DateTime? deliveredAt,
    bool clearDispatchedAt = false,
    bool clearDeliveredAt = false,
  }) {
    return Delivery(
      assignedDriver: assignedDriver ?? this.assignedDriver,
      driverPhone: driverPhone ?? this.driverPhone,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      dispatchedAt:
          clearDispatchedAt ? null : (dispatchedAt ?? this.dispatchedAt),
      deliveredAt: clearDeliveredAt ? null : (deliveredAt ?? this.deliveredAt),
    );
  }

  static String _str(Object? value) =>
      (value is String ? value : value?.toString() ?? '').trim();

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
