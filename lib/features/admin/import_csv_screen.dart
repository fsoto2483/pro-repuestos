import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../admin/import_csv_screen.dart';

class ImportCsvScreen extends StatefulWidget {
  const ImportCsvScreen({super.key});

  @override
  State<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends State<ImportCsvScreen> {
  String? selectedFile;

  Future<void> pickCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
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
          children: [

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