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
    this.customerDocument = '',
    this.customerWhatsapp = '',
    this.customerAddress = '',
    this.customerDepartamento = '',
    this.customerProvincia = '',
    this.customerDistrito = '',
    this.customerReferencia = '',
    this.customerRazonSocial = '',
    this.customerNombreComercial = '',
    this.items = const <QuoteItem>[],
  });

  final String id;
  final String quoteNumber;
  final String userId;

  /// Datos del cliente (comprador). Nunca confundir con el usuario Auth / taller.
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String customerDocument;
  final String customerWhatsapp;
  final String customerAddress;
  final String customerDepartamento;
  final String customerProvincia;
  final String customerDistrito;
  final String customerReferencia;
  final String customerRazonSocial;
  final String customerNombreComercial;

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

  /// Mapa de cliente para logs / PDF (equivalente a `quote.customer`).
  Map<String, String> get customer => <String, String>{
        'razonSocial': customerRazonSocial,
        'nombreComercial': customerNombreComercial,
        'ruc': customerDocument,
        'contacto': customerName,
        'telefono': customerPhone,
        'correo': customerEmail,
      };

  bool get hasCustomerData =>
      customerRazonSocial.isNotEmpty ||
      customerNombreComercial.isNotEmpty ||
      customerDocument.isNotEmpty ||
      customerName.isNotEmpty ||
      customerPhone.isNotEmpty ||
      customerEmail.isNotEmpty ||
      customerWhatsapp.isNotEmpty ||
      customerAddress.isNotEmpty ||
      customerDepartamento.isNotEmpty ||
      customerProvincia.isNotEmpty ||
      customerDistrito.isNotEmpty ||
      customerReferencia.isNotEmpty;

  /// Filas para PDF (orden fijo). Solo valores no vacíos.
  List<MapEntry<String, String>> get customerDisplayRows {
    final List<MapEntry<String, String>> rows = <MapEntry<String, String>>[];
    void add(String label, String value) {
      final String v = value.trim();
      if (v.isNotEmpty) rows.add(MapEntry<String, String>(label, v));
    }

    add('Razon Social', customerRazonSocial);
    add('Nombre Comercial', customerNombreComercial);
    add('RUC', customerDocument);
    add('Contacto', customerName);
    add('Telefono', customerPhone);
    add('Correo', customerEmail);
    return rows;
  }

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

    final Map<String, dynamic> customer = _customerMap(map);

    final DateTime now = DateTime.now();
    return Quote(
      id: id,
      quoteNumber: _str(map['quoteNumber']),
      userId: _str(map['userId']),
      customerDocument: _str(
        customer['ruc'] ??
            customer['document'] ??
            customer['documento'] ??
            map['customerDocument'] ??
            map['customerRuc'],
      ),
      customerWhatsapp: _str(
        customer['whatsapp'] ?? map['customerWhatsapp'],
      ),
      customerAddress: _str(
        customer['address'] ??
            customer['direccion'] ??
            map['customerAddress'],
      ),
      customerDepartamento: _str(
        customer['departamento'] ?? map['customerDepartamento'],
      ),
      customerProvincia: _str(
        customer['provincia'] ?? map['customerProvincia'],
      ),
      customerDistrito: _str(
        customer['distrito'] ?? map['customerDistrito'],
      ),
      customerReferencia: _str(
        customer['referencia'] ?? map['customerReferencia'],
      ),
      customerRazonSocial: _str(
        customer['razonSocial'] ?? map['customerRazonSocial'],
      ),
      customerNombreComercial: _str(
        customer['nombreComercial'] ?? map['customerNombreComercial'],
      ),
      customerName: _str(
        customer['contacto'] ??
            customer['name'] ??
            customer['nombre'] ??
            map['customerName'],
      ),
      customerPhone: _str(
        customer['telefono'] ?? customer['phone'] ?? map['customerPhone'],
      ),
      customerEmail: _str(
        customer['correo'] ?? customer['email'] ?? map['customerEmail'],
      ),
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
      'customerDocument': customerDocument.trim(),
      'customerWhatsapp': customerWhatsapp.trim(),
      'customerAddress': customerAddress.trim(),
      'customerDepartamento': customerDepartamento.trim(),
      'customerProvincia': customerProvincia.trim(),
      'customerDistrito': customerDistrito.trim(),
      'customerReferencia': customerReferencia.trim(),
      'customerRazonSocial': customerRazonSocial.trim(),
      'customerNombreComercial': customerNombreComercial.trim(),
      'customer': <String, dynamic>{
        'razonSocial': customerRazonSocial.trim(),
        'nombreComercial': customerNombreComercial.trim(),
        'ruc': customerDocument.trim(),
        'contacto': customerName.trim(),
        'telefono': customerPhone.trim(),
        'correo': customerEmail.trim().toLowerCase(),
      },
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
    String? customerDocument,
    String? customerWhatsapp,
    String? customerAddress,
    String? customerDepartamento,
    String? customerProvincia,
    String? customerDistrito,
    String? customerReferencia,
    String? customerRazonSocial,
    String? customerNombreComercial,
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
      customerDocument: customerDocument ?? this.customerDocument,
      customerWhatsapp: customerWhatsapp ?? this.customerWhatsapp,
      customerAddress: customerAddress ?? this.customerAddress,
      customerDepartamento: customerDepartamento ?? this.customerDepartamento,
      customerProvincia: customerProvincia ?? this.customerProvincia,
      customerDistrito: customerDistrito ?? this.customerDistrito,
      customerReferencia: customerReferencia ?? this.customerReferencia,
      customerRazonSocial: customerRazonSocial ?? this.customerRazonSocial,
      customerNombreComercial:
          customerNombreComercial ?? this.customerNombreComercial,
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

  static Map<String, dynamic> _customerMap(Map<String, dynamic> map) {
    final Object? raw = map['customer'];
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return const <String, dynamic>{};
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
