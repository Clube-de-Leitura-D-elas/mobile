import 'package:equatable/equatable.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_group_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';

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

  /// Vem do backend: o card oferece "Solicitar participação" (ou "Pedir
  /// novamente") só quando é `true`.
  final bool canRequestParticipation;

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
    this.canRequestParticipation = false,
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

  /// Agendado e ainda não começou: só nele um pedido pendente ou recusado
  /// faz sentido no card.
  bool isOpenAt(DateTime now) =>
      status == CalendarMeetingStatus.scheduled && date.isAfter(now);

  /// O backend decide quem pode pedir (vínculo com o grupo, presença já
  /// registrada, recusa recente); o horário é conferido de novo porque o
  /// encontro pode começar com a tela aberta.
  bool canRequestParticipationAt(DateTime now) =>
      canRequestParticipation && isOpenAt(now);

  /// Depois de um pedido aceito: aguardando, sem nova ação.
  CalendarMeetingEntity asRequested() {
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
      guestStatus: CalendarGuestStatus.requested,
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
    canRequestParticipation,
  ];
}
