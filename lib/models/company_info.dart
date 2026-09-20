import 'package:flutter/foundation.dart';

/// Datos fijos de la empresa vendedora (REPUESTOS LCC).
///
/// El encabezado del PDF siempre usa esta fuente.
/// Nunca Auth, nunca `users/{uid}.workshop`, nunca el cliente.
@immutable
class CompanyInfo {
  const CompanyInfo({
    required this.nombreComercial,
    required this.razonSocial,
    required this.ruc,
    required this.telefono,
    required this.whatsapp,
    required this.correo,
    this.direccion = '',
  });

  final String nombreComercial;
  final String razonSocial;
  final String ruc;
  final String telefono;
  final String whatsapp;
  final String correo;
  final String direccion;

  /// Única instancia de la empresa vendedora en cotizaciones PDF.
  static const CompanyInfo lcc = CompanyInfo(
    nombreComercial: 'REPUESTOS LCC',
    razonSocial: 'La Casa de la Camioneta SAC',
    ruc: '20603365641',
    telefono: '928300562',
    whatsapp: '928300562',
    correo: 'fsoto2483@gmail.com',
  );
}
