import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/pdf/pdf_download_stub.dart'
    if (dart.library.html) '../core/pdf/pdf_download_web.dart' as pdf_download;
import '../models/company_info.dart';
import '../models/quote.dart';

/// Generación y descarga de PDF profesional de cotizaciones.
///
/// Encabezado = siempre [CompanyInfo.lcc] (REPUESTOS LCC).
/// Cliente = únicamente campos de la cotización (nunca Auth / workshop).
class PdfQuoteService {
  const PdfQuoteService();

  static const double _igvRate = 0.18;
  static const String _logoAsset = 'assets/images/logo_lcc.png';
  static const CompanyInfo _company = CompanyInfo.lcc;

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _money = NumberFormat.currency(
    locale: 'es_PE',
    symbol: r'S/ ',
    decimalDigits: 2,
  );

  static const PdfColor _brand = PdfColor.fromInt(0xFFFF5A1F);
  static const PdfColor _ink = PdfColor.fromInt(0xFF0D1117);
  static const PdfColor _slate = PdfColor.fromInt(0xFF637381);
  static const PdfColor _line = PdfColor.fromInt(0xFFE3E8EF);
  static const PdfColor _headerBg = PdfColor.fromInt(0xFF161C24);
  static const PdfColor _rowAlt = PdfColor.fromInt(0xFFF8F9FB);
  static const PdfColor _totalBg = PdfColor.fromInt(0xFFFFE9E0);

  Future<void> downloadQuotePdf(Quote quote) async {
    debugPrint('PDF STEP 1: downloadQuotePdf inicio');

    final Uint8List bytes = await generateQuotePdf(quote);
    debugPrint('PDF generado: ${bytes.length} bytes');

    final String number = quote.quoteNumber.trim().isNotEmpty
        ? quote.quoteNumber.trim()
        : resolveQuoteNumber(quote);
    final String filename = 'Cotizacion_$number.pdf';

    if (kIsWeb) {
      debugPrint('Descargando PDF Web');
      pdf_download.downloadPdfBytes(bytes, filename);
    } else {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    }
  }

