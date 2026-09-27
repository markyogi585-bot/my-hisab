import 'package:intl/intl.dart';

/// Production-grade Money class using integer minor units (paise for INR).
/// 1 Rupee = 100 Paise. ₹50,000 = 5,000,000 paise.
class Money implements Comparable<Money> {
  final int minorUnits;
  final String currency;

  const Money(this.minorUnits, {this.currency = 'INR'});

  factory Money.fromRupees(double rupees, {String currency = 'INR'}) {
    return Money((rupees * 100).round(), currency: currency);
  }

  factory Money.zero({String currency = 'INR'}) {
    return Money(0, currency: currency);
  }

  double get inRupees => minorUnits / 100.0;
  bool get isPositive => minorUnits > 0;
  bool get isNegative => minorUnits < 0;
  bool get isZero => minorUnits == 0;

  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return Money(minorUnits - other.minorUnits, currency: currency);
  }

  Money operator -() {
    return Money(-minorUnits, currency: currency);
  }

  Money operator *(num multiplier) {
    return Money((minorUnits * multiplier).round(), currency: currency);
  }

  Money abs() {
    return Money(minorUnits.abs(), currency: currency);
  }

  @override
  int compareTo(Money other) {
    return minorUnits.compareTo(other.minorUnits);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          minorUnits == other.minorUnits &&
          currency == other.currency;

  @override
  int get hashCode => minorUnits.hashCode ^ currency.hashCode;

  /// Formats according to Indian numbering system: ₹ 9,00,000 or ₹ 50,000
  String format({bool showDecimals = false, String symbol = '₹'}) {
    final absPaise = minorUnits.abs();
    final wholeRupees = absPaise ~/ 100;
    final paiseRemainder = absPaise % 100;

    final String baseFormatted = _formatIndianWhole(wholeRupees);
    final String sign = isNegative ? '- ' : '';

    if (showDecimals && paiseRemainder > 0) {
      final paiseStr = paiseRemainder.toString().padLeft(2, '0');
      return '$sign$symbol $baseFormatted.$paiseStr';
    }

    return '$sign$symbol $baseFormatted';
  }

  String formatWithSign({String symbol = '₹'}) {
    final formatted = format(symbol: symbol);
    if (isPositive) {
      return '+ $formatted';
    }
    return formatted;
  }

  static String _formatIndianWhole(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;

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
    return buffer.toString();
  }

  @override
  String toString() => format();
}
