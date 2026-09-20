/// Estados comerciales de una cotización (CRM).
enum QuoteStatus {
  pending,
  contacted,
  quotationSent,
  negotiation,
  won,
  lost;

  String get value {
    switch (this) {
      case QuoteStatus.pending:
        return 'pending';
      case QuoteStatus.contacted:
        return 'contacted';
      case QuoteStatus.quotationSent:
        return 'quotation_sent';
      case QuoteStatus.negotiation:
        return 'negotiation';
      case QuoteStatus.won:
        return 'won';
      case QuoteStatus.lost:
        return 'lost';
    }
  }

  String get label {
    switch (this) {
      case QuoteStatus.pending:
        return 'Pendiente';
      case QuoteStatus.contacted:
        return 'Contactado';
      case QuoteStatus.quotationSent:
        return 'Cotización Enviada';
      case QuoteStatus.negotiation:
        return 'Negociación';
      case QuoteStatus.won:
        return 'Venta Cerrada';
      case QuoteStatus.lost:
        return 'No Interesado';
    }
  }

  static QuoteStatus fromString(String? raw) {
    final String value = (raw ?? '').trim().toLowerCase();
    switch (value) {
      case 'contacted':
        return QuoteStatus.contacted;
      case 'quotation_sent':
        return QuoteStatus.quotationSent;
      case 'negotiation':
        return QuoteStatus.negotiation;
      case 'won':
        return QuoteStatus.won;
      case 'lost':
        return QuoteStatus.lost;
      case 'pending':
      case 'saved':
      default:
        return QuoteStatus.pending;
    }
  }

  static const List<QuoteStatus> all = QuoteStatus.values;
}
