import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 0,
  );

  static final NumberFormat _indianFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  /// Formats amount into Indian format: ₹ 9,00,000 or ₹ 50,000
  static String format(double amount, {bool showDecimals = false, String symbol = '₹'}) {
    final hasFraction = (amount % 1 != 0) && showDecimals;
    final formatter = hasFraction ? _indianFormatWithDecimals : _indianFormat;
    final formatted = formatter.format(amount.abs());
    
    // Replace default symbol if customized
    String result = formatted;
    if (symbol != '₹') {
      result = formatted.replaceAll('₹', symbol);
    }
    
    if (amount < 0) {
      return '- $result';
    }
    return result;
  }

  /// Formats with explicit sign: + ₹ 1,20,000 or - ₹ 50,000
  static String formatWithSign(double amount, {String symbol = '₹'}) {
    final formatted = format(amount.abs(), symbol: symbol);
    if (amount > 0) {
      return '+ $formatted';
    } else if (amount < 0) {
      return '- $formatted';
    }
    return formatted;
  }

  /// Parses string into double
  static double parse(String input) {
    if (input.isEmpty) return 0.0;
    final cleaned = input.replaceAll('₹', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Format compact for charts: e.g. 50K, 1.2L, 9L
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      final val = amount / 100000;
      return '${val == val.toInt() ? val.toInt() : val.toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      final val = amount / 1000;
      return '${val == val.toInt() ? val.toInt() : val.toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
