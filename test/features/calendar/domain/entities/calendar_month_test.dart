import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';

void main() {
  group('CalendarMonth', () {
    test('starts the grid on the Sunday before the 1st and spans 42 days', () {
      // Agosto de 2026 começa num sábado.
      const month = CalendarMonth(2026, 8);

      expect(month.firstVisibleDay, DateTime(2026, 7, 26));
      expect(month.lastVisibleDay, DateTime(2026, 9, 5));
      expect(month.visibleDays, hasLength(CalendarMonth.visibleDayCount));
      expect(month.firstVisibleDay.weekday, DateTime.sunday);
      expect(month.lastVisibleDay.weekday, DateTime.saturday);
    });

    test('starts on the 1st itself when it is a Sunday', () {
      // Novembro de 2026 começa num domingo.
      const month = CalendarMonth(2026, 11);

      expect(month.firstVisibleDay, DateTime(2026, 11, 1));
      expect(month.lastVisibleDay, DateTime(2026, 12, 12));
    });

    test('moves across years', () {
      expect(
        const CalendarMonth(2026, 1).previous,
        const CalendarMonth(2025, 12),
      );
      expect(const CalendarMonth(2026, 12).next, const CalendarMonth(2027, 1));
      expect(
        CalendarMonth.of(DateTime(2026, 8, 31, 23)),
        const CalendarMonth(2026, 8),
      );
    });

    test('contains only the days of its own month', () {
      const month = CalendarMonth(2026, 8);

      expect(month.contains(DateTime(2026, 8, 1)), isTrue);
      expect(month.contains(DateTime(2026, 7, 31)), isFalse);
      expect(month.contains(DateTime(2025, 8, 1)), isFalse);
    });
  });
}
