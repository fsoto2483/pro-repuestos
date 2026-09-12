import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xlsx;

import 'catalog_importer.dart';
import 'catalog_tables.dart';

/// Un archivo elegido por el usuario, todavia sin interpretar.
class SourceFile {
  const SourceFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;

  String get extension {
    final int dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  bool get isExcel => extension == 'xlsx' || extension == 'xls';
}

/// Las hojas reconocidas de un lote de archivos, mas lo que se ignoro.
class SheetCollection {
  const SheetCollection({required this.sheets, required this.ignored});

  final Map<CatalogTable, ParsedSheet> sheets;

  /// Nombres de archivos u hojas que no corresponden a ninguna tabla.
  final List<String> ignored;

  bool get isEmpty => sheets.isEmpty;
}

/// Convierte archivos CSV y libros de Excel en hojas listas para el importador.
///
/// La tabla de destino se deduce del nombre: `productos.csv`, `productos.xlsx`
/// o una hoja llamada `productos` terminan todas en la tabla de productos.
class CatalogSourceReader {
  const CatalogSourceReader();

  SheetCollection read(List<SourceFile> files) {
    final Map<CatalogTable, ParsedSheet> sheets = <CatalogTable, ParsedSheet>{};
    final List<String> ignored = <String>[];

    for (final SourceFile file in files) {
      if (file.isExcel) {
        _readWorkbook(file, sheets, ignored);
      } else {
        final CatalogTable? table = CatalogTable.matchName(file.name);
        if (table == null) {
          ignored.add(file.name);
          continue;
        }
        sheets[table] = parseCsv(file.name, decodeText(file.bytes));
      }
    }

    return SheetCollection(sheets: sheets, ignored: ignored);
  }

  void _readWorkbook(
    SourceFile file,
    Map<CatalogTable, ParsedSheet> sheets,
    List<String> ignored,
  ) {
    final xlsx.Excel book = xlsx.Excel.decodeBytes(file.bytes);

    for (final MapEntry<String, xlsx.Sheet> entry in book.tables.entries) {
      final CatalogTable? table = CatalogTable.matchName(entry.key);
      if (table == null) {
        ignored.add('${file.name} · ${entry.key}');
        continue;
      }

      sheets[table] = ParsedSheet(
        sourceName: '${file.name} · ${entry.key}',
        rows: entry.value.rows
            .map(
              (List<xlsx.Data?> row) =>
                  row.map((xlsx.Data? cell) => _cellText(cell?.value)).toList(),
            )
            .toList(),
      );
    }
  }

  static String _cellText(xlsx.CellValue? value) {
    if (value == null) return '';
    // Excel guarda todo numero como decimal. Sin esto, el id 12 llegaria como
    // "12.0" y no encontraria a su padre.
    if (value is xlsx.DoubleCellValue) {
      final double number = value.value;
      if (number == number.roundToDouble() && number.abs() < 1e15) {
        return number.toInt().toString();
      }
      return number.toString();
    }
    return value.toString().trim();
  }

  /// Lee un CSV separado por comas o por punto y coma.
  ///
  /// Todas las celdas quedan como texto: la conversion a numero la hace el
  /// importador, que sabe que `189.000` es un precio colombiano.
  static ParsedSheet parseCsv(String sourceName, String content) {
    final String text = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    // Sin `fieldDelimiter` el decodificador deduce solo si el archivo usa coma
    // o punto y coma, que es lo que cambia entre un Excel en espanol y uno en
    // ingles.
    final List<List<dynamic>> rows = const CsvToListConverter(
  	shouldParseNumbers: false,
  	eol: '\n',
    ).convert(text);

    return ParsedSheet(
      sourceName: sourceName,
      rows: rows
          .map(
            (List<dynamic> row) =>
                row.map((dynamic cell) => (cell ?? '').toString()).toList(),
          )
          .toList(),
    );
  }

  /// Excel en Windows exporta CSV en la codificacion regional, no en UTF-8.
  static String decodeText(Uint8List bytes) {
    Uint8List data = bytes;
    if (data.length >= 3 &&
        data[0] == 0xEF &&
        data[1] == 0xBB &&
        data[2] == 0xBF) {
      data = data.sublist(3);
    }
    try {
      return const Utf8Decoder(allowMalformed: false).convert(data);
    } on FormatException {
      return const Latin1Decoder(allowInvalid: true).convert(data);
    }
  }
}
