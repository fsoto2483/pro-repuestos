import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'catalog_tables.dart';
import 'import_report.dart';

/// Una tabla ya convertida a filas de texto. La primera fila es el encabezado.
class ParsedSheet {
  const ParsedSheet({required this.sourceName, required this.rows});

  final String sourceName;
  final List<List<String>> rows;

  bool get isEmpty => rows.length < 2;
}

/// Carga masiva del catalogo.
///
/// Recibe las tablas ya convertidas a filas de texto (vengan de un CSV, de un
/// Excel o de los archivos que trae la app) y las escribe en la base de datos
/// en una sola transaccion.
///
/// Reglas:
/// - Las tablas que no vengan en el archivo conservan lo que ya estaba.
/// - Una fila con un dato obligatorio vacio se descarta y se reporta.
/// - Una fila que apunta a un registro inexistente se descarta, junto con todo
///   lo que dependa de ella.
class CatalogImporter {
  CatalogImporter(this._db);

  final AppDatabase _db;

  Future<ImportReport> import(Map<CatalogTable, ParsedSheet> sources) async {
    final List<ImportIssue> issues = <ImportIssue>[];
    final List<TableResult> results = <TableResult>[];

    final Map<CatalogTable, List<_Record>> parsed =
        <CatalogTable, List<_Record>>{};

    // 1. Leer lo que viene en el archivo y lo que ya estaba en la base.
    for (final CatalogTable table in CatalogTable.loadOrder) {
      final ParsedSheet? sheet = sources[table];

      if (sheet == null) {
        final List<_Record> existing = await _readExisting(table);
        parsed[table] = existing;
        results.add(
          TableResult(
            table: table,
            read: existing.length,
            accepted: existing.length,
            provided: false,
          ),
        );
        continue;
      }

      final _ParseOutcome outcome = _parseSheet(table, sheet);
      issues.addAll(outcome.issues);
      if (outcome.fatal != null) {
        return ImportReport(
          results: results,
          issues: issues,
          applied: false,
          fatalError: outcome.fatal,
        );
      }
      parsed[table] = outcome.records;
      results.add(
        TableResult(
          table: table,
          read: outcome.readCount,
          accepted: outcome.records.length,
        ),
      );
    }

    // 2. Descartar lo que apunte a registros que no existen.
    final List<TableResult> adjusted = _enforceReferences(
      parsed,
      issues,
      results,
    );

    // 3. Escribir todo de una sola vez.
    try {
      await _db.replaceCatalog(
        categoryRows: parsed[CatalogTable.categories]!
            .map((_Record r) => r.companion as CategoriesCompanion)
            .toList(),
        partBrandRows: parsed[CatalogTable.partBrands]!
            .map((_Record r) => r.companion as PartBrandsCompanion)
            .toList(),
        makeRows: parsed[CatalogTable.vehicleMakes]!
            .map((_Record r) => r.companion as VehicleMakesCompanion)
            .toList(),
        modelRows: parsed[CatalogTable.vehicleModels]!
            .map((_Record r) => r.companion as VehicleModelsCompanion)
            .toList(),
        engineRows: parsed[CatalogTable.engines]!
            .map((_Record r) => r.companion as EnginesCompanion)
            .toList(),
        productRows: parsed[CatalogTable.products]!
            .map((_Record r) => r.companion as ProductsCompanion)
            .toList(),
        imageRows: parsed[CatalogTable.productImages]!
            .map((_Record r) => r.companion as ProductImagesCompanion)
            .toList(),
        fitmentRows: parsed[CatalogTable.fitments]!
            .map((_Record r) => r.companion as FitmentsCompanion)
            .toList(),
      );
    } catch (e) {
      return ImportReport(
        results: adjusted,
        issues: issues,
        applied: false,
        fatalError: 'La base de datos rechazo la carga: $e',
      );
    }

    return ImportReport(results: adjusted, issues: issues, applied: true);
  }

  // ------------------------------------------------------------- lectura

