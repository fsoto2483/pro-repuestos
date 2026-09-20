import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../core/web/popup_stub.dart'
    if (dart.library.html) '../../core/web/popup_web.dart';
import '../../data/models/user_role.dart';
import '../../models/quote.dart';
import '../../services/quote_service.dart';
import '../../state/quotes_controller.dart';
import '../../widgets/common.dart';
import '../auth/auth_guard.dart';

/// CRM de cotizaciones para administradores.
class AdminQuotesScreen extends StatefulWidget {
  const AdminQuotesScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const AuthGuard(
          requiredRole: UserRole.admin,
          child: AdminQuotesScreen(),
        ),
      ),
    );
  }

  @override
  State<AdminQuotesScreen> createState() => _AdminQuotesScreenState();
}

class _AdminQuotesScreenState extends State<AdminQuotesScreen> {
  late QuoteService _service;
  late Stream<List<Quote>> _stream;
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  QuoteStatus? _statusFilter;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _service = context.read<QuotesController>().service;
    _stream = _service.getAllQuotes();
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
    setState(() => _stream = _service.getAllQuotes());
  }

  List<Quote> _applyFilters(List<Quote> all) {
    Iterable<Quote> list = all;
    if (_statusFilter != null) {
      list = list.where((Quote q) => q.statusEnum == _statusFilter);
    }
    if (_search.isNotEmpty) {
      list = list.where((Quote q) {
        final String haystack = <String>[
          q.quoteNumber,
          q.customerRazonSocial,
          q.customerDocument,
          q.customerName,
          q.customerPhone,
        ].join(' ').toLowerCase();
        return haystack.contains(_search);
      });
    }
    return list.toList();
  }

  Map<QuoteStatus, int> _counts(List<Quote> all) {
    final Map<QuoteStatus, int> map = <QuoteStatus, int>{
      for (final QuoteStatus s in QuoteStatus.values) s: 0,
    };
    for (final Quote q in all) {
      map[q.statusEnum] = (map[q.statusEnum] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final double pad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('GESTIÓN DE COTIZACIONES'),
      ),
      body: StreamBuilder<List<Quote>>(
        stream: _stream,
        builder: (BuildContext context, AsyncSnapshot<List<Quote>> snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              !snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorPane(
              message: 'No se pudieron cargar las cotizaciones.',
              detail: '${snap.error}',
              onRetry: _retry,
            );
          }

          final List<Quote> all = snap.data ?? const <Quote>[];
          final Map<QuoteStatus, int> counts = _counts(all);
          final List<Quote> filtered = _applyFilters(all);

          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _DashboardStrip(counts: counts),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por número, razón social, RUC o contacto',
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
                          _FilterChip(
                            label: 'Todos',
                            selected: _statusFilter == null,
                            onTap: () => setState(() => _statusFilter = null),
                          ),
                          _FilterChip(
                            label: 'Pendiente',
                            selected: _statusFilter == QuoteStatus.pending,
                            onTap: () => setState(
                              () => _statusFilter = QuoteStatus.pending,
                            ),
                          ),
                          _FilterChip(
                            label: 'Contactado',
                            selected: _statusFilter == QuoteStatus.contacted,
                            onTap: () => setState(
                              () => _statusFilter = QuoteStatus.contacted,
                            ),
                          ),
                          _FilterChip(
                            label: 'Negociación',
                            selected: _statusFilter == QuoteStatus.negotiation,
                            onTap: () => setState(
                              () => _statusFilter = QuoteStatus.negotiation,
                            ),
                          ),
                          _FilterChip(
                            label: 'Venta Cerrada',
                            selected: _statusFilter == QuoteStatus.won,
                            onTap: () => setState(
                              () => _statusFilter = QuoteStatus.won,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${filtered.length} de ${all.length} cotizaciones',
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
                        icon: Icons.request_quote_outlined,
                        title: 'Sin cotizaciones',
                        message:
                            'No hay resultados con los filtros actuales.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(pad, 8, pad, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final Quote quote = filtered[index];
                          return _QuoteCard(
                            quote: quote,
                            dateLabel: _dateFmt.format(quote.createdAt),
                            onTap: () => _AdminQuoteDetailScreen.open(
                              context,
                              quoteId: quote.id,
                              service: _service,
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

class _DashboardStrip extends StatelessWidget {
  const _DashboardStrip({required this.counts});

  final Map<QuoteStatus, int> counts;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _StatPill(
          label: 'Pendientes',
          value: counts[QuoteStatus.pending] ?? 0,
          color: AppColors.warning,
        ),
        _StatPill(
          label: 'Contactados',
          value: counts[QuoteStatus.contacted] ?? 0,
          color: AppColors.info,
        ),
        _StatPill(
          label: 'Negociación',
          value: counts[QuoteStatus.negotiation] ?? 0,
          color: AppColors.brand,
        ),
        _StatPill(
          label: 'Ventas Cerradas',
          value: counts[QuoteStatus.won] ?? 0,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.dateLabel,
    required this.onTap,
  });

  final Quote quote;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuoteStatus status = quote.statusEnum;
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
                      quote.quoteNumber.isEmpty
                          ? quote.id
                          : quote.quoteNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.slate,
                    ),
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.business_rounded,
                text: quote.customerRazonSocial.isEmpty
                    ? '—'
                    : quote.customerRazonSocial,
              ),
              _InfoRow(
                icon: Icons.badge_outlined,
                text: quote.customerDocument.isEmpty
                    ? '—'
                    : quote.customerDocument,
              ),
              _InfoRow(
                icon: Icons.person_outline_rounded,
                text: quote.customerName.isEmpty ? '—' : quote.customerName,
              ),
              _InfoRow(
                icon: Icons.phone_outlined,
                text: quote.customerPhone.isEmpty ? '—' : quote.customerPhone,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  Formatters.price(quote.total),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: AppColors.slate),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final QuoteStatus status;

  Color get _color {
    switch (status) {
      case QuoteStatus.pending:
        return AppColors.warning;
      case QuoteStatus.contacted:
        return AppColors.info;
      case QuoteStatus.quotationSent:
        return const Color(0xFF7C3AED);
      case QuoteStatus.negotiation:
        return AppColors.brand;
      case QuoteStatus.won:
        return AppColors.success;
      case QuoteStatus.lost:
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

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String message;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.slate,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

/// Detalle + seguimiento comercial de una cotización.
class _AdminQuoteDetailScreen extends StatefulWidget {
  const _AdminQuoteDetailScreen({
    required this.quoteId,
    required this.service,
  });

  final String quoteId;
  final QuoteService service;

  static Future<void> open(
    BuildContext context, {
    required String quoteId,
    required QuoteService service,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AdminQuoteDetailScreen(
          quoteId: quoteId,
          service: service,
        ),
      ),
    );
  }

  @override
  State<_AdminQuoteDetailScreen> createState() =>
      _AdminQuoteDetailScreenState();
}

class _AdminQuoteDetailScreenState extends State<_AdminQuoteDetailScreen> {
  Quote? _quote;
  Object? _error;
  bool _loading = true;
  bool _saving = false;
  bool _contacting = false;

  late QuoteStatus _selectedStatus;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    _selectedStatus = QuoteStatus.pending;
    _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Quote? quote = await widget.service.getQuote(widget.quoteId);
      if (!mounted) return;
      if (quote == null) {
        setState(() {
          _loading = false;
          _error = 'Cotización no encontrada.';
        });
        return;
      }
      _notesCtrl.text = quote.notes;
      setState(() {
        _quote = quote;
        _selectedStatus = quote.statusEnum;
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

  Future<void> _saveFollowUp() async {
    final Quote? quote = _quote;
    if (quote == null) return;
    setState(() => _saving = true);
    try {
      await widget.service.saveQuoteFollowUp(
        quoteId: quote.id,
        status: _selectedStatus.value,
        notes: _notesCtrl.text,
      );
      if (!mounted) return;
      _snack('Seguimiento guardado.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _snack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _contactClient() async {
    final Quote? quote = _quote;
    if (quote == null) return;

    final String phone = _normalizePhone(quote.customerPhone);
    if (phone.isEmpty) {
      _snack('El cliente no tiene teléfono registrado.');
      return;
    }

    final String contacto = quote.customerName.trim().isEmpty
        ? 'cliente'
        : quote.customerName.trim();
    final String number = quote.quoteNumber.trim().isEmpty
        ? quote.id
        : quote.quoteNumber.trim();

    final String message = 'Hola $contacto.\n'
        '\n'
        'Soy de REPUESTOS LCC.\n'
        '\n'
        'Estamos dando seguimiento a la cotización:\n'
        '\n'
        '$number\n'
        '\n'
        '¿Desea más información sobre los repuestos solicitados?\n'
        '\n'
        'Quedamos atentos.';

    final String url =
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    debugPrint('ADMIN WHATSAPP URL: $url');

    setState(() => _contacting = true);
    final WebPopup? popup = kIsWeb ? openPopup() : null;

    try {
      await widget.service.updateLastContact(quote.id);
      if (kIsWeb && popup != null) {
        popup.redirect(url);
      } else {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
      if (!mounted) return;
      _snack('WhatsApp abierto. Último contacto actualizado.');
      await _load();
    } catch (e) {
      popup?.close();
      if (!mounted) return;
      _snack('No se pudo abrir WhatsApp: $e');
    } finally {
      if (mounted) setState(() => _contacting = false);
    }
  }

  /// Normaliza teléfono a dígitos con código país Perú si aplica.
  String _normalizePhone(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('51') && digits.length >= 11) return digits;
    if (digits.length == 9) return '51$digits';
    return digits;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double pad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          _quote?.quoteNumber.isNotEmpty == true
              ? _quote!.quoteNumber
              : 'Detalle cotización',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorPane(
                  message: 'No se pudo cargar el detalle.',
                  detail: '$_error',
                  onRetry: _load,
                )
              : _quote == null
                  ? const EmptyState(
                      icon: Icons.request_quote_outlined,
                      title: 'Cotización no encontrada',
                      message: 'La cotización no existe o fue eliminada.',
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
                      children: <Widget>[
                        _SectionCard(
                          title: 'DATOS CLIENTE',
                          child: Column(
                            children: <Widget>[
                              _DetailRow(
                                'Razón Social',
                                _quote!.customerRazonSocial,
                              ),
                              _DetailRow(
                                'Nombre Comercial',
                                _quote!.customerNombreComercial,
                              ),
                              _DetailRow('RUC', _quote!.customerDocument),
                              _DetailRow('Contacto', _quote!.customerName),
                              _DetailRow('Teléfono', _quote!.customerPhone),
                              _DetailRow('Correo', _quote!.customerEmail),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'PRODUCTOS',
                          child: Column(
                            children: <Widget>[
                              for (final QuoteItem item in _quote!.items)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
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
                                            if (item.codigo.isNotEmpty)
                                              Text(
                                                item.codigo,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors.slate,
                                                    ),
                                              ),
                                            Text(
                                              'Cant: ${item.cantidad} · '
                                              '${Formatters.price(item.precioUnitario)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors.slate,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        Formatters.price(item.total),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'TOTALES',
                          child: Column(
                            children: <Widget>[
                              _DetailRow(
                                'Subtotal',
                                Formatters.price(_quote!.subtotal),
                              ),
                              _DetailRow('IGV', Formatters.price(_quote!.igv)),
                              _DetailRow(
                                'Total',
                                Formatters.price(_quote!.total),
                                emphasize: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'SEGUIMIENTO',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              DropdownButtonFormField<QuoteStatus>(
                                key: ValueKey<String>(
                                  'status-${_quote!.id}-$_selectedStatus',
                                ),
                                initialValue: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Estado',
                                  border: OutlineInputBorder(),
                                ),
                                items: QuoteStatus.values
                                    .map(
                                      (QuoteStatus s) =>
                                          DropdownMenuItem<QuoteStatus>(
                                        value: s,
                                        child: Text(s.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _saving
                                    ? null
                                    : (QuoteStatus? value) {
                                        if (value == null) return;
                                        setState(() => _selectedStatus = value);
                                      },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _notesCtrl,
                                enabled: !_saving,
                                minLines: 3,
                                maxLines: 6,
                                decoration: const InputDecoration(
                                  labelText: 'Observaciones internas',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              if (_quote!.lastContactAt != null) ...<Widget>[
                                const SizedBox(height: 10),
                                Text(
                                  'Último contacto: '
                                  '${DateFormat('dd/MM/yyyy HH:mm').format(_quote!.lastContactAt!)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.slate),
                                ),
                              ],
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: _saving ? null : _saveFollowUp,
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
                                      : 'Guardar Seguimiento',
                                ),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: _contacting ? null : _contactClient,
                                icon: const Icon(Icons.chat_rounded),
                                label: Text(
                                  _contacting
                                      ? 'Abriendo...'
                                      : 'CONTACTAR CLIENTE',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

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

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.emphasize = false});

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
