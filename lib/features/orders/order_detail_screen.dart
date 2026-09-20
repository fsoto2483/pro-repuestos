import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/sales_order.dart';
import '../../services/sales_order_service.dart';

/// Detalle de pedido para el cliente (timeline + logística solo lectura).
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  static Future<void> open(BuildContext context, String orderId) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailScreen(orderId: orderId),
      ),
    );
  }

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final SalesOrderService _service = const SalesOrderService();
  SalesOrder? _order;
  Object? _error;
  bool _loading = true;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final SalesOrder? order = await _service.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _loading = false;
        if (order == null) _error = 'Pedido no encontrado.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
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
              : 'Detalle del pedido',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _order == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _error?.toString() ?? 'Pedido no encontrado.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
                  children: <Widget>[
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'OV',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.slate),
                          ),
                          Text(
                            _order!.orderNumber,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _order!.statusEnum.clientMessage,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Estado: ${_order!.statusEnum.clientTimelineLabel}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Actualizado: ${_dateFmt.format(_order!.updatedAt)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.slate),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${Formatters.price(_order!.total)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.brandDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Logística',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          _InfoLine(
                            'Conductor',
                            _order!.assignedDriver.isEmpty
                                ? 'Por asignar'
                                : _order!.assignedDriver,
                          ),
                          _InfoLine(
                            'Teléfono',
                            _order!.driverPhone.isEmpty
                                ? '—'
                                : _order!.driverPhone,
                          ),
                          _InfoLine(
                            'Vehículo',
                            _order!.vehiclePlate.isEmpty
                                ? '—'
                                : _order!.vehiclePlate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Seguimiento',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 16),
                          if (_order!.statusEnum == OrderStatus.cancelled)
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.danger,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _order!.statusEnum.clientMessage,
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            _ClientTimeline(current: _order!.statusEnum),
                        ],
                      ),
                    ),
                    if (_order!.trackingNotes.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 14),
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Notas de seguimiento',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(_order!.trackingNotes),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Productos',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
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
                                    ),
                                  ),
                                  Text(
                                    'x${item.cantidad}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.slate),
                                  ),
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
                          Row(
                            children: <Widget>[
                              const Expanded(child: Text('Total')),
                              Text(
                                Formatters.price(_order!.total),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.brandDark,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

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
      child: child,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.slate,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ClientTimeline extends StatelessWidget {
  const _ClientTimeline({required this.current});

  final OrderStatus current;

  @override
  Widget build(BuildContext context) {
    final int currentIndex = current.clientTimelineIndex;

    return Column(
      children: <Widget>[
        for (int i = 0; i < OrderStatus.clientTimeline.length; i++)
          _Step(
            status: OrderStatus.clientTimeline[i],
            state: i < currentIndex
                ? _StepState.done
                : i == currentIndex
                    ? _StepState.active
                    : _StepState.pending,
            isLast: i == OrderStatus.clientTimeline.length - 1,
          ),
      ],
    );
  }
}

enum _StepState { done, active, pending }

class _Step extends StatelessWidget {
  const _Step({
    required this.status,
    required this.state,
    required this.isLast,
  });

  final OrderStatus status;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    switch (state) {
      case _StepState.done:
        color = AppColors.success;
        icon = Icons.check_circle_rounded;
      case _StepState.active:
        color = AppColors.warning;
        icon = Icons.radio_button_checked_rounded;
      case _StepState.pending:
        color = AppColors.slateLight;
        icon = Icons.radio_button_unchecked_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(icon, color: color, size: 26),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: state == _StepState.done
                        ? AppColors.success.withValues(alpha: 0.4)
                        : AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    status.clientTimelineLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: state == _StepState.pending
                              ? AppColors.slateLight
                              : AppColors.ink,
                        ),
                  ),
                  if (state != _StepState.pending)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        status.clientMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.slate,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
