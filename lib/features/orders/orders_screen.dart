import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/sales_order.dart';
import '../../services/sales_order_service.dart';
import '../../state/auth_controller.dart';
import '../../widgets/common.dart';
import 'order_detail_screen.dart';

/// Historial de órdenes de venta del cliente autenticado.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
    );
  }

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Stream<List<SalesOrder>> _stream;
  final SalesOrderService _service = const SalesOrderService();
  String? _userId;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _userId = context.read<AuthController>().user?.id;
    _stream = _service.getUserOrders(_userId);
  }

  void _retry() {
    setState(() => _stream = _service.getUserOrders(_userId));
  }

  @override
  Widget build(BuildContext context) {
    final double pad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: StreamBuilder<List<SalesOrder>>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<List<SalesOrder>> snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('No se pudieron cargar tus pedidos.'),
                    const SizedBox(height: 8),
                    Text('${snap.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<SalesOrder> orders = snap.data ?? const <SalesOrder>[];
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'Sin pedidos',
              message:
                  'Cuando una cotización se cierre como venta, '
                  'aparecerá aquí tu orden de venta.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 28),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final SalesOrder order = orders[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => OrderDetailScreen.open(context, order.id),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                order.orderNumber.isEmpty
                                    ? order.id
                                    : order.orderNumber,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            _StatusChip(status: order.statusEnum),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fecha: ${_dateFmt.format(order.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.slate,
                              ),
                        ),
                        Text(
                          'Actualizado: ${_dateFmt.format(order.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.slate,
                              ),
                        ),
                        if (order.assignedDriver.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            'Conductor: ${order.assignedDriver}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          Formatters.price(order.total),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.brandDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(order.statusEnum.clientMessage),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return AppColors.warning;
      case OrderStatus.preparing:
        return AppColors.brand;
      case OrderStatus.dispatched:
        return const Color(0xFF7C3AED);
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.clientTimelineLabel,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
