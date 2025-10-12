import 'dart:html' as html;

// Posts the full callback URL string to the opener/parent (as expected by flutter_web_auth_2)
Future<void> postCallbackUrlIfPossible() async {
  try {
    final href = html.window.location.href;
    // Ziel-Origin: '*' damit das öffnende Fenster die Nachricht auch bei anderem Port erhält
    const targetOrigin = '*';
    final opener = html.window.opener;
    if (opener != null) {
      opener.postMessage(href, targetOrigin);
      return;
    }
    final parent = html.window.parent;
    if (parent != null && parent != html.window) {
      parent.postMessage(href, targetOrigin);
      return;
    }
  } catch (_) {}
}

Future<bool> detectPopupFlow() async {
  try {
    final opener = html.window.opener;
    final parent = html.window.parent;
    return opener != null || (parent != null && parent != html.window);
  } catch (_) {
    return false;
  }
}
