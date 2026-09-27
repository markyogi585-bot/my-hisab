import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy');
  static final DateFormat _dayMonth = DateFormat('dd MMM');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonthYear = DateFormat('MMM yyyy');
  static final DateFormat _time12Hour = DateFormat('h:mm a');
  static final DateFormat _dayMonthTime = DateFormat('dd MMM, h:mm a');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  static String toDayMonthYear(DateTime date) => _dayMonthYear.format(date);
  static String toDayMonth(DateTime date) => _dayMonth.format(date);
  static String toMonthYear(DateTime date) => _monthYear.format(date);
  static String toShortMonthYear(DateTime date) => _shortMonthYear.format(date);
  static String toTime12Hour(DateTime date) => _time12Hour.format(date);
  static String toDayMonthTime(DateTime date) => _dayMonthTime.format(date);
  static String toIsoDate(DateTime date) => _isoDate.format(date);

  /// Group key for dates: "27 Sep 2026"
  static String toDateGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    
    if (target == today) {
      return 'Today, ${_dayMonthYear.format(date)}';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_dayMonthYear.format(date)}';
    }
    return _dayMonthYear.format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
