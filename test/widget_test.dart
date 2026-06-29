import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fintrack/widgets/summary_card.dart';
import 'package:fintrack/providers/settings_provider.dart';
import 'package:fintrack/services/database_service.dart';

// Fake database service stub for setting configurations during widget testing
class FakeSettingsDatabaseService extends DatabaseService {
  @override
  Future<void> init() async {}

  @override
  String getThemeMode(String email) => 'system';

  @override
  String getThemePalette(String email) => 'indigo';

  @override
  String getCurrency(String email) => 'USD';
}

void main() {
  group('SummaryCard Widget Tests', () {
    late FakeSettingsDatabaseService fakeDb;
    late SettingsProvider settingsProvider;

    setUp(() {
      fakeDb = FakeSettingsDatabaseService();
      settingsProvider = SettingsProvider(fakeDb);
    });

    testWidgets('Renders balance, income, and expenses with correct formatting', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: SummaryCard(
                totalBalance: 2700.0,
                totalIncome: 3000.0,
                totalExpenses: 300.0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the section headers/titles are displayed
      expect(find.text('TOTAL BALANCE'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);

      // Verify formatted currency values are displayed correctly
      expect(find.text('\$2,700.00'), findsOneWidget);
      expect(find.text('\$3,000.00'), findsOneWidget);
      expect(find.text('\$300.00'), findsOneWidget);
    });

    testWidgets('Formats negative balance correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settingsProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: SummaryCard(
                totalBalance: -150.50,
                totalIncome: 50.0,
                totalExpenses: 200.50,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify negative sign is included in format
      expect(find.text('-\$150.50'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.text('\$200.50'), findsOneWidget);
    });
  });
}
