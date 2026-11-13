import 'package:mobile/features/calendar/domain/entities/calendar_group_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';

/// Instante de [hour]:[minute] em São Paulo (UTC-3) no dia [day].
DateTime saoPauloInstant(DateTime day, int hour, [int minute = 0]) =>
    DateTime.utc(day.year, day.month, day.day, hour + 3, minute);

/// Encontro no dia civil [day] de São Paulo, às [hour]:[minute] de lá.
CalendarMeetingEntity calendarMeeting(
  String id, {
  required DateTime day,
  int hour = 19,
  int minute = 0,
  int groupNumber = 5,
  int participantCount = 27,
  CalendarMeetingStatus status = CalendarMeetingStatus.scheduled,
  CalendarMembershipStatus membership = CalendarMembershipStatus.member,
  String? cityState = 'Porto Alegre, RS',
  String? locationName,
  String? neighborhood,
  String? hostName,
  CalendarGuestStatus? guestStatus,
  bool canRequestParticipation = false,
}) {
  // Convidada aceita recebe local e anfitriã como membro.
  final isMember =
      membership == CalendarMembershipStatus.member ||
      guestStatus == CalendarGuestStatus.accepted;
  return CalendarMeetingEntity(
    id: id,
    date: saoPauloInstant(day, hour, minute),
    localDate: DateTime(day.year, day.month, day.day),
    status: status,
    locationName: isMember ? locationName : null,
    neighborhood: neighborhood,
    hostName: isMember ? hostName : null,
    guestStatus: guestStatus,
    canRequestParticipation: canRequestParticipation,
    group: CalendarGroupEntity(
      id: 'group-$id',
      number: groupNumber,
      cityState: cityState,
      participantCount: participantCount,
      membershipStatus: membership,
    ),
  );
}
