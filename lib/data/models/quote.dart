import 'package:flutter/foundation.dart';

@immutable
class QuoteItem {
  const QuoteItem({
    required this.id,
    required this.productId,
    required this.sku,
    required this.oem,
    required this.productName,
    required this.brandName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  final String id;
  final String productId;
  final String sku;
  final String oem;
  final String productName;
  final String brandName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
}

@immutable
class Quote {
  const Quote({
    required this.id,
    required this.userId,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.companyName,
    required this.notes,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.itemCount,
    required this.unitCount,
    required this.createdAt,
    this.items = const <QuoteItem>[],
  });

  final String id;
  final String userId;
  final String status;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String companyName;
  final String notes;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final int itemCount;
  final int unitCount;
  final DateTime createdAt;
  final List<QuoteItem> items;

  Quote copyWith({List<QuoteItem>? items}) => Quote(
    id: id,
    userId: userId,
    status: status,
    customerName: customerName,
    customerPhone: customerPhone,
    customerEmail: customerEmail,
    companyName: companyName,
    notes: notes,
    subtotal: subtotal,
    taxRate: taxRate,
    taxAmount: taxAmount,
    total: total,
    itemCount: itemCount,
    unitCount: unitCount,
    createdAt: createdAt,
    items: items ?? this.items,
  );
}

/// Datos del cliente capturados en el checkout.
@immutable
class QuoteCustomerInput {
  const QuoteCustomerInput({
    required this.name,
    required this.phone,
    required this.email,
    required this.companyName,
    this.notes = '',
  });

  final String name;
  final String phone;
  final String email;
  final String companyName;
  final String notes;
}
