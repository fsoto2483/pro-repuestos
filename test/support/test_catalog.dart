import 'dart:io';

import 'package:drift/native.dart';
import 'package:repuestos_pro/data/db/app_database.dart';
import 'package:repuestos_pro/data/import/catalog_importer.dart';
import 'package:repuestos_pro/data/import/catalog_sources.dart';
import 'package:repuestos_pro/data/import/catalog_tables.dart';
import 'package:repuestos_pro/data/repositories/catalog_repository.dart';

/// Base en memoria con el mismo catalogo que trae la aplicacion.
///
/// Se leen los CSV del disco en vez de `rootBundle` para que las pruebas no
/// dependan de como se empaquetan los recursos.
Future<CatalogRepository> testCatalogRepository() async {
  final AppDatabase db = AppDatabase.forTesting(NativeDatabase.memory());

  final Map<CatalogTable, ParsedSheet> sheets = <CatalogTable, ParsedSheet>{};
  for (final CatalogTable table in CatalogTable.loadOrder) {
    final File file = File('assets/data/${table.fileName}');
    if (!file.existsSync()) continue;
    sheets[table] = CatalogSourceReader.parseCsv(
      table.fileName,
      file.readAsStringSync(),
    );
  }

  await CatalogImporter(db).import(sheets);
  return CatalogRepository(database: db);
}
