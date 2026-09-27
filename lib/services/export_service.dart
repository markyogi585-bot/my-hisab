import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/export_config.dart';
import '../models/transaction_model.dart';
import 'csv_service.dart';
import 'pdf_service.dart';

class ExportService {
  ExportService._();

  static Future<void> exportTransactions({
    required BuildContext context,
    required ExportConfig config,
    required List<TransactionModel> transactions,
    required double openingBalance,
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> categoryBreakdown,
  }) async {
    final range = config.effectiveDateRange;
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final closingBalance = openingBalance + totalIncome - totalExpense;

    String filePath;

    switch (config.format) {
      case ExportFormat.pdf:
        final pdfBytes = await PdfService.generateTransactionReport(
          transactions: transactions,
          dateRange: range,
          openingBalance: openingBalance,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          closingBalance: closingBalance,
          categoryBreakdown: categoryBreakdown,
        );
        filePath = '${tempDir.path}/My_Hisab_Report_$timestamp.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        break;

      case ExportFormat.csv:
        final csvContent = CsvService.generateCsv(transactions);
        filePath = '${tempDir.path}/My_Hisab_Transactions_$timestamp.csv';
        final file = File(filePath);
        await file.writeAsString(csvContent);
        break;

      case ExportFormat.txt:
        final txtContent = _generateTextReport(
          transactions: transactions,
          range: range,
          openingBalance: openingBalance,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          closingBalance: closingBalance,
        );
        filePath = '${tempDir.path}/My_Hisab_Statement_$timestamp.txt';
        final file = File(filePath);
        await file.writeAsString(txtContent);
        break;
    }

    final xFile = XFile(filePath);
    await Share.shareXFiles(
      [xFile],
      text: 'My Hisab Statement (${DateFormatter.toDayMonth(range.start)} - ${DateFormatter.toDayMonth(range.end)})',
      subject: 'My Hisab Exported Report',
    );
  }

  static String _generateTextReport({
    required List<TransactionModel> transactions,
    required DateTimeRange range,
    required double openingBalance,
    required double totalIncome,
    required double totalExpense,
    required double closingBalance,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('========================================');
    buffer.writeln('          MY HISAB STATEMENT            ');
    buffer.writeln('         Track • Manage • Grow          ');
    buffer.writeln('========================================');
    buffer.writeln('Period: ${DateFormatter.toDayMonthYear(range.start)} to ${DateFormatter.toDayMonthYear(range.end)}');
    buffer.writeln('Generated: ${DateFormatter.toDayMonthTime(DateTime.now())}');
    buffer.writeln('----------------------------------------');
    buffer.writeln('Opening Balance : ${CurrencyFormatter.format(openingBalance)}');
    buffer.writeln('Total Income    : + ${CurrencyFormatter.format(totalIncome)}');
    buffer.writeln('Total Expense   : - ${CurrencyFormatter.format(totalExpense)}');
    buffer.writeln('Closing Balance : ${CurrencyFormatter.format(closingBalance)}');
    buffer.writeln('========================================');
    buffer.writeln('TRANSACTIONS (${transactions.length})');
    buffer.writeln('----------------------------------------');

    for (final tx in transactions) {
      final sign = tx.isIncome ? '+' : '-';
      buffer.writeln(
        '${DateFormatter.toDayMonthTime(tx.dateTime)} | ${tx.type.shortName.toUpperCase()}',
      );
      buffer.writeln('${tx.title} [${tx.categoryName}]');
      if (tx.description.isNotEmpty) {
        buffer.writeln('Note: ${tx.description}');
      }
      buffer.writeln('Amount: $sign ${CurrencyFormatter.format(tx.amount)}');
      buffer.writeln('----------------------------------------');
    }

    buffer.writeln('End of report');
    return buffer.toString();
  }
}
