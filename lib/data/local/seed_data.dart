import '../../models/transaction_model.dart';
import '../../models/category_model.dart';

class SeedData {
  SeedData._();

  static const double initialBalance = 810000.0;

  static List<CategoryModel> get categories => CategoryModel.defaultCategories;

  static List<TransactionModel> get sampleTransactions {
    final now = DateTime.now();
    // September 2026 baseline for reference or relative to current date
    final baseYear = now.year;
    final baseMonth = now.month;

    return [
      TransactionModel(
        id: 'tx_seed_1',
        type: TransactionType.expense,
        amount: 50000.0,
        categoryId: 'construction',
        categoryName: 'Construction Material',
        title: 'Construction Material',
        description: 'Cement + Sand payment',
        dateTime: DateTime(baseYear, baseMonth, 27, 13, 43),
        createdAt: DateTime(baseYear, baseMonth, 27, 13, 43),
        updatedAt: DateTime(baseYear, baseMonth, 27, 13, 43),
      ),
      TransactionModel(
        id: 'tx_seed_2',
        type: TransactionType.income,
        amount: 100000.0,
        categoryId: 'client_payment',
        categoryName: 'Received from Client',
        title: 'Received from Client',
        description: 'Advance Payment',
        dateTime: DateTime(baseYear, baseMonth, 27, 11, 20),
        createdAt: DateTime(baseYear, baseMonth, 27, 11, 20),
        updatedAt: DateTime(baseYear, baseMonth, 27, 11, 20),
      ),
      TransactionModel(
        id: 'tx_seed_3',
        type: TransactionType.income,
        amount: 20000.0,
        categoryId: 'freelance',
        categoryName: 'Consultancy',
        title: 'Site Supervision Fee',
        description: 'Client consultation payment',
        dateTime: DateTime(baseYear, baseMonth, 26, 17, 30),
        createdAt: DateTime(baseYear, baseMonth, 26, 17, 30),
        updatedAt: DateTime(baseYear, baseMonth, 26, 17, 30),
      ),
      TransactionModel(
        id: 'tx_seed_4',
        type: TransactionType.expense,
        amount: 5000.0,
        categoryId: 'construction',
        categoryName: 'Labour Payment',
        title: 'Labour Payment',
        description: 'House Work',
        dateTime: DateTime(baseYear, baseMonth, 26, 16, 20),
        createdAt: DateTime(baseYear, baseMonth, 26, 16, 20),
        updatedAt: DateTime(baseYear, baseMonth, 26, 16, 20),
      ),
      TransactionModel(
        id: 'tx_seed_5',
        type: TransactionType.expense,
        amount: 10000.0,
        categoryId: 'construction',
        categoryName: 'Tiles Purchase',
        title: 'Tiles Purchase',
        description: 'Kitchen Tiles',
        dateTime: DateTime(baseYear, baseMonth, 26, 11, 35),
        createdAt: DateTime(baseYear, baseMonth, 26, 11, 35),
        updatedAt: DateTime(baseYear, baseMonth, 26, 11, 35),
      ),
      TransactionModel(
        id: 'tx_seed_6',
        type: TransactionType.expense,
        amount: 7000.0,
        categoryId: 'bills',
        categoryName: 'Electric Work',
        title: 'Electric Work',
        description: 'Wiring + Switch',
        dateTime: DateTime(baseYear, baseMonth, 25, 18, 12),
        createdAt: DateTime(baseYear, baseMonth, 25, 18, 12),
        updatedAt: DateTime(baseYear, baseMonth, 25, 18, 12),
      ),
      TransactionModel(
        id: 'tx_seed_7',
        type: TransactionType.expense,
        amount: 500.0,
        categoryId: 'food',
        categoryName: 'Food Expense',
        title: 'Food Expense',
        description: 'Lunch',
        dateTime: DateTime(baseYear, baseMonth, 25, 14, 30),
        createdAt: DateTime(baseYear, baseMonth, 25, 14, 30),
        updatedAt: DateTime(baseYear, baseMonth, 25, 14, 30),
      ),
      TransactionModel(
        id: 'tx_seed_8',
        type: TransactionType.expense,
        amount: 4500.0,
        categoryId: 'transport',
        categoryName: 'Transport',
        title: 'Transport',
        description: 'Material Delivery',
        dateTime: DateTime(baseYear, baseMonth, 25, 10, 10),
        createdAt: DateTime(baseYear, baseMonth, 25, 10, 10),
        updatedAt: DateTime(baseYear, baseMonth, 25, 10, 10),
      ),
    ];
  }
}
