import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/quote.dart';

/// Persistencia local de cotizaciones confirmadas.
class QuotesRepository {
  QuotesRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Future<Quote> createFromCart({
    required List<CartItem> items,
    required QuoteCustomerInput customer,
    required double subtotal,
    required double taxRate,
    required double taxAmount,
    required double total,
    AppUser? user,
  }) async {
    debugPrint('[QUOTE_DEBUG] QuotesRepository.createFromCart INICIO '
        'items=${items.length}');
    if (items.isEmpty) {
      throw StateError('No se puede guardar una cotizacion vacia.');
    }

    try {
      await _db.debugQuoteSchema();
    } catch (e, st) {
      debugPrint('[QUOTE_DEBUG] QuotesRepository debugQuoteSchema fallo: $e');
      debugPrint('[QUOTE_DEBUG] STACK:\n$st');
    }

    final String quoteId =
        'cot-${DateTime.now().millisecondsSinceEpoch}';
    final DateTime now = DateTime.now();
    final int unitCount = items.fold(0, (int s, CartItem i) => s + i.quantity);

    final List<QuoteItemsCompanion> lineCompanions = <QuoteItemsCompanion>[];
    for (int i = 0; i < items.length; i++) {
      final CartItem item = items[i];
      lineCompanions.add(
        QuoteItemsCompanion.insert(
          id: '$quoteId-$i',
          quoteId: quoteId,
          productId: item.product.id,
          sku: item.product.sku,
          oem: Value<String>(item.product.oem),
          productName: item.product.name,
          brandName: Value<String>(item.product.brand),
          unitPrice: item.product.price,
          quantity: item.quantity,
          lineTotal: item.subtotal,
          sortOrder: Value<int>(i),
        ),
      );
    }

    final QuotesCompanion quoteCompanion = QuotesCompanion.insert(
      id: quoteId,
      userId: Value<String>(user?.id ?? ''),
      status: const Value<String>('confirmed'),
      customerName: customer.name.trim(),
      customerPhone: Value<String>(customer.phone.trim()),
      customerEmail: customer.email.trim().toLowerCase(),
      companyName: Value<String>(customer.companyName.trim()),
      notes: Value<String>(customer.notes.trim()),
      subtotal: subtotal,
      taxRate: Value<double>(taxRate),
      taxAmount: taxAmount,
      total: total,
      itemCount: Value<int>(items.length),
      unitCount: Value<int>(unitCount),
      createdAt: now,
    );

    debugPrint('[QUOTE_DEBUG] QuotesRepository → insertQuote id=$quoteId '
        'lines=${lineCompanions.length}');
    try {
      await _db.insertQuote(
        quote: quoteCompanion,
        items: lineCompanions,
      );
      debugPrint('[QUOTE_DEBUG] QuotesRepository insertQuote OK');
    } catch (e, st) {
      debugPrint('[QUOTE_DEBUG] QuotesRepository insertQuote FALLO: $e');
      debugPrint('[QUOTE_DEBUG] QuotesRepository STACK:\n$st');
      rethrow;
    }

    final Quote? saved = await fetchById(quoteId);
    if (saved == null) {
      throw StateError('La cotizacion se guardo pero no se pudo releer.');
    }
    return saved;
  }

  Future<List<Quote>> listForUser(String? userId) async {
    final List<QuoteRow> rows = await _db.listQuotes(userId: userId);
    return rows.map(_quoteFromRow).toList();
  }

  Future<Quote?> fetchById(String id) async {
    final QuoteRow? row = await _db.quoteById(id);
    if (row == null) return null;
    final List<QuoteItemRow> lines = await _db.quoteItemsFor(id);
    return _quoteFromRow(row).copyWith(
      items: lines.map(_itemFromRow).toList(),
    );
  }

  static Quote _quoteFromRow(QuoteRow row) => Quote(
    id: row.id,
    userId: row.userId,
    status: row.status,
    customerName: row.customerName,
    customerPhone: row.customerPhone,
    customerEmail: row.customerEmail,
    companyName: row.companyName,
    notes: row.notes,
    subtotal: row.subtotal,
    taxRate: row.taxRate,
    taxAmount: row.taxAmount,
    total: row.total,
    itemCount: row.itemCount,
    unitCount: row.unitCount,
    createdAt: row.createdAt,
  );

  static QuoteItem _itemFromRow(QuoteItemRow row) => QuoteItem(
    id: row.id,
    productId: row.productId,
    sku: row.sku,
    oem: row.oem,
    productName: row.productName,
    brandName: row.brandName,
    unitPrice: row.unitPrice,
    quantity: row.quantity,
    lineTotal: row.lineTotal,
  );
}
