import 'package:get/get.dart';

class LoggerController extends GetxController {
  final _logs = <String>[].obs;
  List<String> get logs => _logs;

  void addToLog(String message) {
    _logs.add(message);
    if (_logs.length > 500) {
      _logs.removeAt(0); // Remove the oldest log if the list exceeds 100 entries
    }
  }

  void clearLogs() {
    _logs.clear();
  }

  // Log a general message
  void log(String message) {
    final timestamp = DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]; // Get time only

    _printWithTimestamp('LOG', message, timestamp);
  }

  // Log an error message
  void error(String message) {
    final timestamp = DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]; // Get time only

    _printWithTimestamp('ERROR', message, timestamp);
  }

  // Log an info message
  void info(String message) {
    final timestamp = DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]; // Get time only

    _printWithTimestamp('INFO', message, timestamp);
  }

  // Private method to handle printing with a timestamp
  void _printWithTimestamp(String level, String message, String timestamp) {
    final formattedMessage = '[$timestamp] $level: $message';
    // print(formattedMessage); // print to the console
    addToLog(formattedMessage); // Add to the log list
  }

  // Custom print function
  void customPrint(Object? object) {
    final timestamp = DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]; // Get time only

    final message = object?.toString() ?? 'null';
    _printWithTimestamp('print', message, timestamp);
  }
}
