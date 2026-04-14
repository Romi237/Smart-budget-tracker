import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_budget_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full app flow: open home, add expense, and return', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Smart Budget Tracker'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('amountField')), '250');
    await tester.enterText(find.byKey(const Key('noteField')), 'Integration expense');

    await tester.tap(find.byKey(const Key('saveExpenseButton')));
    await tester.pumpAndSettle();

    expect(find.text('Smart Budget Tracker'), findsOneWidget);
    expect(find.text('Expense added successfully!'), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 120)));
}
