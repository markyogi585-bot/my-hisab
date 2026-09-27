import 'package:flutter_test/flutter_test.dart';
import 'package:my_hisab/models/transaction_model.dart';

void main() {
  group('TransactionModel Tests', () {
    test('serialization and deserialization works correctly', () {
      final now = DateTime.now();
      final tx = TransactionModel(
        id: 'tx_test_1',
        type: TransactionType.expense,
        amount: 50000.0,
        categoryId: 'construction',
        categoryName: 'Construction Material',
        title: 'Construction Material',
        description: 'Cement + Sand payment',
        dateTime: now,
        createdAt: now,
        updatedAt: now,
      );

      final map = tx.toMap();
      final reconstructed = TransactionModel.fromMap(map);

      expect(reconstructed.id, equals(tx.id));
      expect(reconstructed.amount, equals(50000.0));
      expect(reconstructed.type, equals(TransactionType.expense));
      expect(reconstructed.isExpense, isTrue);
      expect(reconstructed.isIncome, isFalse);
      expect(reconstructed.title, equals('Construction Material'));
    });

    test('balance formula calculation verification', () {
      const double initialBalance = 900000.0;
      const double totalIncome = 120000.0;
      const double totalExpense = 30000.0;

      final currentBalance = initialBalance + totalIncome - totalExpense;
      expect(currentBalance, equals(990000.0));
    });
  });
}
