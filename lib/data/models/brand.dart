import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Marca de repuesto en la coleccion Firestore `brands`.
@immutable
class Brand {
  const Brand({
    required this.id,
    required this.name,
    this.logoUrl,
    this.createdAt,
  });

  factory Brand.fromMap(String id, Map<String, dynamic> data) {
    return Brand(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      logoUrl: data['logoUrl'] as String?,
      createdAt: _readTimestamp(data['createdAt']),
    );
  }

  final String id;
  final String name;
  final String? logoUrl;
  final DateTime? createdAt;

  Map<String, dynamic> toMap({bool includeServerTimestamp = true}) {
    return <String, dynamic>{
      'name': name,
      'logoUrl': logoUrl,
      if (includeServerTimestamp && createdAt == null)
        'createdAt': FieldValue.serverTimestamp()
      else if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  Brand copyWith({
    String? id,
    String? name,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Brand && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

DateTime? _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