  _ParseOutcome _parseSheet(CatalogTable table, ParsedSheet sheet) {
    final List<ImportIssue> issues = <ImportIssue>[];

    if (sheet.rows.isEmpty) {
      return _ParseOutcome(
        records: const <_Record>[],
        issues: issues,
        readCount: 0,
      );
    }

    final List<String> header = sheet.rows.first
        .map((String h) => h.trim().toLowerCase())
        .toList();

    final List<String> missing = table.required
        .where((String c) => !header.contains(c))
        .toList();
    if (missing.isNotEmpty) {
      return _ParseOutcome(
        records: const <_Record>[],
        issues: issues,
        readCount: 0,
        fatal:
            'A "${sheet.sourceName}" le faltan columnas obligatorias: '
            '${missing.join(', ')}.',
      );
    }

    final Map<String, int> index = <String, int>{
      for (int i = 0; i < header.length; i++) header[i]: i,
    };

    final List<_Record> records = <_Record>[];
    final Set<String> seenIds = <String>{};
    int readCount = 0;

    for (int i = 1; i < sheet.rows.length; i++) {
      final List<String> cells = sheet.rows[i];
      if (cells.every((String c) => c.trim().isEmpty)) continue;
      readCount++;

      final int line = i + 1;
      final _Row row = _Row(table: table, line: line, cells: cells, index: index);

      final String id = row.text('id');
      if (id.isEmpty) {
        issues.add(
          ImportIssue(
            table: table,
            line: line,
            column: 'id',
            message: 'La fila no tiene id y se descarto.',
          ),
        );
        continue;
      }
      if (!seenIds.add(id)) {
        issues.add(
          ImportIssue(
            table: table,
            line: line,
            column: 'id',
            message: 'El id "$id" esta repetido en el archivo.',
          ),
        );
        continue;
      }

      final _Record? record = _buildRecord(table, row);
      issues.addAll(row.issues);
      if (record != null) records.add(record.atLine(line));
    }

    return _ParseOutcome(
      records: records,
      issues: issues,
      readCount: readCount,
    );
  }

