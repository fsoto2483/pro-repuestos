import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';

import 'core/location/register_geolocator_web_stub.dart'
    if (dart.library.html) 'core/location/register_geolocator_web_web.dart'
    as geolocator_web_bootstrap;
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    geolocator_web_bootstrap.registerGeolocatorForWeb();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('es_CO');

  runApp(const RepuestosProApp());
}
