import 'package:flutter/foundation.dart';

/// Línea de producto dentro de una cotización (`quotes/{id}.items[]`).
@immutable
class QuoteItem {
  const QuoteItem({
    required this.productId,
    required this.codigo,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.total,
  });

  final String productId;
  final String codigo;
  final String descripcion;
  final int cantidad;
  final double precioUnitario;
  final double total;

  factory QuoteItem.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const QuoteItem(
        productId: '',
        codigo: '',
        descripcion: '',
        cantidad: 0,
        precioUnitario: 0,
        total: 0,
      );
    }
    return QuoteItem(
      productId: _str(map['productId']),
      codigo: _str(map['codigo']),
      descripcion: _str(map['descripcion']),
      cantidad: _int(map['cantidad']),
      precioUnitario: _double(map['precioUnitario']),
      total: _double(map['total']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'productId': productId.trim(),
        'codigo': codigo.trim(),
        'descripcion': descripcion.trim(),
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
        'total': total,
      };

  static String _str(Object? value) =>
      (value is String ? value : value?.toString() ?? '').trim();

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
