import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_relative_date.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;
  final now = DateTime(2026, 11, 5, 12);

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('pt', 'BR'));
  });

  String format(Duration age) =>
      formatNotificationDate(l10n, date: now.subtract(age), now: now);

  test('uses "agora" under a minute, even with a clock ahead', () {
    expect(format(const Duration(seconds: 59)), 'agora');
    expect(format(const Duration(minutes: -5)), 'agora');
  });

  test('uses minutes under an hour', () {
    expect(format(const Duration(minutes: 1)), 'há 1 min');
    expect(format(const Duration(minutes: 59)), 'há 59 min');
  });

  test('uses hours under a day', () {
    expect(format(const Duration(hours: 1)), 'há 1 h');
    expect(format(const Duration(hours: 23)), 'há 23 h');
  });

  test('uses days under a week', () {
    expect(format(const Duration(days: 1)), 'ontem');
    expect(format(const Duration(hours: 36)), 'ontem');
    expect(format(const Duration(hours: 37)), 'há 2 dias');
    expect(format(const Duration(days: 6)), 'há 6 dias');
    expect(format(const Duration(days: 6, hours: 13)), '29/10/2026');
  });

  test('uses the full local date from a week on', () {
    final date = now.subtract(const Duration(days: 7));

    expect(
      formatNotificationDate(l10n, date: date.toUtc(), now: now),
      DateFormat('dd/MM/yyyy').format(date),
    );
    expect(format(const Duration(days: 7)), '29/10/2026');
  });

  test('reads the UTC date of the backend in local time', () {
    expect(
      formatNotificationDate(
        l10n,
        date: DateTime(2026, 10, 3, 23, 30).toUtc(),
        now: now.toUtc(),
      ),
      '03/10/2026',
    );
    expect(
      formatNotificationDate(
        l10n,
        date: DateTime(2026, 11, 2, 23, 30).toUtc(),
        now: DateTime(2026, 11, 4, 12).toUtc(),
      ),
      'há 2 dias',
    );
  });
}
