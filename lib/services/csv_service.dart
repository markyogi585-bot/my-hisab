import 'package:csv/csv.dart';
import '../core/utils/date_formatter.dart';
import '../models/transaction_model.dart';

class CsvService {
  CsvService._();

  static String generateCsv(List<TransactionModel> transactions) {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'Transaction ID',
      'Date',
      'Time',
      'Type',
      'Category',
      'Title',
      'Description',
      'Amount',
    ]);

    for (final tx in transactions) {
      rows.add([
        tx.id,
        DateFormatter.toDayMonthYear(tx.dateTime),
        DateFormatter.toTime12Hour(tx.dateTime),
        tx.type.shortName,
        tx.categoryName,
        tx.title,
        tx.description,
        tx.amount,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
