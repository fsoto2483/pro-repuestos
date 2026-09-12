import 'package:intl/intl.dart';

/// Formatos de texto compartidos por toda la app.
class Formatters {
  const Formatters._();

  /// `es_CO` pone el simbolo al final ("189.000 $"). En Colombia se escribe
  /// antes, asi que se fuerza el patron con `customPattern`.
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$',
    decimalDigits: 0,
    customPattern: '¤ #,##0',
  );

  static final NumberFormat _integer = NumberFormat.decimalPattern('es_CO');

  /// Precio con separador de miles: 189000 -> "$ 189.000".
  static String price(num value) => _currency.format(value);

  /// Cantidades: 1250 -> "1.250".
  static String quantity(num value) => _integer.format(value);

  /// Concuerda el sustantivo con el numero: 1 -> "1 referencia".
  static String plural(int count, String singular, String plural) =>
      '$count ${count == 1 ? singular : plural}';
}
