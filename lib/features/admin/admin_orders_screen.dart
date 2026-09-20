import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/user_role.dart';
import '../../models/sales_order.dart';
import '../../services/sales_order_service.dart';
import '../../widgets/common.dart';
import '../auth/auth_guard.dart';
import 'admin_order_detail_screen.dart';

/// Administración de ventas y logística (órdenes de venta).
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const AuthGuard(
          requiredRole: UserRole.admin,
          child: AdminOrdersScreen(),
        ),
      ),
    );
  }

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

enum _LogisticsFilter { all, preparation, dispatch, delivered }

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final SalesOrderService _orderService = const SalesOrderService();
  late Stream<List<SalesOrder>> _ordersStream;
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  _LogisticsFilter _filter = _LogisticsFilter.all;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _money = NumberFormat.currency(
    locale: 'es_PE',
    symbol: r'S/',
    decimalDigits: 2,
    customPattern: '¤#,##0.00',
  );

  @override
  void initState() {
    super.initState();
    _ordersStream = _orderService.getAllOrders();
    _searchCtrl.addListener(() {
      setState(() => _search = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() => _ordersStream = _orderService.getAllOrders());
  }

  List<SalesOrder> _applyFilters(List<SalesOrder> all) {
    Iterable<SalesOrder> list = all;
    switch (_filter) {
      case _LogisticsFilter.all:
        break;
      case _LogisticsFilter.preparation:
        list = list.where((SalesOrder o) => o.statusEnum.isPreparationPhase);
      case _LogisticsFilter.dispatch:
        list = list.where(
          (SalesOrder o) => o.statusEnum == OrderStatus.dispatched,
        );
      case _LogisticsFilter.delivered:
        list = list.where(
          (SalesOrder o) => o.statusEnum == OrderStatus.delivered,
        );
    }
    if (_search.isNotEmpty) {
      list = list.where((SalesOrder o) {
        final String haystack = <String>[
          o.orderNumber,
          o.quoteNumber,
          o.displayRazonSocial,
          o.customerRuc,
          o.customerName,
          o.customerPhone,
          o.assignedDriver,
        ].join(' ').toLowerCase();
        return haystack.contains(_search);
      });
    }
    return list.toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final double pad = context.horizontalPadding;
    final DateTime now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('VENTAS Y LOGÍSTICA')),
      body: StreamBuilder<List<SalesOrder>>(
        stream: _ordersStream,
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
                    const Text('No se pudieron cargar las ventas.'),
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

          final List<SalesOrder> all = snap.data ?? const <SalesOrder>[];
          final List<SalesOrder> filtered = _applyFilters(all);

          double salesToday = 0;
          double salesMonth = 0;
          int pending = 0;
          int dispatched = 0;
          int delivered = 0;

          for (final SalesOrder o in all) {
            if (_isSameDay(o.createdAt, now)) {
              salesToday += o.total;
            }
            if (o.createdAt.year == now.year &&
                o.createdAt.month == now.month) {
              salesMonth += o.total;
            }
            if (o.statusEnum.isPreparationPhase) pending++;
            if (o.statusEnum == OrderStatus.dispatched) dispatched++;
            if (o.statusEnum == OrderStatus.delivered) delivered++;
          }

          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _Kpi(
                          label: 'Ventas Hoy',
                          value: _money.format(salesToday),
                          color: AppColors.brand,
                        ),
                        _Kpi(
                          label: 'Ventas Mes',
                          value: _money.format(salesMonth),
                          color: AppColors.info,
                        ),
                        _Kpi(
                          label: 'Pendientes',
                          value: '$pending',
                          color: AppColors.warning,
                        ),
                        _Kpi(
                          label: 'Despachados',
                          value: '$dispatched',
                          color: const Color(0xFF7C3AED),
                        ),
                        _Kpi(
                          label: 'Entregados',
                          value: '$delivered',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Buscar OV, cliente, RUC, conductor...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.line),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _Chip(
                            label: 'Todos',
                            selected: _filter == _LogisticsFilter.all,
                            onTap: () => setState(
                              () => _filter = _LogisticsFilter.all,
                            ),
                          ),
                          _Chip(
                            label: 'Preparación',
                            selected: _filter == _LogisticsFilter.preparation,
                            onTap: () => setState(
                              () => _filter = _LogisticsFilter.preparation,
                            ),
                          ),
                          _Chip(
                            label: 'Despacho',
                            selected: _filter == _LogisticsFilter.dispatch,
                            onTap: () => setState(
                              () => _filter = _LogisticsFilter.dispatch,
                            ),
                          ),
                          _Chip(
                            label: 'Entregado',
                            selected: _filter == _LogisticsFilter.delivered,
                            onTap: () => setState(
                              () => _filter = _LogisticsFilter.delivered,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${filtered.length} de ${all.length} órdenes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.slate,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.point_of_sale_outlined,
                        title: 'Sin ventas',
                        message:
                            'Cierra cotizaciones como Venta Cerrada para '
                            'generar órdenes de venta.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(pad, 8, pad, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final SalesOrder order = filtered[index];
                          return _OrderTile(
                            order: order,
                            dateLabel: _dateFmt.format(order.createdAt),
                            onTap: () => AdminOrderDetailScreen.open(
                              context,
                              orderId: order.id,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.slate,
                ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.brandSoft,
        labelStyle: TextStyle(
          color: selected ? AppColors.brandDark : AppColors.ink,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    required this.dateLabel,
    required this.onTap,
  });

  final SalesOrder order;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  _StatusBadge(status: order.statusEnum),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                order.displayRazonSocial.isEmpty
                    ? '—'
                    : order.displayRazonSocial,
              ),
              if (order.assignedDriver.isNotEmpty)
                Text(
                  'Conductor: ${order.assignedDriver}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.slate,
                      ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  Formatters.price(order.total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.brandDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

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
        status.label,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
