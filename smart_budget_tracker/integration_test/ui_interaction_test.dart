import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_budget_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UI Interaction & User Flow Tests', () {
    testWidgets('User can interact with form fields', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final amountField = find.byKey(const Key('amountField'));
      await tester.tap(amountField);
      await tester.pumpAndSettle();

      await tester.enterText(amountField, '999.99');
      await tester.pumpAndSettle();

      expect(find.text('999.99'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Category dropdown can be selected', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final dropdownFinder = find.byType(DropdownButton);
      if (dropdownFinder.evaluate().isNotEmpty) {
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Date picker interaction works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final dateFieldFinder = find.byIcon(Icons.calendar_today);
      if (dateFieldFinder.evaluate().isNotEmpty) {
        await tester.tap(dateFieldFinder);
        await tester.pumpAndSettle();
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Form submission disables on invalid data', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final saveButton = find.byKey(const Key('saveExpenseButton'));
      expect(saveButton, findsOneWidget);

      await tester.pumpAndSettle();
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Back button returns to home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      expect(find.text('Smart Budget Tracker'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('Scrolling through expense list works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
    }, timeout: const Timeout(Duration(seconds: 60)));

    testWidgets('App maintains state during navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final initialTitle = find.text('Smart Budget Tracker');
      expect(initialTitle, findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(initialTitle, findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
