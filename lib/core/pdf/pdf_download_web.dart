// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'package:flutter/foundation.dart';

/// Descarga de PDF en Flutter Web mediante HTML Blob + AnchorElement.
void downloadPdfBytes(Uint8List bytes, String filename) {
  debugPrint('Descargando PDF Web');
  final html.Blob blob = html.Blob(<dynamic>[bytes], 'application/pdf');
  final String url = html.Url.createObjectUrlFromBlob(blob);
  final html.AnchorElement anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
