import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../data/db/app_database.dart';
import '../../data/models/product.dart';
import '../../services/catalog_firestore_sync.dart';
import '../../services/firestore_service.dart';

/// Pantalla temporal para validar lectura de `products` en Cloud Firestore.
///
/// No forma parte del flujo de producto; se puede abrir con:
/// `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const FirestoreTestScreen()));`
class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({
    super.key,
    this.firestore = const FirestoreService(),
  });

  final FirestoreService firestore;

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  late Future<List<CatalogProduct>> _future;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _future = widget.firestore.fetchProducts();
  }

  void _reload() {
    setState(() {
      _future = widget.firestore.fetchProducts();
    });
  }

  Future<void> _syncDriftToFirestore() async {
    if (_syncing) return;
    setState(() => _syncing = true);

    final CatalogFirestoreSync sync = CatalogFirestoreSync(
      db: AppDatabase.instance,
    );
    final FirestoreSyncReport report = await sync.run();

    if (!mounted) return;

    setState(() => _syncing = false);

    final int productsTotal =
        report.productsCreated + report.productsUpdated;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Categorias: ${report.categoriesUpserted}\n'
          'Marcas: ${report.brandsUpserted}\n'
          'Productos: $productsTotal\n'
          'Errores: ${report.errors.length}',
        ),
        duration: const Duration(seconds: 6),
      ),
    );

    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Recargar',
            onPressed: _syncing ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _syncing ? null : _syncDriftToFirestore,
                icon: _syncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  _syncing ? 'Sincronizando...' : 'Sync Drift → Firestore',
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CatalogProduct>>(
              future: _future,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<CatalogProduct>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Error al leer products',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _reload,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final List<CatalogProduct> products =
                    snapshot.data ?? const <CatalogProduct>[];

                if (products.isEmpty) {
                  return const Center(
                    child: Text('No hay productos en Firestore.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: products.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final CatalogProduct product = products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('SKU: ${product.sku}'),
                      trailing: Text(
                        Formatters.price(product.price),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
