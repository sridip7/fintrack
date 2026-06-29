import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/models/transaction.dart';
import 'package:fintrack/models/category.dart';
import 'package:fintrack/providers/transaction_provider.dart';
import 'package:fintrack/services/database_service.dart';

// Fake database service for testing without initializing Hive
class FakeDatabaseService extends DatabaseService {
  final List<Transaction> mockTransactions;

  FakeDatabaseService(this.mockTransactions);

  @override
  Future<void> init() async {}

  @override
  Future<List<Transaction>> getTransactions(String email) async {
    return mockTransactions;
  }

  @override
  Future<void> saveTransaction(String email, Transaction transaction) async {}

  @override
  Future<void> deleteTransaction(String email, String id) async {}
}

void main() {
  group('Transaction Model Tests', () {
    test('toJson and fromJson serialization works correctly', () {
      final tx = Transaction(
        id: '123',
        title: 'Lunch',
        amount: 25.50,
        date: DateTime(2026, 6, 23),
        category: TransactionCategory.food,
        type: TransactionType.expense,
      );

      final json = tx.toJson();
      expect(json['id'], '123');
      expect(json['title'], 'Lunch');
      expect(json['amount'], 25.50);
      expect(json['date'], '2026-06-23T00:00:00.000');
      expect(json['category'], 'food');
      expect(json['type'], 'expense');

      final parsedTx = Transaction.fromJson(json);
      expect(parsedTx.id, tx.id);
      expect(parsedTx.title, tx.title);
      expect(parsedTx.amount, tx.amount);
      expect(parsedTx.date, tx.date);
      expect(parsedTx.category, tx.category);
      expect(parsedTx.type, tx.type);
    });

    test('copyWith modifications work correctly', () {
      final tx = Transaction(
        id: '123',
        title: 'Salary',
        amount: 2000.0,
        date: DateTime(2026, 6, 23),
        category: TransactionCategory.others,
        type: TransactionType.income,
      );

      final updatedTx = tx.copyWith(amount: 2500.0, title: 'Bonus');
      expect(updatedTx.id, '123');
      expect(updatedTx.title, 'Bonus');
      expect(updatedTx.amount, 2500.0);
      expect(updatedTx.type, TransactionType.income);
    });
  });

  group('TransactionProvider Calculations Tests', () {
    late List<Transaction> testTransactions;

    setUp(() {
      testTransactions = [
        Transaction(
          id: '1',
          title: 'Salary',
          amount: 3000.0,
          date: DateTime.now(),
          category: TransactionCategory.others,
          type: TransactionType.income,
        ),
        Transaction(
          id: '2',
          title: 'Groceries',
          amount: 150.0,
          date: DateTime.now(),
          category: TransactionCategory.food,
          type: TransactionType.expense,
        ),
        Transaction(
          id: '3',
          title: 'Uber rides',
          amount: 50.0,
          date: DateTime.now(),
          category: TransactionCategory.travel,
          type: TransactionType.expense,
        ),
        Transaction(
          id: '4',
          title: 'Electricity bill',
          amount: 100.0,
          date: DateTime.now(),
          category: TransactionCategory.bills,
          type: TransactionType.expense,
        ),
      ];
    });

    test('calculates correct total income, expenses, and balance', () async {
      final fakeDb = FakeDatabaseService(testTransactions);
      final provider = TransactionProvider(fakeDb);

      await provider.loadTransactions('test@example.com');

      expect(provider.totalIncome, 3000.0);
      expect(provider.totalExpenses, 300.0); // 150 + 50 + 100
      expect(provider.totalBalance, 2700.0); // 3000 - 300
    });

    test('calculates correct category breakdown for expenses only', () async {
      final fakeDb = FakeDatabaseService(testTransactions);
      final provider = TransactionProvider(fakeDb);

      await provider.loadTransactions('test@example.com');

      final breakdown = provider.categoryExpenses;
      expect(breakdown[TransactionCategory.food], 150.0);
      expect(breakdown[TransactionCategory.travel], 50.0);
      expect(breakdown[TransactionCategory.bills], 100.0);
      expect(breakdown[TransactionCategory.shopping], 0.0); // No shopping expense
      expect(breakdown[TransactionCategory.others], 0.0); // Income 'others' shouldn't count as expense
    });
  });
}
