import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repuestos_pro/data/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Simula una DB v1 (sin quotes) y abre AppDatabase v2 encima.
void main() {
  test('migracion v1->v2 crea quotes y permite insert', () async {
    final Database raw = sqlite3.openInMemory();
    // Schema minimo v1: al menos una tabla + user_version=1
    raw.execute('''
      CREATE TABLE categories (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        icon_key TEXT NOT NULL DEFAULT 'default',
        color_hex TEXT NOT NULL DEFAULT '#FF5A1F',
        sort_order INTEGER NOT NULL DEFAULT 0
      );
    ''');
    raw.execute('PRAGMA user_version = 1');

    final AppDatabase db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.opened(raw)),
    );
    addTearDown(db.close);

    // Dispara beforeOpen / onUpgrade
    await db.customSelect('SELECT 1').get();
    await db.debugQuoteSchema();

    // Intentar insert directo
    await db.insertQuote(
      quote: QuotesCompanion.insert(
        id: 'cot-test',
        customerName: 'Felipe',
        customerEmail: 'a@b.com',
        subtotal: 100,
        taxAmount: 19,
        total: 119,
        createdAt: DateTime.now(),
      ),
      items: <QuoteItemsCompanion>[
        QuoteItemsCompanion.insert(
          id: 'cot-test-0',
          quoteId: 'cot-test',
          productId: 'p-1',
          sku: 'S',
          productName: 'Prod',
          unitPrice: 100,
          quantity: 1,
          lineTotal: 100,
        ),
      ],
    );
  });
}
