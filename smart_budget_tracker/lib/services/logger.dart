import 'package:flutter/foundation.dart';

abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) {
    debugPrint("LOG: $message");
  }
}
