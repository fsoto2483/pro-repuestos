import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/sales_order.dart';
import '../../services/delivery_service.dart';
import '../../services/sales_order_service.dart';
import '../../widgets/common.dart';

/// Detalle administrativo de una orden de venta (logística).
class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  static Future<void> open(BuildContext context, {required String orderId}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminOrderDetailScreen(orderId: orderId),
      ),
    );
  }

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final SalesOrderService _orderService = const SalesOrderService();
  final DeliveryService _deliveryService = const DeliveryService();

  SalesOrder? _order;
  Object? _error;
  bool _loading = true;
  bool _saving = false;

  late OrderStatus _selectedStatus;
  late TextEditingController _notesCtrl;
  late TextEditingController _driverCtrl;
  late TextEditingController _driverPhoneCtrl;
  late TextEditingController _plateCtrl;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    _driverCtrl = TextEditingController();
    _driverPhoneCtrl = TextEditingController();
    _plateCtrl = TextEditingController();
    _selectedStatus = OrderStatus.confirmed;
    _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _driverCtrl.dispose();
    _driverPhoneCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final SalesOrder? order = await _orderService.getOrder(widget.orderId);
      if (!mounted) return;
      if (order == null) {
        setState(() {
          _loading = false;
          _error = 'Orden no encontrada.';
        });
        return;
      }
      _notesCtrl.text = order.trackingNotes;
      _driverCtrl.text = order.assignedDriver;
      _driverPhoneCtrl.text = order.driverPhone;
      _plateCtrl.text = order.vehiclePlate;
      setState(() {
        _order = order;
        _selectedStatus = _logisticsStatusOrFallback(order.statusEnum);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveLogistics() async {
    final SalesOrder? order = _order;
    if (order == null) return;
    setState(() => _saving = true);
    try {
      await _deliveryService.assignDelivery(
        orderId: order.id,
        assignedDriver: _driverCtrl.text,
        driverPhone: _driverPhoneCtrl.text,
        vehiclePlate: _plateCtrl.text,
      );

      final OrderStatus next = _selectedStatus;
      if (next == OrderStatus.dispatched) {
        await _deliveryService.markDispatched(order.id);
      } else if (next == OrderStatus.delivered) {
        await _deliveryService.markDelivered(order.id);
      } else if (next == OrderStatus.preparing) {
        await _deliveryService.markPreparing(order.id);
      } else {
        await _orderService.updateOrderStatus(order.id, next.value);
      }

      await _orderService.updateTrackingNotes(order.id, _notesCtrl.text);

      if (!mounted) return;
      _snack('Seguimiento logístico guardado.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _snack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double pad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          _order?.orderNumber.isNotEmpty == true
              ? _order!.orderNumber
              : 'Detalle OV',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('$_error', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : _order == null
                  ? const EmptyState(
                      icon: Icons.local_shipping_outlined,
                      title: 'Orden no encontrada',
                      message: 'La orden no existe o fue eliminada.',
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
                      children: <Widget>[
                        _Section(
                          title: 'DATOS CLIENTE',
                          child: Column(
                            children: <Widget>[
                              _Row('Razón Social', _order!.displayRazonSocial),
                              _Row(
                                'Nombre Comercial',
                                _order!.nombreComercial,
                              ),
                              _Row('RUC', _order!.customerRuc),
                              _Row('Contacto', _order!.customerName),
                              _Row('Teléfono', _order!.customerPhone),
                              _Row('Correo', _order!.email),
                              if (_order!.quoteNumber.isNotEmpty)
                                _Row('Cotización', _order!.quoteNumber),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'PRODUCTOS',
                          child: Column(
                            children: <Widget>[
                              for (final QuoteItem item in _order!.items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          item.descripcion.isEmpty
                                              ? item.codigo
                                              : item.descripcion,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Text('x${item.cantidad}'),
                                      const SizedBox(width: 12),
                                      Text(
                                        Formatters.price(item.total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Divider(),
                              _Row(
                                'Total',
                                Formatters.price(_order!.total),
                                emphasize: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'LOGÍSTICA / DESPACHO',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              TextField(
                                controller: _driverCtrl,
                                enabled: !_saving,
                                decoration: const InputDecoration(
                                  labelText: 'Conductor',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _driverPhoneCtrl,
                                enabled: !_saving,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Teléfono conductor',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _plateCtrl,
                                enabled: !_saving,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  labelText: 'Placa vehículo',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<OrderStatus>(
                                key: ValueKey<String>(
                                  'ov-status-${_order!.id}-$_selectedStatus',
                                ),
                                initialValue: _logisticsStatusOrFallback(
                                  _selectedStatus,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Estado logístico',
                                  border: OutlineInputBorder(),
                                ),
                                items: const <DropdownMenuItem<OrderStatus>>[
                                  DropdownMenuItem<OrderStatus>(
                                    value: OrderStatus.preparing,
                                    child: Text('Preparación'),
                                  ),
                                  DropdownMenuItem<OrderStatus>(
                                    value: OrderStatus.dispatched,
                                    child: Text('Despacho'),
                                  ),
                                  DropdownMenuItem<OrderStatus>(
                                    value: OrderStatus.delivered,
                                    child: Text('Entregado'),
                                  ),
                                  DropdownMenuItem<OrderStatus>(
                                    value: OrderStatus.confirmed,
                                    child: Text('Confirmado'),
                                  ),
                                  DropdownMenuItem<OrderStatus>(
                                    value: OrderStatus.cancelled,
                                    child: Text('Cancelado'),
                                  ),
                                ],
                                onChanged: _saving
                                    ? null
                                    : (OrderStatus? value) {
                                        if (value == null) return;
                                        setState(
                                          () => _selectedStatus = value,
                                        );
                                      },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _notesCtrl,
                                enabled: !_saving,
                                minLines: 3,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  labelText: 'Observaciones / tracking',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              if (_order!.dispatchedAt != null) ...<Widget>[
                                const SizedBox(height: 10),
                                Text(
                                  'Despachado: ${_dateFmt.format(_order!.dispatchedAt!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.slate),
                                ),
                              ],
                              if (_order!.deliveredAt != null) ...<Widget>[
                                Text(
                                  'Entregado: ${_dateFmt.format(_order!.deliveredAt!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.slate),
                                ),
                              ],
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: _saving ? null : _saveLogistics,
                                icon: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save_rounded),
                                label: Text(
                                  _saving
                                      ? 'Guardando...'
                                      : 'Guardar seguimiento',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  OrderStatus _logisticsStatusOrFallback(OrderStatus current) {
    const Set<OrderStatus> allowed = <OrderStatus>{
      OrderStatus.preparing,
      OrderStatus.dispatched,
      OrderStatus.delivered,
      OrderStatus.confirmed,
      OrderStatus.cancelled,
    };
    if (allowed.contains(current)) return current;
    if (current == OrderStatus.pending) return OrderStatus.confirmed;
    return OrderStatus.preparing;
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.slate,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        emphasize ? FontWeight.w800 : FontWeight.w500,
                    color: emphasize ? AppColors.brandDark : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
