import 'package:equatable/equatable.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_group_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';

class CalendarMeetingEntity extends Equatable {
  final String id;

  /// Instante do encontro; a tela mostra a hora de São Paulo.
  final DateTime date;

  /// Dia civil de São Paulo do encontro, à meia-noite local. É a chave do dia
  /// na grade: não derive de [date], que em UTC pode cair no dia seguinte.
  final DateTime localDate;

  final CalendarMeetingStatus status;

  final String? locationName;
  final String? locationAddress;
  final String? neighborhood;
  final String? hostName;
  final CalendarGroupEntity group;

  /// Pedido de participação da leitora; sempre `null` para membro.
  final CalendarGuestStatus? guestStatus;

  const CalendarMeetingEntity({
    required this.id,
    required this.date,
    required this.localDate,
    required this.status,
    required this.group,
    this.locationName,
    this.locationAddress,
    this.neighborhood,
    this.hostName,
    this.guestStatus,
  });

  /// Nome do local para membro; para não-membro o backend só manda o bairro.
  /// `null` quando não há nada para mostrar.
  String? get placeLabel {
    for (final value in [locationName, neighborhood, group.cityState]) {
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  bool get isDraft => status == CalendarMeetingStatus.created;

  /// Para os filtros: começou e ainda não acabou conta como próximo.
  bool isUpcomingAt(DateTime now) =>
      status == CalendarMeetingStatus.inProgress || !date.isBefore(now);

  /// Encontro agendado e futuro de grupo com o qual a leitora não tem
  /// vínculo: o card mostra o pedido de participação. O backend recusa quem
  /// tem qualquer vínculo ou pedido de entrada no grupo, e encontro em
  /// andamento (diferente de [isUpcomingAt]).
  bool acceptsGuestRequestAt(DateTime now) =>
      group.membershipStatus == CalendarMembershipStatus.none &&
      status == CalendarMeetingStatus.scheduled &&
      date.isAfter(now);

  bool canRequestParticipationAt(DateTime now) =>
      acceptsGuestRequestAt(now) &&
      (guestStatus == null || guestStatus == CalendarGuestStatus.rejected);

  CalendarMeetingEntity copyWithGuestStatus(CalendarGuestStatus guestStatus) {
    return CalendarMeetingEntity(
      id: id,
      date: date,
      localDate: localDate,
      status: status,
      group: group,
      locationName: locationName,
      locationAddress: locationAddress,
      neighborhood: neighborhood,
      hostName: hostName,
      guestStatus: guestStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    localDate,
    status,
    locationName,
    locationAddress,
    neighborhood,
    hostName,
    group,
    guestStatus,
  ];
}
