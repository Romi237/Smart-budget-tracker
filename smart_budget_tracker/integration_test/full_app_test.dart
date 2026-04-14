import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_budget_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Integration Tests', () {
    testWidgets('User can navigate through all screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Smart Budget Tracker'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsWidgets);
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Complete expense add workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('amountField')), '150.00');
      await tester.enterText(find.byKey(const Key('noteField')), 'Integration test expense');

      await tester.tap(find.byKey(const Key('saveExpenseButton')));
      await tester.pumpAndSettle();

      expect(find.text('Smart Budget Tracker'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('User can view expense history', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final historyIcon = find.byIcon(Icons.history);
      if (historyIcon.evaluate().isNotEmpty) {
        await tester.tap(historyIcon);
        await tester.pumpAndSettle();

        expect(find.text('Expense History'), findsWidgets);
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Multiple expenses can be added sequentially', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('amountField')), '${50 + (i * 10)}.00');
        await tester.enterText(find.byKey(const Key('noteField')), 'Expense $i');

        await tester.tap(find.byKey(const Key('saveExpenseButton')));
        await tester.pumpAndSettle();
      }

      expect(find.text('Smart Budget Tracker'), findsOneWidget);
    }, timeout: const Timeout(Duration(minutes: 2)));

    testWidgets('App handles rapid button taps', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }

      expect(find.text('Smart Budget Tracker'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 120)));
  });
}
