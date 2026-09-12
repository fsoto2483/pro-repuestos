import 'catalog_tables.dart';

enum IssueLevel { error, warning }

/// Un problema encontrado en una fila concreta del archivo.
class ImportIssue {
  const ImportIssue({
    required this.table,
    required this.line,
    required this.message,
    this.level = IssueLevel.error,
    this.column,
  });

  final CatalogTable table;

  /// Numero de fila tal como se ve en Excel: la 1 es el encabezado.
  final int line;
  final String? column;
  final String message;
  final IssueLevel level;

  bool get isError => level == IssueLevel.error;

  String get location =>
      '${table.label} · fila $line${column == null ? '' : ' · $column'}';
}

/// Cuantas filas entraron y cuantas se rechazaron en una tabla.
class TableResult {
  const TableResult({
    required this.table,
    required this.read,
    required this.accepted,
    this.provided = true,
  });

  final CatalogTable table;
  final int read;
  final int accepted;

  /// `false` cuando la tabla no venia en el archivo y se conservo la que ya
  /// estaba en la base de datos.
  final bool provided;

  int get rejected => read - accepted;
}

/// Resultado completo de una carga masiva.
class ImportReport {
  const ImportReport({
    required this.results,
    required this.issues,
    required this.applied,
    this.fatalError,
  });

  factory ImportReport.failure(String message) => ImportReport(
    results: const <TableResult>[],
    issues: const <ImportIssue>[],
    applied: false,
    fatalError: message,
  );

  final List<TableResult> results;
  final List<ImportIssue> issues;

  /// `true` si los cambios llegaron a guardarse en la base de datos.
  final bool applied;
  final String? fatalError;

  List<ImportIssue> get errors =>
      issues.where((ImportIssue i) => i.isError).toList();

  List<ImportIssue> get warnings =>
      issues.where((ImportIssue i) => !i.isError).toList();

  int get totalAccepted =>
      results.fold(0, (int sum, TableResult r) => sum + r.accepted);

  int get totalRejected =>
      results.fold(0, (int sum, TableResult r) => sum + r.rejected);

  bool get hasErrors => fatalError != null || errors.isNotEmpty;

  String get summary {
    if (fatalError != null) return fatalError!;
    if (!applied) {
      return 'No se guardo nada: corrige los errores y vuelve a intentar.';
    }
    final String base = '$totalAccepted registros cargados';
    if (totalRejected == 0) return '$base sin errores.';
    return '$base, $totalRejected filas descartadas.';
  }
}
