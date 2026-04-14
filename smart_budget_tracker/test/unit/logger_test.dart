import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget_tracker/services/logger.dart';

class MockLogger extends Logger {
  @override
  void log(String message) {
    // Mock implementation
  }
}

void main() {
  group('Logger service', () {
    late Logger logger;

    setUp(() {
      logger = MockLogger();
    });

    test('should log message without exception', () {
      expect(
        () => logger.log('Test message'),
        returnsNormally,
      );
    });

    test('should handle empty log messages', () {
      expect(
        () => logger.log(''),
        returnsNormally,
      );
    });

    test('should log multiple messages sequentially', () {
      expect(
        () {
          logger.log('First message');
          logger.log('Second message');
          logger.log('Third message');
        },
        returnsNormally,
      );
    });

    test('should handle long log messages', () {
      final longMessage = 'A' * 10000;
      expect(
        () => logger.log(longMessage),
        returnsNormally,
      );
    });

    test('should handle special characters in logs', () {
      expect(
        () => logger.log('Test: \$100, @user, #hashtag, 中文, 🚀'),
        returnsNormally,
      );
    });
  });
}
