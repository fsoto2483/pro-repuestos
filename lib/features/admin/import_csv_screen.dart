import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_role.dart';
import '../auth/auth_guard.dart';

/// Pantalla administrativa de seleccion de CSV (stub).
///
/// La carga real del catalogo vive en [BulkImportScreen]. Esta pantalla queda
/// protegida por rol para no exponer herramientas admin a clientes.
class ImportCsvScreen extends StatefulWidget {
  const ImportCsvScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const AuthGuard(
          requiredRole: UserRole.admin,
          child: ImportCsvScreen(),
        ),
      ),
    );
  }

  @override
  State<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends State<ImportCsvScreen> {
  String? selectedFile;

  Future<void> pickCsv() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['csv'],
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar CSV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: pickCsv,
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleccionar CSV'),
            ),
            const SizedBox(height: 20),
            if (selectedFile != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: Text(selectedFile!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
