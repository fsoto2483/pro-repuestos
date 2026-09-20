import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Datos del taller/empresa asociados a `users/{uid}.workshop`.
@immutable
class WorkshopData {
  const WorkshopData({
    this.razonSocial = '',
    this.nombreComercial = '',
    this.ruc = '',
    this.propietario = '',
    this.telefono = '',
    this.whatsapp = '',
    this.correo = '',
    this.direccion = '',
    this.referencia = '',
    this.departamento = '',
    this.provincia = '',
    this.distrito = '',
    this.lat,
    this.lng,
    this.updatedAt,
  });

  final String razonSocial;
  final String nombreComercial;
  final String ruc;
  final String propietario;
  final String telefono;
  final String whatsapp;
  final String correo;
  final String direccion;
  final String referencia;
  final String departamento;
  final String provincia;
  final String distrito;
  final double? lat;
  final double? lng;
  final DateTime? updatedAt;

  factory WorkshopData.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const WorkshopData();
    }
    return WorkshopData(
      razonSocial: _str(map['razonSocial']),
      nombreComercial: _str(map['nombreComercial']),
      ruc: _str(map['ruc']),
      propietario: _str(map['propietario']),
      telefono: _str(map['telefono']),
      whatsapp: _str(map['whatsapp']),
      correo: _str(map['correo']),
      direccion: _str(map['direccion']),
      referencia: _str(map['referencia']),
      departamento: _str(map['departamento']),
      provincia: _str(map['provincia']),
      distrito: _str(map['distrito']),
      lat: _num(map['lat']),
      lng: _num(map['lng']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool includeServerTimestamp = true}) {
    return <String, dynamic>{
      'razonSocial': razonSocial.trim(),
      'nombreComercial': nombreComercial.trim(),
      'ruc': ruc.trim(),
      'propietario': propietario.trim(),
      'telefono': telefono.trim(),
      'whatsapp': whatsapp.trim(),
      'correo': correo.trim(),
      'direccion': direccion.trim(),
      'referencia': referencia.trim(),
      'departamento': departamento.trim(),
      'provincia': provincia.trim(),
      'distrito': distrito.trim(),
      'lat': lat,
      'lng': lng,
      'updatedAt': includeServerTimestamp
          ? FieldValue.serverTimestamp()
          : (updatedAt != null
                ? Timestamp.fromDate(updatedAt!)
                : FieldValue.serverTimestamp()),
    };
  }

  @override
  String toString() =>
      'WorkshopData(razonSocial: $razonSocial, nombreComercial: $nombreComercial, '
      'ruc: $ruc, telefono: $telefono, whatsapp: $whatsapp, correo: $correo, '
      'direccion: $direccion)';

  WorkshopData copyWith({
    String? razonSocial,
    String? nombreComercial,
    String? ruc,
    String? propietario,
    String? telefono,
    String? whatsapp,
    String? correo,
    String? direccion,
    String? referencia,
    String? departamento,
    String? provincia,
    String? distrito,
    double? lat,
    double? lng,
    DateTime? updatedAt,
    bool clearLatLng = false,
  }) {
    return WorkshopData(
      razonSocial: razonSocial ?? this.razonSocial,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      ruc: ruc ?? this.ruc,
      propietario: propietario ?? this.propietario,
      telefono: telefono ?? this.telefono,
      whatsapp: whatsapp ?? this.whatsapp,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
      referencia: referencia ?? this.referencia,
      departamento: departamento ?? this.departamento,
      provincia: provincia ?? this.provincia,
      distrito: distrito ?? this.distrito,
      lat: clearLatLng ? null : (lat ?? this.lat),
      lng: clearLatLng ? null : (lng ?? this.lng),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _str(Object? value) =>
      (value is String ? value : value?.toString() ?? '').trim();

  static double? _num(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
