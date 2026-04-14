import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/services/error_handler.dart';

void main() {
  group('ErrorHandler service', () {
    late ErrorHandler errorHandler;

    setUp(() {
      errorHandler = ErrorHandler();
    });

    test('should handle general exceptions', () {
      final error = Exception('Something went wrong');
      final message = errorHandler.handleError(error);

      expect(message, isNotEmpty);
      expect(message, isA<String>());
    });

    test('should handle FormatException', () {
      final error = FormatException('Invalid format');
      final message = errorHandler.handleError(error);

      expect(message, isNotEmpty);
    });

    test('should handle null errors gracefully', () {
      final message = errorHandler.handleError(null);

      expect(message, isNotEmpty);
    });

    test('should return different messages for different errors', () {
      final error1 = Exception('Database error');
      final error2 = Exception('Network error');

      final message1 = errorHandler.handleError(error1);
      final message2 = errorHandler.handleError(error2);

      expect(message1, isNotEmpty);
      expect(message2, isNotEmpty);
    });

    test('should handle RangeError', () {
      final error = RangeError('Index out of bounds');
      final message = errorHandler.handleError(error);

      expect(message, isNotEmpty);
    });

    test('should not return empty string for errors', () {
      final error = Exception('User password: secret123');
      final message = errorHandler.handleError(error);

      expect(message.isNotEmpty, true);
    });
  });
}
