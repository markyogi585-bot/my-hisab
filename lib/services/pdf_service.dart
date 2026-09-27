import 'dart:typed_data';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/transaction_model.dart';

class PdfService {
  PdfService._();

  static Future<Uint8List> generateTransactionReport({
    required List<TransactionModel> transactions,
    required DateTimeRange dateRange,
    required double openingBalance,
    required double totalIncome,
    required double totalExpense,
    required double closingBalance,
    required Map<String, double> categoryBreakdown,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#3B82F6');
    final incomeColor = PdfColor.fromHex('#10B981');
    final expenseColor = PdfColor.fromHex('#EF4444');
    final darkHeader = PdfColor.fromHex('#1E293B');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MY HISAB',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Track • Manage • Grow',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'STATEMENT PERIOD',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${DateFormatter.toDayMonthYear(dateRange.start)} - ${DateFormatter.toDayMonthYear(dateRange.end)}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: darkHeader,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Generated: ${DateFormatter.toDayMonthYear(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Financial Summary Metrics Grid
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Opening Balance', CurrencyFormatter.format(openingBalance), darkHeader),
                  _buildSummaryItem('Total Income', '+ ${CurrencyFormatter.format(totalIncome)}', incomeColor),
                  _buildSummaryItem('Total Expense', '- ${CurrencyFormatter.format(totalExpense)}', expenseColor),
                  _buildSummaryItem('Closing Balance', CurrencyFormatter.format(closingBalance), primaryColor),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Category Breakdown Section
            if (categoryBreakdown.isNotEmpty) ...[
              pw.Text(
                'Expense by Category',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: darkHeader),
              ),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 12,
                runSpacing: 6,
                children: categoryBreakdown.entries.map((e) {
                  final percent = totalExpense > 0 ? ((e.value / totalExpense) * 100).toStringAsFixed(1) : '0';
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      '${e.key}: ${CurrencyFormatter.format(e.value)} ($percent%)',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 16),
            ],

            // Transaction Table
            pw.Text(
              'Itemized Transactions (${transactions.length})',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: darkHeader),
            ),
            pw.SizedBox(height: 8),

            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: darkHeader),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              data: [
                ['Date', 'Category', 'Title & Note', 'Type', 'Amount'],
                ...transactions.map((t) => [
                  '${DateFormatter.toDayMonthYear(t.dateTime)}\n${DateFormatter.toTime12Hour(t.dateTime)}',
                  t.categoryName,
                  '${t.title}${t.description.isNotEmpty ? '\n${t.description}' : ''}',
                  t.type.shortName,
                  '${t.isIncome ? '+' : '-'} ${CurrencyFormatter.format(t.amount)}',
                ]),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'My Hisab - Complete Personal & Business Ledger',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