  _Record? _buildRecord(CatalogTable table, _Row row) {
    switch (table) {
      case CatalogTable.categories:
        final String id = row.required('id');
        final String name = row.required('nombre');
        if (row.failed) return null;
        return _Record(
          id: id,
          companion: CategoriesCompanion.insert(
            id: id,
            name: name,
            description: Value<String>(row.text('descripcion')),
            iconKey: Value<String>(
              row.text('icono').isEmpty ? id : row.text('icono'),
            ),
            colorHex: Value<String>(
              row.text('color').isEmpty ? '#FF5A1F' : row.text('color'),
            ),
            sortOrder: Value<int>(row.integer('orden', fallback: 0)),
          ),
        );

      case CatalogTable.partBrands:
        final String id = row.required('id');
        final String name = row.required('nombre');
        if (row.failed) return null;
        return _Record(
          id: id,
          companion: PartBrandsCompanion.insert(
            id: id,
            name: name,
            country: Value<String>(row.text('pais')),
            tier: Value<String>(
              row.text('tipo').isEmpty ? 'homologada' : row.text('tipo'),
            ),
            logoUrl: Value<String?>(row.nullableText('logo_url')),
          ),
        );

      case CatalogTable.vehicleMakes:
        final String id = row.required('id');
        final String name = row.required('nombre');
        if (row.failed) return null;
        return _Record(
          id: id,
          companion: VehicleMakesCompanion.insert(
            id: id,
            name: name,
            country: Value<String>(row.text('pais')),
          ),
        );

      case CatalogTable.vehicleModels:
        final String id = row.required('id');
        final String makeId = row.required('marca_id');
        final String name = row.required('nombre');
        final int from = row.requiredInt('ano_desde');
        final int to = row.requiredInt('ano_hasta');
        if (row.failed) return null;
        return _Record(
          id: id,
          parentIds: <String, String>{'marca_id': makeId},
          companion: VehicleModelsCompanion.insert(
            id: id,
            makeId: makeId,
            name: name,
            bodyType: Value<String>(row.text('carroceria')),
            yearFrom: from,
            yearTo: to,
          ),
        );

      case CatalogTable.engines:
        final String id = row.required('id');
        final String modelId = row.required('modelo_id');
        final String code = row.required('codigo');
        final String name = row.required('nombre');
        final int from = row.requiredInt('ano_desde');
        final int to = row.requiredInt('ano_hasta');
        if (row.failed) return null;
        return _Record(
          id: id,
          parentIds: <String, String>{'modelo_id': modelId},
          companion: EnginesCompanion.insert(
            id: id,
            modelId: modelId,
            code: code,
            name: name,
            displacement: Value<double>(row.decimal('cilindrada')),
            fuel: Value<String>(
              row.text('combustible').isEmpty
                  ? 'Gasolina'
                  : row.text('combustible'),
            ),
            horsepower: Value<int>(row.integer('potencia_hp', fallback: 0)),
            yearFrom: from,
            yearTo: to,
          ),
        );

      case CatalogTable.products:
        final String id = row.required('id');
        final String sku = row.required('sku');
        final String name = row.required('nombre');
        final String categoryId = row.required('categoria_id');
        final String brandId = row.required('marca_repuesto_id');
        final double price = row.requiredDecimal('precio');
        if (row.failed) return null;
        return _Record(
          id: id,
          parentIds: <String, String>{
            'categoria_id': categoryId,
            'marca_repuesto_id': brandId,
          },
          companion: ProductsCompanion.insert(
            id: id,
            sku: sku,
            oem: row.text('oem'),
            name: name,
            description: Value<String>(row.text('descripcion')),
            categoryId: categoryId,
            partBrandId: brandId,
            price: price,
            previousPrice: Value<double?>(row.nullableDecimal('precio_anterior')),
            stock: Value<int>(row.integer('stock', fallback: 0)),
            warrantyMonths: Value<int>(
              row.integer('garantia_meses', fallback: 12),
            ),
            rating: Value<double>(row.decimal('calificacion')),
            reviewCount: Value<int>(
              row.integer('numero_opiniones', fallback: 0),
            ),
            isFeatured: Value<bool>(row.boolean('destacado')),
            specsJson: Value<String>(_specsToJson(row.text('ficha_tecnica'))),
          ),
        );

      case CatalogTable.productImages:
        final String id = row.required('id');
        final String productId = row.required('producto_id');
        final String url = row.required('url');
        if (row.failed) return null;
        return _Record(
          id: id,
          parentIds: <String, String>{'producto_id': productId},
          companion: ProductImagesCompanion.insert(
            id: id,
            productId: productId,
            url: url,
            sortOrder: Value<int>(row.integer('orden', fallback: 0)),
            isPrimary: Value<bool>(row.boolean('principal')),
          ),
        );

      case CatalogTable.fitments:
        final String id = row.required('id');
        final String productId = row.required('producto_id');
        final String modelId = row.required('modelo_id');
        final int from = row.requiredInt('ano_desde');
        final int to = row.requiredInt('ano_hasta');
        if (row.failed) return null;
        final String? engineId = row.nullableText('motor_id');
        return _Record(
          id: id,
          parentIds: <String, String>{
            'producto_id': productId,
            'modelo_id': modelId,
            'motor_id': ?engineId,
          },
          companion: FitmentsCompanion.insert(
            id: id,
            productId: productId,
            modelId: modelId,
            engineId: Value<String?>(engineId),
            yearFrom: from,
            yearTo: to,
          ),
        );
    }
  }

  /// Convierte `Material=Ceramica|Piezas=4` en JSON.
  ///
  /// Se acepta tambien JSON directo, por si el archivo lo trae asi.
  static String _specsToJson(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return '{}';
    if (value.startsWith('{')) {
      try {
        jsonDecode(value);
        return value;
      } on FormatException {
        return '{}';
      }
    }

    final Map<String, String> specs = <String, String>{};
    for (final String pair in value.split('|')) {
      final int eq = pair.indexOf('=');
      if (eq <= 0) continue;
      final String key = pair.substring(0, eq).trim();
      final String val = pair.substring(eq + 1).trim();
      if (key.isNotEmpty) specs[key] = val;
    }
    return jsonEncode(specs);
  }

  // ------------------------------------------------------- integridad FK

  /// Qué columna de cada tabla apunta a qué tabla padre.
  static const Map<CatalogTable, Map<String, CatalogTable>> _references =
      <CatalogTable, Map<String, CatalogTable>>{
        CatalogTable.vehicleModels: <String, CatalogTable>{
          'marca_id': CatalogTable.vehicleMakes,
        },
        CatalogTable.engines: <String, CatalogTable>{
          'modelo_id': CatalogTable.vehicleModels,
        },
        CatalogTable.products: <String, CatalogTable>{
          'categoria_id': CatalogTable.categories,
          'marca_repuesto_id': CatalogTable.partBrands,
        },
        CatalogTable.productImages: <String, CatalogTable>{
          'producto_id': CatalogTable.products,
        },
        CatalogTable.fitments: <String, CatalogTable>{
          'producto_id': CatalogTable.products,
          'modelo_id': CatalogTable.vehicleModels,
          'motor_id': CatalogTable.engines,
        },
      };

