import 'dart:typed_data';

/// Descarga de PDF en plataformas no-web (no-op de Blob).
void downloadPdfBytes(Uint8List bytes, String filename) {
  throw UnsupportedError(
    'downloadPdfBytes (Blob) solo esta disponible en Flutter Web.',
  );
}
