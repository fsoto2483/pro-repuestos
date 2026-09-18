import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Categoria de catalogo en la coleccion Firestore `categories`.
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    this.description = '',
    this.sortOrder = 0,
    this.createdAt,
  });

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: _readTimestamp(data['createdAt']),
    );
  }

  final String id;
  final String name;
  final String description;
  final int sortOrder;
  final DateTime? createdAt;

  Map<String, dynamic> toMap({bool includeServerTimestamp = true}) {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'sortOrder': sortOrder,
      if (includeServerTimestamp && createdAt == null)
        'createdAt': FieldValue.serverTimestamp()
      else if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Category && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

DateTime? _readTimestamp(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
