import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/quote.dart';
import '../../services/quote_service.dart';
import '../../state/auth_controller.dart';
import '../../state/quotes_controller.dart';
import '../../widgets/common.dart';

/// Historial de cotizaciones — fuente única: stream de Firestore.
class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const QuotesScreen()),
    );
  }

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  late Stream<List<Quote>> _quotesStream;
  String? _userId;
  late QuoteService _service;

  @override
  void initState() {
    super.initState();
    _userId = context.read<AuthController>().user?.id;
    _service = context.read<QuotesController>().service;
    _quotesStream = _service.watchUserQuotes(_userId);
  }

  void _retry() {
    setState(() {
      _quotesStream = _service.watchUserQuotes(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = context.horizontalPadding;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis cotizaciones')),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 820,
          child: StreamBuilder<List<Quote>>(
            stream: _quotesStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<Quote>> snapshot,
            ) {
              if (snapshot.hasError) {
                return EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Error',
                  message: 'No se pudieron cargar las cotizaciones.',
                  actionLabel: 'Reintentar',
                  onAction: _retry,
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Quote> quotes = snapshot.data ?? const <Quote>[];

              if (quotes.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sin cotizaciones',
                  message:
                      'Cuando guardes una cotizacion desde el carrito, '
                      'aparecera aqui.',
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 28),
                itemCount: quotes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Quote quote = quotes[index];
                  return _QuoteTile(
                    quote: quote,
                    onTap: () => QuoteDetailScreen.open(context, quote.id),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuoteTile extends StatelessWidget {
  const _QuoteTile({required this.quote, required this.onTap});

  final Quote quote;
  final VoidCallback onTap;

  static final DateFormat _dateFmt = DateFormat('d MMM yyyy · HH:mm', 'es');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      quote.quoteNumber.isNotEmpty
                          ? quote.quoteNumber
                          : quote.customerName,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_dateFmt.format(quote.createdAt)} · '
                      '${Formatters.plural(quote.itemCount, 'referencia', 'referencias')}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (quote.customerName.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        quote.customerName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                Formatters.price(quote.total),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class QuoteDetailScreen extends StatefulWidget {
  const QuoteDetailScreen({super.key, required this.quoteId});

  final String quoteId;

  static Future<void> open(BuildContext context, String quoteId) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QuoteDetailScreen(quoteId: quoteId),
      ),
    );
  }

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  Quote? _quote;
  bool _loading = true;

  static final DateFormat _dateFmt = DateFormat('d MMMM yyyy · HH:mm', 'es');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final Quote? quote = await context.read<QuotesController>().fetchById(
          widget.quoteId,
        );
    if (!mounted) return;
    setState(() {
      _quote = quote;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double gutter = context.horizontalPadding;
    final Quote? quote = _quote;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cotizacion')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : quote == null
                ? const EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'No encontrada',
                    message: 'Esta cotizacion ya no esta disponible.',
                  )
                : ContentWidth(
                    maxWidth: 820,
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 28),
                      children: <Widget>[
                        Text(
                          quote.quoteNumber.isNotEmpty
                              ? quote.quoteNumber
                              : quote.id,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dateFmt.format(quote.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 18),
                        _InfoCard(
                          title: 'Cliente',
                          lines: <String>[
                            quote.customerName,
                            if (quote.customerPhone.isNotEmpty)
                              quote.customerPhone,
                            quote.customerEmail,
                          ],
                        ),
                        if (_hasVehicle(quote)) ...<Widget>[
                          const SizedBox(height: 16),
                          _InfoCard(
                            title: 'Vehiculo',
                            lines: <String>[
                              if (quote.vehicleBrand.isNotEmpty)
                                quote.vehicleBrand,
                              if (quote.vehicleModel.isNotEmpty)
                                quote.vehicleModel,
                              if (quote.vehicleYear.isNotEmpty)
                                quote.vehicleYear,
                              if (quote.vehicleEngine.isNotEmpty)
                                quote.vehicleEngine,
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text('Productos', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        ...quote.items.map(
                          (QuoteItem item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ItemCard(item: item),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _InfoCard(
                          title: 'Totales',
                          lines: <String>[
                            'Subtotal: ${Formatters.price(quote.subtotal)}',
                            'IGV: ${Formatters.price(quote.igv)}',
                            'Total: ${Formatters.price(quote.total)}',
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  bool _hasVehicle(Quote quote) =>
      quote.vehicleBrand.isNotEmpty ||
      quote.vehicleModel.isNotEmpty ||
      quote.vehicleYear.isNotEmpty ||
      quote.vehicleEngine.isNotEmpty;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final String line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: theme.textTheme.bodyMedium),
            ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final QuoteItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.descripcion, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(item.codigo, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('x${item.cantidad}', style: theme.textTheme.labelLarge),
              Text(
                Formatters.price(item.total),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
