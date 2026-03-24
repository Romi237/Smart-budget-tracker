import 'package:flutter/foundation.dart';

class ErrorHandler {
  String handleError(dynamic error) {
    if (kDebugMode) {
      print('Error: $error');
    }

    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }

    return 'An unexpected error occurred';
  }

  void logError(String context, dynamic error) {
    if (kDebugMode) {
      print('Error in $context: $error');
    }
  }
}