  Future<Uint8List> generateQuotePdf(Quote quote) async {
    if (quote.id.isEmpty || quote.items.isEmpty) {
      throw Exception('Datos incompletos de cotización');
    }

    final String quoteNumber = quote.quoteNumber.trim().isNotEmpty
        ? quote.quoteNumber.trim()
        : resolveQuoteNumber(quote);
    if (quoteNumber.isEmpty) {
      throw Exception('Datos incompletos de cotización');
    }

    debugPrint(
      'PDF: vendedor=${_company.nombreComercial} / ${_company.razonSocial}',
    );
    debugPrint('CLIENTE PDF: ${quote.customer}');

    final _PdfFonts fonts = await _loadFonts();
    final pw.ImageProvider? logo = await _loadLogo();

    final double subtotal = _calcSubtotal(quote);
    final double igv = _round2(subtotal * _igvRate);
    final double total = _round2(subtotal + igv);

    final pw.Document pdf = pw.Document(
      title: 'Cotizacion $quoteNumber',
      author: _company.nombreComercial,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 40),
        theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
        footer: (pw.Context context) => _buildFooter(
          fonts: fonts,
          pageNumber: context.pageNumber,
          pageCount: context.pagesCount,
        ),
        build: (pw.Context context) => <pw.Widget>[
          _buildSellerHeader(
            company: _company,
            logo: logo,
            fonts: fonts,
            quoteNumber: quoteNumber,
            createdAt: quote.createdAt,
          ),
          pw.SizedBox(height: 14),
          pw.Container(height: 3, color: _brand),
          pw.SizedBox(height: 16),
          _buildClientBlock(quote: quote, fonts: fonts),
          pw.SizedBox(height: 20),
          _buildProductsTable(quote: quote, fonts: fonts),
          pw.SizedBox(height: 16),
          _buildTotals(
            subtotal: subtotal,
            igv: igv,
            total: total,
            fonts: fonts,
          ),
          pw.SizedBox(height: 20),
          _buildObservations(fonts: fonts),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text(
              'Gracias por su preferencia',
              style: pw.TextStyle(
                font: fonts.medium,
                fontSize: 10,
                color: _ink,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              _company.nombreComercial,
              style: pw.TextStyle(
                font: fonts.extraBold,
                fontSize: 11,
                color: _brand,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load(_logoAsset);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('PDF: logo no disponible: $e');
      return null;
    }
  }

  Future<_PdfFonts> _loadFonts() async {
    try {
      final ByteData regularData =
          await rootBundle.load('assets/fonts/Manrope-Regular.ttf');
      final ByteData mediumData =
          await rootBundle.load('assets/fonts/Manrope-Medium.ttf');
      final ByteData boldData =
          await rootBundle.load('assets/fonts/Manrope-Bold.ttf');
      final ByteData extraBoldData =
          await rootBundle.load('assets/fonts/Manrope-ExtraBold.ttf');
      return _PdfFonts(
        regular: pw.Font.ttf(regularData),
        medium: pw.Font.ttf(mediumData),
        bold: pw.Font.ttf(boldData),
        extraBold: pw.Font.ttf(extraBoldData),
      );
    } catch (e, s) {
      debugPrint('PDF: Manrope fallo ($e) → PdfGoogleFonts');
      debugPrintStack(stackTrace: s);
      final pw.Font regular = await PdfGoogleFonts.notoSansRegular();
      final pw.Font bold = await PdfGoogleFonts.notoSansBold();
      return _PdfFonts(
        regular: regular,
        medium: regular,
        bold: bold,
        extraBold: bold,
      );
    }
  }

  String resolveQuoteNumber(Quote quote) {
    final String existing = quote.quoteNumber.trim();
    if (existing.isNotEmpty) return existing;
    final String digits = quote.id.replaceAll(RegExp(r'[^0-9]'), '');
    final int n = digits.isEmpty
        ? (quote.createdAt.millisecondsSinceEpoch % 1000000)
        : int.parse(
            digits.length > 6 ? digits.substring(digits.length - 6) : digits,
          );
    return 'COT-${n.toString().padLeft(6, '0')}';
  }

  double _calcSubtotal(Quote quote) {
    if (quote.items.isEmpty) return _round2(quote.subtotal);
    final double sum = quote.items.fold<double>(
      0,
      (double acc, QuoteItem item) => acc + item.total,
    );
    return _round2(sum > 0 ? sum : quote.subtotal);
  }

  double _round2(double value) => (value * 100).roundToDouble() / 100;

  String _moneyOf(double value) => _money.format(value);

  /// Encabezado oscuro: siempre [CompanyInfo.lcc], nunca workshop/cliente/Auth.
  pw.Widget _buildSellerHeader({
    required CompanyInfo company,
    required pw.ImageProvider? logo,
    required _PdfFonts fonts,
    required String quoteNumber,
    required DateTime createdAt,
  }) {
    final List<pw.Widget> meta = <pw.Widget>[
      _headerLine(company.razonSocial, fonts.bold, emphasize: true),
      _headerLine('RUC: ${company.ruc}', fonts.regular),
      if (company.direccion.trim().isNotEmpty)
        _headerLine(company.direccion.trim(), fonts.regular),
      _headerLine('Tel: ${company.telefono}', fonts.regular),
      _headerLine('WhatsApp: ${company.whatsapp}', fonts.regular),
      _headerLine('Correo: ${company.correo}', fonts.regular),
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: pw.BoxDecoration(
        color: _headerBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                if (logo != null) ...<pw.Widget>[
                  pw.Container(
                    width: 56,
                    height: 56,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                  pw.SizedBox(width: 14),
                ],
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(
                        company.nombreComercial,
                        style: pw.TextStyle(
                          font: fonts.extraBold,
                          fontSize: 18,
                          color: PdfColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      ...meta,
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Container(
            width: 178,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: _brand, width: 1.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: <pw.Widget>[
                pw.Text(
                  'COTIZACION',
                  style: pw.TextStyle(
                    font: fonts.extraBold,
                    fontSize: 11,
                    color: _brand,
                    letterSpacing: 1.1,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  quoteNumber,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: fonts.extraBold,
                    fontSize: 11,
                    color: _ink,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(height: 1, color: _line),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Fecha:',
                  style: pw.TextStyle(
                    font: fonts.medium,
                    fontSize: 8,
                    color: _slate,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  _dateFmt.format(createdAt),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: fonts.bold,
                    fontSize: 10,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _headerLine(
    String text,
    pw.Font font, {
    bool emphasize = false,
    bool accent = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: emphasize ? 10 : 9,
          color: accent
              ? _brand
              : emphasize
                  ? PdfColors.white
                  : const PdfColor.fromInt(0xFFCBD5E1),
        ),
      ),
    );
  }

  /// Cliente = solo datos de la cotización. Layout en dos columnas.
  pw.Widget _buildClientBlock({
    required Quote quote,
    required _PdfFonts fonts,
  }) {
    String valueOrDash(String value) {
      final String v = value.trim();
      return v.isEmpty ? '-' : v;
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line, width: 1),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'DATOS DEL CLIENTE',
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 11,
              color: _brand,
              letterSpacing: 0.8,
            ),
          ),
          pw.SizedBox(height: 10),
          if (!quote.hasCustomerData)
            pw.Text(
              'CLIENTE NO REGISTRADO',
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 11,
                color: _slate,
              ),
            )
          else
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      _clientFieldRow(
                        'RAZON SOCIAL',
                        valueOrDash(quote.customerRazonSocial),
                        fonts,
                      ),
                      _clientFieldRow(
                        'NOMBRE COMERCIAL',
                        valueOrDash(quote.customerNombreComercial),
                        fonts,
                      ),
                      _clientFieldRow(
                        'RUC',
                        valueOrDash(quote.customerDocument),
                        fonts,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      _clientFieldRow(
                        'CONTACTO',
                        valueOrDash(quote.customerName),
                        fonts,
                      ),
                      _clientFieldRow(
                        'TELEFONO',
                        valueOrDash(quote.customerPhone),
                        fonts,
                      ),
                      _clientFieldRow(
                        'CORREO',
                        valueOrDash(quote.customerEmail),
                        fonts,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  pw.Widget _clientFieldRow(String label, String value, _PdfFonts fonts) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.SizedBox(
            width: 118,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                font: fonts.medium,
                fontSize: 8,
                color: _slate,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: fonts.bold,
                fontSize: 10,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProductsTable({
    required Quote quote,
    required _PdfFonts fonts,
  }) {
    final List<pw.TableRow> rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _headerBg),
        children: <pw.Widget>[
          _th('Codigo', fonts.bold),
          _th('Descripcion', fonts.bold),
          _th('Cantidad', fonts.bold, align: pw.TextAlign.center),
          _th('P. Unitario', fonts.bold, align: pw.TextAlign.right),
          _th('Subtotal', fonts.bold, align: pw.TextAlign.right),
        ],
      ),
    ];

    for (int i = 0; i < quote.items.length; i++) {
      final QuoteItem item = quote.items[i];
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i.isOdd ? _rowAlt : PdfColors.white,
          ),
          children: <pw.Widget>[
            _td(item.codigo.isEmpty ? '-' : item.codigo, fonts.regular),
            _td(
              item.descripcion.isEmpty ? '-' : item.descripcion,
              fonts.regular,
            ),
            _td(
              item.cantidad.toString(),
              fonts.medium,
              align: pw.TextAlign.center,
            ),
            _td(
              _moneyOf(item.precioUnitario),
              fonts.regular,
              align: pw.TextAlign.right,
            ),
            _td(
              _moneyOf(item.total),
              fonts.medium,
              align: pw.TextAlign.right,
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'DETALLE DE PRODUCTOS',
          style: pw.TextStyle(
            font: fonts.bold,
            fontSize: 11,
            color: _brand,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: _line, width: 0.8),
          columnWidths: const <int, pw.TableColumnWidth>{
            0: pw.FlexColumnWidth(1.4),
            1: pw.FlexColumnWidth(3.2),
            2: pw.FlexColumnWidth(1.0),
            3: pw.FlexColumnWidth(1.3),
            4: pw.FlexColumnWidth(1.3),
          },
          children: rows,
        ),
      ],
    );
  }

  pw.Widget _th(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.white),
      ),
    );
  }

  pw.Widget _td(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: 9, color: _ink),
      ),
    );
  }

  pw.Widget _buildTotals({
    required double subtotal,
    required double igv,
    required double total,
    required _PdfFonts fonts,
  }) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 230,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _line),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: <pw.Widget>[
            _totalRow('Subtotal:', _moneyOf(subtotal), fonts),
            pw.SizedBox(height: 4),
            _totalRow('IGV (18%):', _moneyOf(igv), fonts),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(
                color: _totalBg,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: _brand, width: 1.2),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: <pw.Widget>[
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(
                      font: fonts.extraBold,
                      fontSize: 12,
                      color: _brand,
                    ),
                  ),
                  pw.Text(
                    _moneyOf(total),
                    style: pw.TextStyle(
                      font: fonts.extraBold,
                      fontSize: 13,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value, _PdfFonts fonts) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(
          label,
          style: pw.TextStyle(
            font: fonts.regular,
            fontSize: 10,
            color: _slate,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: _ink),
        ),
      ],
    );
  }

  pw.Widget _buildObservations({required _PdfFonts fonts}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _rowAlt,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _line),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'OBSERVACIONES',
            style: pw.TextStyle(
              font: fonts.bold,
              fontSize: 10,
              color: _brand,
              letterSpacing: 0.6,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '- Precios expresados en Soles.\n'
            '- Cotizacion sujeta a disponibilidad de stock.\n'
            '- Validez de la cotizacion: 7 dias.',
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 9,
              color: _ink,
              lineSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter({
    required _PdfFonts fonts,
    required int pageNumber,
    required int pageCount,
  }) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Container(height: 1.2, color: _line),
        pw.SizedBox(height: 6),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Pagina $pageNumber de $pageCount',
            style: pw.TextStyle(
              font: fonts.regular,
              fontSize: 8,
              color: _slate,
            ),
          ),
        ),
      ],
    );
  }
}

class _PdfFonts {
  const _PdfFonts({
    required this.regular,
    required this.medium,
    required this.bold,
    required this.extraBold,
  });

  final pw.Font regular;
  final pw.Font medium;
  final pw.Font bold;
  final pw.Font extraBold;
}
