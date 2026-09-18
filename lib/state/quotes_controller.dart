import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/models/cart_item.dart';
import '../data/models/quote.dart';
import '../data/repositories/quotes_repository.dart';
import 'cart_controller.dart';

class QuotesController extends ChangeNotifier {
  QuotesController(this._repository);

  final QuotesRepository _repository;

  List<Quote> _quotes = <Quote>[];
  bool _loading = false;
  bool _saving = false;
  String? _error;

  List<Quote> get quotes => List<Quote>.unmodifiable(_quotes);
  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;
  int get count => _quotes.length;

  Future<void> load({String? userId}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _quotes = await _repository.listForUser(userId);
    } catch (e) {
      _error = 'No se pudieron cargar las cotizaciones.';
      debugPrint('QuotesController.load: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Confirma la cotizacion del carrito, la persiste y vacia el carrito.
  Future<Quote?> confirmQuote({
    required CartController cart,
    required QuoteCustomerInput customer,
    AppUser? user,
  }) async {
    debugPrint('[QUOTE_DEBUG] QuotesController.confirmQuote INICIO '
        'items=${cart.items.length} user=${user?.id}');
    if (cart.isEmpty) {
      _error = 'La cotizacion esta vacia.';
      notifyListeners();
      return null;
    }

    _saving = true;
    _error = null;
    notifyListeners();

    try {
      final List<CartItem> snapshot = List<CartItem>.from(cart.items);
      debugPrint('[QUOTE_DEBUG] QuotesController → repository.createFromCart');
      final Quote quote = await _repository.createFromCart(
        items: snapshot,
        customer: customer,
        subtotal: cart.subtotal,
        taxRate: CartController.ivaRate,
        taxAmount: cart.iva,
        total: cart.total,
        user: user,
      );
      debugPrint('[QUOTE_DEBUG] QuotesController OK id=${quote.id}');
      cart.clear();
      _quotes = <Quote>[quote, ..._quotes.where((Quote q) => q.id != quote.id)];
      return quote;
    } catch (e, st) {
      _error = 'No se pudo guardar la cotizacion. Intenta de nuevo.';
      // Temporal: exponer la causa real en UI para diagnostico.
      _error = 'FALLO: $e';
      debugPrint('[QUOTE_DEBUG] QuotesController EXCEPCION: $e');
      debugPrint('[QUOTE_DEBUG] QuotesController STACK:\n$st');
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<Quote?> fetchById(String id) => _repository.fetchById(id);
}
