import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/product.dart';

/// Cotizacion en curso. En un negocio de repuestos el carrito funciona como
/// una lista de pedido para el taller, por eso se calcula IVA y total.
class CartController extends ChangeNotifier {
  static const double ivaRate = 0.19;

  final Map<String, CartItem> _items = <String, CartItem>{};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get distinctCount => _items.length;

  int get totalUnits =>
      _items.values.fold(0, (int sum, CartItem i) => sum + i.quantity);

  double get subtotal =>
      _items.values.fold(0, (double sum, CartItem i) => sum + i.subtotal);

  double get iva => subtotal * ivaRate;
  double get total => subtotal + iva;

  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;
  bool contains(String productId) => _items.containsKey(productId);

  /// Agrega respetando el stock disponible del producto.
  void add(Product product, {int quantity = 1}) {
    if (!product.isAvailable) return;
    final int current = quantityOf(product.id);
    final int next = (current + quantity).clamp(1, product.stock);
    _items[product.id] = CartItem(product: product, quantity: next);
    notifyListeners();
  }

  void setQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      remove(product.id);
      return;
    }
    _items[product.id] = CartItem(
      product: product,
      quantity: quantity.clamp(1, product.stock),
    );
    notifyListeners();
  }

  void increment(Product product) => add(product);

  void decrement(Product product) =>
      setQuantity(product, quantityOf(product.id) - 1);

  void remove(String productId) {
    if (_items.remove(productId) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