  List<TableResult> _enforceReferences(
    Map<CatalogTable, List<_Record>> parsed,
    List<ImportIssue> issues,
    List<TableResult> results,
  ) {
    // Se recorre en orden de dependencia: al llegar a una tabla, sus padres ya
    // quedaron depurados, asi que el descarte se propaga solo.
    for (final CatalogTable table in CatalogTable.loadOrder) {
      final Map<String, CatalogTable>? refs = _references[table];
      if (refs == null) continue;

      final List<_Record> records = parsed[table]!;
      final List<_Record> kept = <_Record>[];

      for (final _Record record in records) {
        String? problem;
        for (final MapEntry<String, CatalogTable> ref in refs.entries) {
          final String? value = record.parentIds[ref.key];
          if (value == null || value.isEmpty) continue;
          final bool exists = parsed[ref.value]!.any(
            (_Record p) => p.id == value,
          );
          if (!exists) {
            problem =
                'La columna ${ref.key} apunta a "$value", que no existe en '
                '${ref.value.label}.';
            break;
          }
        }

        if (problem == null) {
          kept.add(record);
        } else {
          issues.add(
            ImportIssue(
              table: table,
              line: record.line,
              message: problem,
            ),
          );
        }
      }

      parsed[table] = kept;
    }

    return results
        .map(
          (TableResult r) => TableResult(
            table: r.table,
            read: r.read,
            accepted: parsed[r.table]!.length,
            provided: r.provided,
          ),
        )
        .toList();
  }

  // --------------------------------------------- lo que ya esta guardado

  Future<List<_Record>> _readExisting(CatalogTable table) async {
    switch (table) {
      case CatalogTable.categories:
        final List<CategoryRow> rows = await _db.select(_db.categories).get();
        return rows
            .map(
              (CategoryRow r) =>
                  _Record(id: r.id, companion: r.toCompanion(false)),
            )
            .toList();

      case CatalogTable.partBrands:
        final List<PartBrandRow> rows = await _db.select(_db.partBrands).get();
        return rows
            .map(
              (PartBrandRow r) =>
                  _Record(id: r.id, companion: r.toCompanion(false)),
            )
            .toList();

      case CatalogTable.vehicleMakes:
        final List<VehicleMakeRow> rows =
            await _db.select(_db.vehicleMakes).get();
        return rows
            .map(
              (VehicleMakeRow r) =>
                  _Record(id: r.id, companion: r.toCompanion(false)),
            )
            .toList();

      case CatalogTable.vehicleModels:
        final List<VehicleModelRow> rows =
            await _db.select(_db.vehicleModels).get();
        return rows
            .map(
              (VehicleModelRow r) => _Record(
                id: r.id,
                companion: r.toCompanion(false),
                parentIds: <String, String>{'marca_id': r.makeId},
              ),
            )
            .toList();

      case CatalogTable.engines:
        final List<EngineRow> rows = await _db.select(_db.engines).get();
        return rows
            .map(
              (EngineRow r) => _Record(
                id: r.id,
                companion: r.toCompanion(false),
                parentIds: <String, String>{'modelo_id': r.modelId},
              ),
            )
            .toList();

      case CatalogTable.products:
        final List<ProductRow> rows = await _db.select(_db.products).get();
        return rows
            .map(
              (ProductRow r) => _Record(
                id: r.id,
                companion: r.toCompanion(false),
                parentIds: <String, String>{
                  'categoria_id': r.categoryId,
                  'marca_repuesto_id': r.partBrandId,
                },
              ),
            )
            .toList();

      case CatalogTable.productImages:
        final List<ProductImageRow> rows =
            await _db.select(_db.productImages).get();
        return rows
            .map(
              (ProductImageRow r) => _Record(
                id: r.id,
                companion: r.toCompanion(false),
                parentIds: <String, String>{'producto_id': r.productId},
              ),
            )
            .toList();

      case CatalogTable.fitments:
        final List<FitmentRow> rows = await _db.select(_db.fitments).get();
        return rows
            .map(
              (FitmentRow r) => _Record(
                id: r.id,
                companion: r.toCompanion(false),
                parentIds: <String, String>{
                  'producto_id': r.productId,
                  'modelo_id': r.modelId,
                  if (r.engineId != null) 'motor_id': r.engineId!,
                },
              ),
            )
            .toList();
    }
  }
}

