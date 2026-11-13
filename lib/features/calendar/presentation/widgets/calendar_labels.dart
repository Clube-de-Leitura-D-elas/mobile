import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// O intl devolve mês e dia da semana em minúsculas no pt ("agosto",
/// "segunda-feira"); no começo de título eles levam inicial maiúscula.
String _capitalized(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

String calendarMonthTitle(AppLocalizations l10n, CalendarMonth month) =>
    l10n.calendarMonthTitle(
      _capitalized(l10n.calendarMonthName(month.firstDay)),
      month.year,
    );

String calendarMonthSemantic(AppLocalizations l10n, DateTime month) =>
    _capitalized(l10n.calendarMonthSemantic(month));

String calendarSelectedDayTitle(AppLocalizations l10n, DateTime day) =>
    _capitalized(l10n.calendarSelectedDayTitle(day));
