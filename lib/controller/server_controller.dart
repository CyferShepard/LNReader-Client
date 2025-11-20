import 'package:get/get.dart';
import 'package:light_novel_reader_client/classes/api.dart';
import 'package:light_novel_reader_client/globals.dart';
import 'package:light_novel_reader_client/utils/env_loader.dart'
    if (dart.library.js_interop) 'package:light_novel_reader_client/utils/env_loader_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerController extends GetxController {
  final _serverUrl = 'http://127.0.0.1:8000'.obs;
  String get serverUrl => _serverUrl.value;
  set serverUrl(String value) => _serverUrl.value = value;

  final _serverResponse = Rx<ServerResponse>(ServerResponse(success: false, message: ''));
  ServerResponse get serverResponse => _serverResponse.value;
  set serverResponse(ServerResponse value) => _serverResponse.value = value;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  final _canRegister = false.obs;
  bool get canRegister => _canRegister.value;
  set canRegister(bool value) => _canRegister.value = value;

  // WebSocketChannel? _channel;
  // WebSocketChannel? get channel => _channel;

//   endWsConnection() {
//     if (_channel != null) {
//       _channel!.sink.close();
//       _channel = null;
//       print('WebSocket connection closed');
//     }
//   }

//   Future<void> connectWebSocket({BuildContext? context}) async {
//     if (authController.auth.isAuthenticated == false) {
//       print('User is not authenticated, skipping WebSocket connection');
//       return;
//     }
//     _channel?.sink.close(); // Close previous connection if any
// // Parse the base server URL
//     Uri baseUri = Uri.parse(serverUrl);

//     // Build the WebSocket URI
//     final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
//     final wsUri = Uri(
//       scheme: wsScheme,
//       host: baseUri.host,
//       port: baseUri.hasPort ? baseUri.port : null,
//       path: '/wss',
//     );
//     print('Connecting to WebSocket: $wsUri');
//     _channel = WebSocketChannel.connect(
//       wsUri,
//       protocols: ['Bearer ${authController.auth.token}'],
//     );
//     await _channel!.ready;
//     _channel!.stream.listen(
//       (message) {
//         print('WebSocket message: $message');
//         if (context != null && context.mounted) {
//           try {
//             Map<String, dynamic> jsonMessage =
//                 message is String ? Map<String, dynamic>.from(jsonDecode(message)) : message as Map<String, dynamic>;
//             WebsocketToast.show(context, jsonMessage["message"], key: jsonMessage["type"]);
//           } catch (e) {
//             print('Error parsing WebSocket message: $e');
//             print(message);
//             WebsocketToast.show(context, 'Error parsing message', key: 'error');
//           }
//         }

//         // Handle incoming messages here
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//       },
//       onDone: () {
//         print('WebSocket closed');
//       },
//       cancelOnError: true,
//     );
//   }

  void setServerUrl(String url) {
    serverUrl = url;
  }

  Future<void> saveServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('serverUrl', serverUrl);
  }

  Future<void> loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    serverUrl = prefs.getString('serverUrl') ?? getApiUrlFromEnv() ?? 'http://127.0.0.1:8000';

    await connect();
  }

  Future<void> toggleRegistration() async {
    try {
      canRegister = await client.toggleRegistration(!canRegister) ?? canRegister;
    } catch (e) {
      print('Failed to toggle registration: $e');
    }
  }

  Future<void> connect() async {
    try {
      serverResponse = await client.ping(Uri.parse(serverUrl));
    } catch (e) {
      serverResponse = serverResponse.copyWith(
        success: false,
        message: 'Connection failed: $e',
      );
      print('Connection failed: $e');
    }

    if (!serverResponse.success) {
      serverUrlFieldKey.currentState?.errorText = serverResponse.message;
    } else {
      try {
        await saveServerUrl();
        client = ApiClient(baseUrl: serverUrl);
        canRegister = await client.canRegister();
      } catch (e) {
        print('Failed to save server URL: $e');
      }
    }
  }

  void disconnect() {
    serverResponse = serverResponse.copyWith(
      success: false,
      message: 'Disconnected from server',
    );
  }
}

class ServerResponse {
  bool success;
  String message;

  ServerResponse({
    required this.success,
    required this.message,
  });

  factory ServerResponse.fromJson(Map<String, dynamic> json) {
    return ServerResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }

  ServerResponse copyWith({
    required bool? success,
    required String? message,
  }) {
    return ServerResponse(
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }
}
