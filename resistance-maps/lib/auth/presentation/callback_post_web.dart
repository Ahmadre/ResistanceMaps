import 'dart:js_interop';
import 'package:web/web.dart' as web;

// Posts the full callback URL string to the opener/parent (as expected by flutter_web_auth_2)
Future<void> postCallbackUrlIfPossible() async {
  try {
    final href = web.window.location.href;
    const targetOrigin = '*';
    final opener = web.window.opener;
    if (opener != null) {
      (opener as web.Window).postMessage(href.toJS, targetOrigin.toJS);
      return;
    }
    final parent = web.window.parent;
    if (parent != null && !identical(parent, web.window)) {
      parent.postMessage(href.toJS, targetOrigin.toJS);
    }
  } catch (_) {}
}

Future<bool> detectPopupFlow() async {
  try {
    final opener = web.window.opener;
    final parent = web.window.parent;
    return opener != null || (parent != null && !identical(parent, web.window));
  } catch (_) {
    return false;
  }
}
