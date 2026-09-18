import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/db/app_database.dart';
import '../../data/import/catalog_sources.dart';
import '../../data/import/catalog_tables.dart';
import '../../data/import/import_report.dart';
import '../../services/firestore_service.dart';
import '../../state/catalog_controller.dart';
import '../../widgets/common.dart';

/// Carga masiva del catalogo desde archivos CSV o Excel.
///
/// Por defecto actualiza/agrega (upsert a Firestore). Opcionalmente puede
/// reemplazar por completo la coleccion `products` remota.
class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => const BulkImportScreen()),
    );
  }

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  bool _working = false;
  bool _replaceCatalog = false;
  ImportReport? _report;
  List<String> _pickedNames = <String>[];

  Future<void> _onReplaceChanged(bool value) async {
    if (!value) {
      setState(() => _replaceCatalog = false);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reemplazar catalogo completo'),
        content: const Text(
          'Esta accion eliminara todo el catalogo actual y lo reemplazara '
          'con los productos del Excel.\n\n'
          'Desea continuar?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    setState(() => _replaceCatalog = confirmed ?? false);
  }

  Future<void> _pickAndImport() async {
    // ignore: avoid_print
    print('[IMPORT_DEBUG] BulkImportScreen._pickAndImport INICIO');
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Archivos del catalogo',
      type: FileType.custom,
      allowedExtensions: <String>['csv', 'xlsx', 'xls'],
      withData: true,
    );

    if (result == null) {
      // ignore: avoid_print
      print('[IMPORT_DEBUG] usuario cancelo picker');
      return;
    }

    final List<SourceFile> files = <SourceFile>[];

    for (final PlatformFile file in result.files) {
      // ignore: avoid_print
      print('[IMPORT_DEBUG] PlatformFile name=${file.name} '
          'bytesNull=${file.bytes == null} size=${file.size}');
      if (file.bytes == null) continue;

      files.add(
        SourceFile(
          name: file.name,
          bytes: file.bytes!,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      _working = true;
      _report = null;
      _pickedNames = files.map((SourceFile f) => f.name).toList();
    });

    try {
      if (_replaceCatalog) {
        // ignore: avoid_print
        print('[IMPORT]\nModo: REEMPLAZAR CATALOGO');
        try {
          final int deleted =
              await const FirestoreService().deleteAllProducts();
          // ignore: avoid_print
          print('[IMPORT]\nProductos eliminados: $deleted');
        } catch (e) {
          // ignore: avoid_print
          print('[IMPORT]\nError al eliminar productos: $e');
          if (!mounted) return;
          setState(() {
            _working = false;
            _report = ImportReport.failure(
              'No se pudo eliminar el catalogo en Firestore. '
              'La importacion no se inicio. Detalle: $e',
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Error al eliminar el catalogo. No se importo nada.',
              ),
            ),
          );
          return;
        }
      }

      // ignore: avoid_print
      print('[IMPORT_DEBUG] enviando a CatalogController.importFiles '
          'count=${files.length}');
      final ImportReport report =
          await context.read<CatalogController>().importFiles(files);
      // ignore: avoid_print
      print('[IMPORT_DEBUG] BulkImportScreen report.applied=${report.applied} '
          'fatal=${report.fatalError} summary=${report.summary}');

      if (_replaceCatalog) {
        final int imported = report.results
            .where((TableResult r) => r.table == CatalogTable.products)
            .fold<int>(0, (int sum, TableResult r) => sum + r.accepted);
        // ignore: avoid_print
        print('[IMPORT]\nProductos importados: $imported');
        // ignore: avoid_print
        print('[IMPORT]\nProceso completado');
      }

      if (!mounted) return;

      if (!report.applied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              report.fatalError ??
                  'La importacion fallo. Revisa el reporte de errores.',
            ),
          ),
        );
      }

      setState(() {
        _working = false;
        _report = report;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _report = ImportReport.failure(
          'Error durante la importacion: $e',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error durante la importacion: $e')),
      );
    }
  }

  Future<void> _restore() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Restaurar el catalogo de ejemplo'),
        content: const Text(
          'Se borra lo que hayas cargado y vuelven los datos que trae la '
          'aplicacion. No se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;

    setState(() {
      _working = true;
      _report = null;
      _pickedNames = <String>[];
    });

    final ImportReport report = await context
        .read<CatalogController>()
        .restoreBundledCatalog();

    if (!mounted) return;
    setState(() {
      _working = false;
      _report = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CatalogController catalog = context.watch<CatalogController>();
    final double gutter = context.horizontalPadding;

    return Scaffold(
      appBar: AppBar(title: const Text('Carga masiva')),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 900,
          child: ListView(
            padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 32),
            children: <Widget>[
              const _HowItWorks(),
              const SizedBox(height: 20),

              _CurrentCatalog(stats: catalog.stats),
              const SizedBox(height: 20),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reemplazar catalogo completo'),
                subtitle: Text(
                  _replaceCatalog
                      ? 'Se eliminaran todos los productos de Firestore '
                          'antes de importar el Excel.'
                      : 'Por defecto solo se actualizan y agregan productos '
                          '(no se elimina nada).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: _replaceCatalog,
                onChanged: _working ? null : _onReplaceChanged,
              ),
              const SizedBox(height: 12),

              FilledButton.icon(
                onPressed: _working ? null : _pickAndImport,
                icon: _working
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file_rounded),
                label: Text(
                  _working ? 'Procesando...' : 'Elegir archivos CSV o Excel',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _working ? null : _restore,
                icon: const Icon(Icons.restore_rounded, size: 20),
                label: const Text('Restaurar el catalogo de ejemplo'),
              ),

              if (_pickedNames.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  'Archivos leidos: ${_pickedNames.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],

              if (_report != null) ...<Widget>[
                const SizedBox(height: 24),
                _ReportView(report: _report!),
              ],

              const SizedBox(height: 28),
              const _FormatReference(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    Widget step(int number, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.ink, AppColors.steel],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Como cargar tu catalogo',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          step(1, 'Nombra cada archivo como la tabla: productos.csv, '
              'modelos.csv, compatibilidades.csv...'),
          step(2, 'Si usas Excel, un solo archivo sirve: pon cada tabla en '
              'una hoja con ese mismo nombre.'),
          step(3, 'Puedes cargar solo las tablas que cambiaron. Las demas '
              'quedan como estan.'),
          step(4, 'Las filas con errores se descartan y se te muestran con el '
              'numero de fila para corregirlas.'),
        ],
      ),
    );
  }
}

class _CurrentCatalog extends StatelessWidget {
  const _CurrentCatalog({required this.stats});

  final CatalogStats? stats;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CatalogStats? data = stats;

    if (data == null) {
      return const Skeleton(height: 90, radius: AppTheme.radius);
    }

    Widget cell(String label, int value) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$value', style: theme.textTheme.titleLarge),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 18,
        runSpacing: 14,
        children: <Widget>[
          cell('Categorias', data.categories),
          cell('Marcas de\nrepuesto', data.partBrands),
          cell('Marcas de\nvehiculo', data.makes),
          cell('Modelos', data.models),
          cell('Motores', data.engines),
          cell('Productos', data.products),
          cell('Imagenes', data.images),
          cell('Compatibi-\nlidades', data.fitments),
        ],
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report});

  final ImportReport report;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool ok = report.applied && !report.hasErrors;
    final Color accent = ok
        ? AppColors.success
        : (report.applied ? AppColors.warning : AppColors.danger);

    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                ok
                    ? Icons.check_circle_rounded
                    : (report.applied
                          ? Icons.warning_amber_rounded
                          : Icons.error_rounded),
                color: accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(report.summary, style: theme.textTheme.titleSmall),
              ),
            ],
          ),

          if (report.results.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            for (final TableResult result in report.results)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        result.table.label,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      result.provided
                          ? '${result.accepted} de ${result.read}'
                          : '${result.accepted} (sin cambios)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: result.rejected > 0
                            ? AppColors.danger
                            : AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
          ],

          if (report.issues.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  'Ver ${report.issues.length} avisos',
                  style: theme.textTheme.labelLarge,
                ),
                children: <Widget>[
                  for (final ImportIssue issue in report.issues.take(60))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            issue.isError
                                ? Icons.cancel_rounded
                                : Icons.info_rounded,
                            size: 15,
                            color: issue.isError
                                ? AppColors.danger
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  issue.location,
                                  style: theme.textTheme.labelSmall,
                                ),
                                Text(
                                  issue.message,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (report.issues.length > 60)
                    Text(
                      'y ${report.issues.length - 60} avisos mas.',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Las columnas que espera cada archivo, para no tener que abrir el codigo.
class _FormatReference extends StatelessWidget {
  const _FormatReference();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Formato de los archivos', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Los nombres de las columnas van en la primera fila y no distinguen '
          'mayusculas. El orden no importa.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Material(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: theme.copyWith(dividerColor: theme.colorScheme.outlineVariant),
            child: Column(
              children: <Widget>[
                for (final CatalogTable table in CatalogTable.loadOrder)
                  ExpansionTile(
                    title: Text(
                      table.label,
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      table.fileName,
                      style: theme.textTheme.bodySmall,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _ColumnList(
                        title: 'Obligatorias',
                        columns: table.required,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 10),
                      if (table.optional.isNotEmpty)
                        _ColumnList(
                          title: 'Opcionales',
                          columns: table.optional,
                          color: AppColors.slate,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ColumnList extends StatelessWidget {
  const _ColumnList({
    required this.title,
    required this.columns,
    required this.color,
  });

  final String title;
  final List<String> columns;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: columns
              .map(
                (String column) =>
                    Pill(label: column, color: color, dense: true, filled: false),
              )
              .toList(),
        ),
      ],
    );
  }
}
