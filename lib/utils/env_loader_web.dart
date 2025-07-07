import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('window.env')
external JSObject? get _env;

String? getApiUrlFromEnv() {
  final env = _env;
  if (env != null) {
    final apiUrl = env.getProperty('API_URL'.toJS) as String?;
    return apiUrl;
  }
  return null;
}
