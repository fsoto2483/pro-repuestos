// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

/// Popup abierto en el gesto del usuario (antes de operaciones async).
class WebPopup {
  WebPopup(this.window);

  final html.WindowBase window;

  bool get isAvailable => true;

  void redirect(String url) {
    window.location.href = url;
  }

  void close() {
    window.close();
  }
}

/// Abre una pestaña vacía de inmediato (debe llamarse en el clic del usuario).
WebPopup? openPopup() {
  final html.WindowBase opened = html.window.open('', '_blank');
  return WebPopup(opened);
}
