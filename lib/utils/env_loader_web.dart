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

bool allowChangeServerFromEnv() {
  final env = _env;
  if (env != null) {
    final allowChangeServer = env.getProperty('ALLOW_CHANGE_SERVER_ON_ERROR'.toJS) as bool?;
    return allowChangeServer ?? true;
  }
  return false;
}
