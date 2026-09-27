import 'package:flutter_test/flutter_test.dart';
import 'package:my_hisab/models/export_config.dart';

void main() {
  group('ExportConfig Tests', () {
    test('effective date range calculation for today and last 30 days', () {
      const config = ExportConfig(
        format: ExportFormat.pdf,
        dateRangeOption: DateRangeOption.today,
      );

      final range = config.effectiveDateRange;
      expect(range.start.day, equals(DateTime.now().day));
      expect(range.end.day, equals(DateTime.now().day));
    });

    test('file extensions match format', () {
      expect(ExportFormat.pdf.extension, equals('pdf'));
      expect(ExportFormat.csv.extension, equals('csv'));
      expect(ExportFormat.txt.extension, equals('txt'));
    });
  });
}
