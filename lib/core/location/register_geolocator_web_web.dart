import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:geolocator_web/geolocator_web.dart';

/// Registra la implementacion web de geolocator antes de runApp.
void registerGeolocatorForWeb() {
  GeolocatorPlugin.registerWith(webPluginRegistrar);
}
