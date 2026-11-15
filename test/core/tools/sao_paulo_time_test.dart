import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/sao_paulo_time.dart';

void main() {
  group('toSaoPaulo', () {
    test('reads the São Paulo wall clock, three hours behind UTC', () {
      final result = toSaoPaulo(DateTime.utc(2026, 11, 13, 12, 30));

      expect(
        (result.year, result.month, result.day, result.hour, result.minute),
        (2026, 11, 13, 9, 30),
      );
    });

    test('goes back to the previous day before 03:00 UTC', () {
      final result = toSaoPaulo(DateTime.utc(2026, 11, 13, 2, 30));

      expect(
        (result.year, result.month, result.day, result.hour, result.minute),
        (2026, 11, 12, 23, 30),
      );
    });

    test('crosses the year at midnight UTC on January 1st', () {
      final result = toSaoPaulo(DateTime.utc(2027, 1, 1, 1));

      expect(
        (result.year, result.month, result.day, result.hour),
        (2026, 12, 31, 22),
      );
    });

    test('does not depend on the time zone of the input', () {
      final instant = DateTime.utc(2026, 11, 13, 2, 30);

      expect(toSaoPaulo(instant.toLocal()), toSaoPaulo(instant));
    });
  });

  test('saoPauloDayOf returns the São Paulo civil day at midnight', () {
    expect(
      saoPauloDayOf(DateTime.utc(2026, 11, 13, 2, 30)),
      DateTime(2026, 11, 12),
    );
  });
}
