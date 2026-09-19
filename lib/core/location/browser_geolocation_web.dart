// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Fallback nativo del navegador cuando Geolocator falla en Web.
Future<({double latitude, double longitude})> getBrowserCurrentPosition() async {
  final html.Geolocation geolocation = html.window.navigator.geolocation;

  final html.Geoposition position = await geolocation.getCurrentPosition(
    enableHighAccuracy: true,
  );

  final num? lat = position.coords?.latitude;
  final num? lng = position.coords?.longitude;
  if (lat == null || lng == null) {
    throw StateError('El navegador no devolvio coordenadas validas.');
  }

  return (latitude: lat.toDouble(), longitude: lng.toDouble());
}