class _Record {
  _Record({
    required this.id,
    required this.companion,
    this.parentIds = const <String, String>{},
    this.line = 0,
  });

  final String id;
  final Insertable<Object> companion;
  final Map<String, String> parentIds;
  final int line;

  _Record atLine(int value) => _Record(
    id: id,
    companion: companion,
    parentIds: parentIds,
    line: value,
  );
}

class _ParseOutcome {
  const _ParseOutcome({
    required this.records,
    required this.issues,
    required this.readCount,
    this.fatal,
  });

  final List<_Record> records;
  final List<ImportIssue> issues;
  final int readCount;
  final String? fatal;
}

/// Lectura de una fila con reporte de errores incorporado.
class _Row {
  _Row({
    required this.table,
    required this.line,
    required this.cells,
    required this.index,
  });

  final CatalogTable table;
  final int line;
  final List<String> cells;
  final Map<String, int> index;
  final List<ImportIssue> issues = <ImportIssue>[];

  bool failed = false;

  String text(String column) {
    final int? i = index[column];
    if (i == null || i >= cells.length) return '';
    return cells[i].trim();
  }

  String? nullableText(String column) {
    final String value = text(column);
    return value.isEmpty ? null : value;
  }

  String required(String column) {
    final String value = text(column);
    if (value.isEmpty) {
      _fail(column, 'El campo $column es obligatorio y llego vacio.');
    }
    return value;
  }

  int integer(String column, {required int fallback}) {
    final String value = text(column);
    if (value.isEmpty) return fallback;
    final int? parsed = int.tryParse(value.replaceAll(RegExp(r'[^\d-]'), ''));
    if (parsed == null) {
      _warn(column, 'No se pudo leer "$value" como numero entero.');
      return fallback;
    }
    return parsed;
  }

  int requiredInt(String column) {
    final String value = text(column);
    final int? parsed = int.tryParse(value.replaceAll(RegExp(r'[^\d-]'), ''));
    if (parsed == null) {
      _fail(column, '"$value" no es un ano valido.');
      return 0;
    }
    return parsed;
  }

  double decimal(String column) => _parseDecimal(text(column)) ?? 0;

  double? nullableDecimal(String column) => _parseDecimal(text(column));

  double requiredDecimal(String column) {
    final double? parsed = _parseDecimal(text(column));
    if (parsed == null) {
      _fail(column, '"${text(column)}" no es un numero valido.');
      return 0;
    }
    return parsed;
  }

  /// Acepta `189000`, `189.000`, `189,5` y `$ 189.000`.
  double? _parseDecimal(String raw) {
    String value = raw.trim().replaceAll(RegExp(r'[^\d.,-]'), '');
    if (value.isEmpty) return null;

    final int lastDot = value.lastIndexOf('.');
    final int lastComma = value.lastIndexOf(',');
    if (lastDot >= 0 && lastComma >= 0) {
      // El separador decimal es el que aparece de ultimo.
      if (lastComma > lastDot) {
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (lastComma >= 0) {
      final String decimals = value.substring(lastComma + 1);
      value = decimals.length == 3
          ? value.replaceAll(',', '')
          : value.replaceAll(',', '.');
    } else if (lastDot >= 0) {
      final String decimals = value.substring(lastDot + 1);
      if (decimals.length == 3) value = value.replaceAll('.', '');
    }

    return double.tryParse(value);
  }

  bool boolean(String column) {
    final String value = text(column).toLowerCase();
    return <String>{'1', 'true', 'si', 'sí', 'x', 'y', 'yes'}.contains(value);
  }

  void _fail(String column, String message) {
    failed = true;
    issues.add(
      ImportIssue(
        table: table,
        line: line,
        column: column,
        message: message,
      ),
    );
  }

  void _warn(String column, String message) {
    issues.add(
      ImportIssue(
        table: table,
        line: line,
        column: column,
        message: message,
        level: IssueLevel.warning,
      ),
    );
  }
}
