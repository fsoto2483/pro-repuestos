import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/quote.dart';
import '../../state/auth_controller.dart';
import '../../state/quotes_controller.dart';
import '../../widgets/common.dart';

/// Historial de cotizaciones guardadas en el dispositivo.
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? userId = context.read<AuthController>().user?.id;
      context.read<QuotesController>().load(userId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final QuotesController quotes = context.watch<QuotesController>();
    final double gutter = context.horizontalPadding;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis cotizaciones')),
      body: SafeArea(
        child: ContentWidth(
          maxWidth: 820,
          child: quotes.loading && quotes.quotes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : quotes.quotes.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Sin cotizaciones',
                  message:
                      'Cuando confirmes una cotizacion desde el carrito, '
                      'aparecera aqui.',
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 28),
                  itemCount: quotes.quotes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final Quote quote = quotes.quotes[index];
                    return _QuoteTile(
                      quote: quote,
                      onTap: () => QuoteDetailScreen.open(context, quote.id),
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
                      quote.companyName.isEmpty
                          ? quote.customerName
                          : quote.companyName,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_dateFmt.format(quote.createdAt)} · '
                      '${Formatters.plural(quote.itemCount, 'referencia', 'referencias')}',
                      style: theme.textTheme.bodySmall,
                    ),
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
                    Text(quote.id, style: theme.textTheme.titleLarge),
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
                        if (quote.companyName.isNotEmpty) quote.companyName,
                      ],
                    ),
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
                        'IVA (${(quote.taxRate * 100).round()} %): '
                            '${Formatters.price(quote.taxAmount)}',
                        'Total: ${Formatters.price(quote.total)}',
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
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
                Text(item.productName, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${item.sku} · ${item.brandName}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text('x${item.quantity}', style: theme.textTheme.labelLarge),
              Text(
                Formatters.price(item.lineTotal),
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
