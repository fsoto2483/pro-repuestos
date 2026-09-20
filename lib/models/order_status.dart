/// Estados de una orden de venta (`sales_orders`).
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  dispatched,
  delivered,
  cancelled;

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.dispatched:
        return 'dispatched';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparación';
      case OrderStatus.dispatched:
        return 'Despacho';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// Mensaje visible al cliente según el estado.
  String get clientMessage {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return 'Tu pedido ha sido confirmado.';
      case OrderStatus.preparing:
        return 'Estamos preparando tu pedido.';
      case OrderStatus.dispatched:
        return 'Tu pedido está en despacho.';
      case OrderStatus.delivered:
        return 'Tu pedido fue entregado.';
      case OrderStatus.cancelled:
        return 'Tu pedido fue cancelado.';
    }
  }

  /// Timeline operativa (admin / logística).
  static const List<OrderStatus> timeline = <OrderStatus>[
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.dispatched,
    OrderStatus.delivered,
  ];

  /// Timeline visible al cliente (4 pasos).
  static const List<OrderStatus> clientTimeline = <OrderStatus>[
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.dispatched,
    OrderStatus.delivered,
  ];

  String get clientTimelineLabel {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return 'Pedido Confirmado';
      case OrderStatus.preparing:
        return 'Preparando Pedido';
      case OrderStatus.dispatched:
        return 'En Despacho';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// Índice en el timeline de cliente (pending cuenta como confirmado).
  int get clientTimelineIndex {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.dispatched:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  int get timelineIndex {
    final int i = timeline.indexOf(this);
    return i < 0 ? -1 : i;
  }

  /// Agrupa pendientes/confirmados/preparando para filtro "Preparación".
  bool get isPreparationPhase =>
      this == OrderStatus.pending ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing;

  static OrderStatus fromString(String? raw) {
    final String value = (raw ?? '').trim().toLowerCase();
    switch (value) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'dispatched':
        return OrderStatus.dispatched;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  static const List<OrderStatus> all = OrderStatus.values;
}
