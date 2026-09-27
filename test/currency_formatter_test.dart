import 'package:flutter_test/flutter_test.dart';
import 'package:my_hisab/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formats numbers into Indian numbering system correctly', () {
      expect(CurrencyFormatter.format(900000).replaceAll('\u00A0', ' '), contains('9,00,000'));
      expect(CurrencyFormatter.format(50000).replaceAll('\u00A0', ' '), contains('50,000'));
      expect(CurrencyFormatter.format(120000).replaceAll('\u00A0', ' '), contains('1,20,000'));
    });

    test('formats with explicit positive/negative signs', () {
      final pos = CurrencyFormatter.formatWithSign(100000).replaceAll('\u00A0', ' ');
      final neg = CurrencyFormatter.formatWithSign(-50000).replaceAll('\u00A0', ' ');

      expect(pos.startsWith('+'), isTrue);
      expect(neg.startsWith('-'), isTrue);
    });

    test('parses Indian currency formatted text correctly', () {
      expect(CurrencyFormatter.parse('₹ 9,00,000'), equals(900000.0));
      expect(CurrencyFormatter.parse('50,000'), equals(50000.0));
      expect(CurrencyFormatter.parse(''), equals(0.0));
    });

    test('formats compact for charts', () {
      expect(CurrencyFormatter.formatCompact(50000), equals('50K'));
      expect(CurrencyFormatter.formatCompact(900000), equals('9L'));
      expect(CurrencyFormatter.formatCompact(10000000), equals('1.0Cr'));
    });
  });
}
