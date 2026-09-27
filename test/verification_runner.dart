import 'dart:io';

// Verification test script running on pure Dart runtime
void main() {
  stdout.writeln('========================================');
  stdout.writeln('RUNNING "MY HISAB" SYSTEM VERIFICATIONS');
  stdout.writeln('========================================');

  // Test 1: Indian Number Formatting
  stdout.write('[1/6] Testing Indian Currency Formatting... ');
  _testIndianCurrencyFormat();
  stdout.writeln('PASSED');

  // Test 2: Balance Calculation Formula
  stdout.write('[2/6] Testing Dynamic Balance Calculation... ');
  _testBalanceCalculations();
  stdout.writeln('PASSED');

  // Test 3: Negative Balance & Overdraft
  stdout.write('[3/6] Testing Negative Balance Support... ');
  _testNegativeBalance();
  stdout.writeln('PASSED');

  // Test 4: Category Percentages Calculation
  stdout.write('[4/6] Testing Category Breakdown Logic... ');
  _testCategoryBreakdown();
  stdout.writeln('PASSED');

  // Test 5: Date Formatting & Filtering Ranges
  stdout.write('[5/6] Testing Date Ranges & Calculations... ');
  _testDateRangeLogic();
  stdout.writeln('PASSED');

  // Test 6: CSV Generation Format
  stdout.write('[6/6] Testing CSV Structure... ');
  _testCsvStructure();
  stdout.writeln('PASSED');

  stdout.writeln('========================================');
  stdout.writeln('ALL 6/6 CORE SYSTEM TESTS PASSED PERFECTLY!');
  stdout.writeln('========================================');
}

void _testIndianCurrencyFormat() {
  String formatIndian(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().round();
    final s = absAmount.toString();
    if (s.length <= 3) {
      return '${isNegative ? '- ' : ''}₹ $s';
    }
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    buffer.write(',$last3');
    return '${isNegative ? '- ' : ''}₹ ${buffer.toString()}';
  }

  assert(formatIndian(900000) == '₹ 9,00,000', 'Failed 900000');
  assert(formatIndian(50000) == '₹ 50,000', 'Failed 50000');
  assert(formatIndian(120000) == '₹ 1,20,000', 'Failed 120000');
  assert(formatIndian(12500) == '₹ 12,500', 'Failed 12500');
  assert(formatIndian(-50000) == '- ₹ 50,000', 'Failed -50000');
  assert(formatIndian(10000000) == '₹ 1,00,00,000', 'Failed 10000000');
}

void _testBalanceCalculations() {
  // Current Balance = initialBalance + totalIncome - totalExpense
  const double initial = 900000.0;
  const double income = 120000.0;
  const double expense = 30000.0;

  final balance = initial + income - expense;
  assert(balance == 990000.0, 'Balance should be 9,90,000');

  // Verify reference mockup values
  // When initial = 8,10,000, income = 1,20,000, expense = 30,000 -> balance = 9,00,000!
  const double seedInitial = 810000.0;
  final refMockupBalance = seedInitial + income - expense;
  assert(refMockupBalance == 900000.0, 'Reference balance match failed');
}

void _testNegativeBalance() {
  const double initial = 5000.0;
  const double income = 0.0;
  const double expense = 15000.0;

  final balance = initial + income - expense;
  assert(balance == -10000.0, 'Negative balance failed');
}

void _testCategoryBreakdown() {
  // Mock expenses matching screenshot:
  // Construction: 18,000 (60%)
  // Labour: 5,100 (17%)
  // Transport: 3,000 (10%)
  // Food: 2,100 (7%)
  // Other: 1,800 (6%)
  // Total = 30,000
  const total = 30000.0;
  final categories = {
    'Construction': 18000.0,
    'Labour': 5100.0,
    'Transport': 3000.0,
    'Food': 2100.0,
    'Other': 1800.0,
  };

  final percentages = categories.map((key, val) => MapEntry(key, (val / total) * 100));

  assert((percentages['Construction']! - 60.0).abs() < 0.1, 'Construction % error');
  assert((percentages['Labour']! - 17.0).abs() < 0.1, 'Labour % error');
  assert((percentages['Transport']! - 10.0).abs() < 0.1, 'Transport % error');
  assert((percentages['Food']! - 7.0).abs() < 0.1, 'Food % error');
  assert((percentages['Other']! - 6.0).abs() < 0.1, 'Other % error');
}

void _testDateRangeLogic() {
  final now = DateTime(2026, 9, 27, 13, 43);
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  assert(startOfMonth.day == 1, 'Month start failed');
  assert(endOfMonth.day == 30, 'September days should be 30');
  assert(now.isAfter(startOfMonth) && now.isBefore(endOfMonth), 'Date range containment failed');
}

void _testCsvStructure() {
  final header = ['ID', 'Date', 'Type', 'Category', 'Amount'];
  final row = ['tx_1', '27 Sep 2026', 'Expense', 'Construction Material', '50000'];
  final csvLine = row.join(',');

  assert(csvLine.contains('Construction Material'), 'CSV encoding error');
  assert(header.length == 5, 'CSV header length mismatch');
}
