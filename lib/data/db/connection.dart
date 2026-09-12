import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Abre la base de datos con la implementacion que corresponda a la
/// plataforma actual.
///
/// - Android y Windows: un archivo `repuestos_pro.sqlite` en la carpeta de
///   documentos de la aplicacion.
/// - Web: IndexedDB o el sistema de archivos del navegador, usando los
///   archivos `web/sqlite3.wasm` y `web/drift_worker.js` que ya vienen en el
///   repositorio.
QueryExecutor openCatalogConnection() {
  return driftDatabase(
    name: 'repuestos_pro',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
