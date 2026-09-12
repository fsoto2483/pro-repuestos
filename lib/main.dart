import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Necesario para que los formatos de moneda y fecha en espanol funcionen.
  await initializeDateFormatting('es_CO');

  runApp(const RepuestosProApp());
}
