import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/utils/formatters.dart';
import '../models/quote.dart';

/// Abre WhatsApp con el detalle de una cotización (flujo comercial).
class WhatsAppQuoteService {
  const WhatsAppQuoteService();

  /// Número destino configurable (Perú, con código de país).
  static const String whatsappNumber = '51928300562';

  /// Construye el mensaje prellenado con productos y total.
  static String buildMessage(Quote quote) {
    final String number = quote.quoteNumber.trim().isNotEmpty
        ? quote.quoteNumber.trim()
        : quote.id;

    final StringBuffer products = StringBuffer();
    for (final QuoteItem item in quote.items) {
      final String name = item.descripcion.trim().isNotEmpty
          ? item.descripcion.trim()
          : (item.codigo.trim().isNotEmpty ? item.codigo.trim() : 'Producto');
      products.writeln('- $name x ${item.cantidad}');
    }

    return 'Hola REPUESTOS LCC.\n'
        '\n'
        'Solicito atención para la siguiente cotización:\n'
        '\n'
        'Cotización:\n'
        '$number\n'
        '\n'
        'Productos solicitados:\n'
        '\n'
        '${products.toString()}'
        'Total:\n'
        '${Formatters.price(quote.total)}\n'
        '\n'
        'Gracias.';
  }

  /// URL completa `wa.me` con mensaje codificado.
  static String buildWhatsAppUrl(Quote quote) {
    final String message = buildMessage(quote);
    return 'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}';
  }

  /// Abre WhatsApp nativo / navegador (Android / iOS / desktop).
  static Future<bool> openQuoteWhatsApp(Quote quote) async {
    final String whatsappUrl = buildWhatsAppUrl(quote);
    debugPrint('WHATSAPP URL: $whatsappUrl');

    try {
      final bool launched = await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('WhatsApp: launchUrl devolvio false');
      }
      return launched;
    } catch (e, s) {
      debugPrint('WhatsApp ERROR: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }
}
