import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repuestos_pro/data/db/app_database.dart';
import 'package:repuestos_pro/data/models/app_user.dart';
import 'package:repuestos_pro/data/models/cart_item.dart';
import 'package:repuestos_pro/data/models/part_category.dart';
import 'package:repuestos_pro/data/models/product.dart';
import 'package:repuestos_pro/data/models/quote.dart';
import 'package:repuestos_pro/data/repositories/quotes_repository.dart';

void main() {
  test('insertQuote en DB nueva (schema 2) funciona', () async {
    final AppDatabase db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.debugQuoteSchema();

    final QuotesRepository repo = QuotesRepository(database: db);
    final Quote quote = await repo.createFromCart(
      items: <CartItem>[
        CartItem(
          product: Product(
            id: 'p-1',
            name: 'Pastillas',
            category: PartCategory.fromStorage(
              id: 'frenos',
              name: 'Frenos',
              description: '',
              iconKey: 'default',
              colorHex: '#FF0000',
              sortOrder: 0,
            ),
            sku: 'SKU-1',
            oem: 'OEM-1',
            brandId: 'bosch',
            brand: 'Bosch',
            price: 1000,
            stock: 5,
            description: '',
          ),
          quantity: 2,
        ),
      ],
      customer: const QuoteCustomerInput(
        name: 'Felipe',
        phone: '300',
        email: 'a@b.com',
        companyName: 'Taller',
      ),
      subtotal: 2000,
      taxRate: 0.19,
      taxAmount: 380,
      total: 2380,
      user: const AppUser(
        id: 'u-demo',
        fullName: 'Felipe',
        email: 'a@b.com',
        provider: AuthProvider.password,
      ),
    );

    expect(quote.id, startsWith('cot-'));
    expect(quote.items, hasLength(1));
  });
}
