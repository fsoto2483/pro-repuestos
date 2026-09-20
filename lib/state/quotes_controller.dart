import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import 'cart_controller.dart';

/// Estado de cotizaciones respaldado exclusivamente por Firestore.
class QuotesController extends ChangeNotifier {
  QuotesController([QuoteService service = const QuoteService()])
      : _service = service;

  final QuoteService _service;

  StreamSubscription<List<Quote>>? _subscription;
  List<Quote> _quotes = <Quote>[];
  bool _loading = false;
  bool _saving = false;
  String? _error;
  String? _listeningUserId;

  List<Quote> get quotes => List<Quote>.unmodifiable(_quotes);
  bool get loading => _loading;
  bool get saving => _saving;
  String? get error => _error;
  int get count => _quotes.length;

  QuoteService get service => _service;

  /// Suscribe al stream de Firestore al iniciar sesión / app.
  void startListening({String? userId}) {
    final String? uid = (userId == null || userId.isEmpty) ? null : userId;
    if (_subscription != null && _listeningUserId == uid && uid != null) {
      return;
    }

    stopListening(clear: false);

    _listeningUserId = uid;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = _service.watchUserQuotes(uid).listen(
        (List<Quote> quotes) {
          _quotes = quotes;
          _loading = false;
          _error = null;
          notifyListeners();
        },
        onError: (Object e, StackTrace st) {
          _error = 'No se pudieron cargar las cotizaciones.';
          _loading = false;
          debugPrint('QuotesController.watch: $e');
          debugPrintStack(stackTrace: st);
          notifyListeners();
        },
      );
    } catch (e, st) {
      _error = 'No se pudieron cargar las cotizaciones.';
      _loading = false;
      debugPrint('QuotesController.startListening: $e');
      debugPrintStack(stackTrace: st);
      notifyListeners();
    }
  }

  void stopListening({bool clear = true}) {
    _subscription?.cancel();
    _subscription = null;
    _listeningUserId = null;
    if (clear) {
      _quotes = <Quote>[];
      _loading = false;
      _error = null;
      notifyListeners();
    }
  }

  /// Recarga puntual desde Firestore (también usado tras guardar).
  Future<void> load({String? userId}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _quotes = await _service.getUserQuotes(userId);
    } catch (e, st) {
      _error = 'No se pudieron cargar las cotizaciones.';
      debugPrint('QuotesController.load: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Guarda en Firestore y deja que el stream actualice la lista.
  Future<Quote?> confirmQuote({
    required CartController cart,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    String customerRazonSocial = '',
    String customerNombreComercial = '',
    String customerRuc = '',
    String vehicleBrand = '',
    String vehicleModel = '',
    String vehicleYear = '',
    String vehicleEngine = '',
  }) async {
    if (cart.isEmpty) {
      _error = 'La cotizacion esta vacia.';
      notifyListeners();
      return null;
    }

    _saving = true;
    _error = null;
    notifyListeners();

    try {
      final List<QuoteItem> items = cart.items
          .map(
            (CartItem item) => QuoteItem(
              productId: item.product.id,
              codigo: item.product.sku,
              descripcion: item.product.name,
              cantidad: item.quantity,
              precioUnitario: item.product.price,
              total: item.subtotal,
            ),
          )
          .toList();

      final Quote quote = await _service.createQuote(
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        customerRazonSocial: customerRazonSocial,
        customerNombreComercial: customerNombreComercial,
        customerRuc: customerRuc,
        vehicleBrand: vehicleBrand,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehicleEngine: vehicleEngine,
        items: items,
        subtotal: cart.subtotal,
        igv: cart.iva,
        total: cart.total,
        status: 'saved',
      );

      cart.clear();

      if (_subscription == null) {
        await load(userId: quote.userId);
      }

      return quote;
    } catch (e, st) {
      _error = 'No se pudo guardar la cotizacion. Intenta de nuevo.';
      debugPrint('QuotesController.confirmQuote: $e');
      debugPrintStack(stackTrace: st);
      return null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<Quote?> fetchById(String id) => _service.getQuote(id);

  Future<void> deleteQuote(String id) async {
    await _service.deleteQuote(id);
    if (_subscription == null) {
      _quotes = _quotes.where((Quote q) => q.id != id).toList();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
