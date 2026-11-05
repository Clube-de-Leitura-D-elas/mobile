import 'dart:math';

import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Data relativa da notificação; a partir de uma semana mostra a data completa.
String formatNotificationDate(
  AppLocalizations l10n, {
  required DateTime date,
  required DateTime now,
}) {
  final elapsed = now.difference(date);

  if (elapsed.inMinutes < 1) return l10n.notificationDateNow;
  if (elapsed.inHours < 1) {
    return l10n.notificationDateMinutes(elapsed.inMinutes);
  }
  if (elapsed.inDays < 1) return l10n.notificationDateHours(elapsed.inHours);

  final days = _calendarDaysBetween(date.toLocal(), now.toLocal());
  if (days < 7) return l10n.notificationDateDays(max(days, 1));
  return DateFormat('dd/MM/yyyy').format(date.toLocal());
}

// Compara em UTC para o horário de verão não mudar a duração do dia.
int _calendarDaysBetween(DateTime from, DateTime to) {
  final fromDay = DateTime.utc(from.year, from.month, from.day);
  final toDay = DateTime.utc(to.year, to.month, to.day);
  return toDay.difference(fromDay).inDays;
}
