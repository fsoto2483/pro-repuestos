import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../services/firestore_service.dart';
import '../db/app_database.dart';
import 'catalog_importer.dart';
import 'catalog_sources.dart';
import 'catalog_tables.dart';
import 'import_report.dart';

/// Carga inicial del catalogo desde los CSV que viajan dentro de la app.
///
/// Solo corre cuando la base esta vacia. Despues de la primera vez manda lo que
/// el usuario haya cargado o editado, no estos archivos.
class CatalogSeeder {
  const CatalogSeeder(this._db, {this.bundle});

  final AppDatabase _db;

  /// Se inyecta en las pruebas para no depender de los archivos empaquetados.
  final AssetBundle? bundle;

  static const String assetFolder = 'assets/data';

  AssetBundle get _assets => bundle ?? rootBundle;

  /// Devuelve el informe si hubo que sembrar, o `null` si ya habia datos.
  Future<ImportReport?> seedIfEmpty() async {
    // Web y modo Firestore: no sembrar desde assets (evita IndexedDB por
    // navegador como fuente de verdad).
    if (kIsWeb) {
      // ignore: avoid_print
      print('[FIRESTORE_MODE] seedIfEmpty omitido en Web');
      return null;
    }

    final CatalogStats stats = await _db.stats();
    // ignore: avoid_print
    print('[BOOT_1] CatalogSeeder.seedIfEmpty '
        'drift.products=${stats.products} isEmpty=${stats.isEmpty}');
    if (!stats.isEmpty) {
      // ignore: avoid_print
      print('[BOOT_1] skip seed — Drift ya tiene productos; '
          'NO se cargan assets/data/*.csv');
      return null;
    }

    // Si Firestore ya tiene catalogo, no rellenar Drift desde CSV.
    try {
      final int remoteCount = await const FirestoreService().countProducts();
      if (remoteCount > 0) {
        // ignore: avoid_print
        print('[FIRESTORE_MODE] seedIfEmpty omitido — '
            'Firestore ya tiene $remoteCount productos');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[FIRESTORE_MODE] no se pudo consultar Firestore para seed: $e');
    }

    // ignore: avoid_print
    print('[BOOT_1] Drift vacio y Firestore vacio → sembrando $assetFolder/*.csv');
    return seed();
  }

  Future<ImportReport> seed() async {
    final Map<CatalogTable, ParsedSheet> sheets =
        <CatalogTable, ParsedSheet>{};

    for (final CatalogTable table in CatalogTable.loadOrder) {
      final String path = '$assetFolder/${table.fileName}';
      final String content;
      try {
        content = await _assets.loadString(path);
      } catch (_) {
        // Un archivo que falta no es un error: la tabla queda vacia y el
        // importador descarta lo que dependiera de ella.
        debugPrint('Catalogo inicial: falta $path');
        continue;
      }
      sheets[table] = CatalogSourceReader.parseCsv(table.fileName, content);
    }

    if (sheets.isEmpty) {
      return ImportReport.failure(
        'No se encontraron los archivos del catalogo inicial en $assetFolder.',
      );
    }

    return CatalogImporter(_db).import(sheets);
  }
}
