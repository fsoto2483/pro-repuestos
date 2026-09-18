import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repuestos_pro/data/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('user_version=2 SIN tablas quotes → falla el INSERT quotes', () async {
    final Database raw = sqlite3.openInMemory();
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
    // Simula DB ya marcada como v2 pero sin tablas de cotizaciones.
    raw.execute('PRAGMA user_version = 2');

    final AppDatabase db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.opened(raw)),
    );
    addTearDown(db.close);

    await db.customSelect('SELECT 1').get();
    await db.debugQuoteSchema();

    Object? caught;
    StackTrace? stack;
    try {
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
        items: const <QuoteItemsCompanion>[],
      );
    } catch (e, st) {
      caught = e;
      stack = st;
    }

    // ignore: avoid_print
    print('[QUOTE_DEBUG] EXCEPCION_EXACTA: $caught');
    // ignore: avoid_print
    print('[QUOTE_DEBUG] STACK_EXACTO:\n$stack');

    expect(caught, isNot(null));
    expect('$caught', contains('quotes'));
  });
}
