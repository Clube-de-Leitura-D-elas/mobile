import 'package:flutter/foundation.dart';
import 'package:mobile/features/calendar/data/models/calendar_group_model.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';

class CalendarMeetingModel {
  final String id;
  final DateTime date;
  final DateTime localDate;
  final CalendarMeetingStatus status;
  final String? locationName;
  final String? locationAddress;
  final String? neighborhood;
  final String? hostName;
  final CalendarGroupModel group;

  const CalendarMeetingModel({
    required this.id,
    required this.date,
    required this.localDate,
    required this.status,
    required this.group,
    this.locationName,
    this.locationAddress,
    this.neighborhood,
    this.hostName,
  });

  factory CalendarMeetingModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return CalendarMeetingModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      // "YYYY-MM-DD" sem hora: o parse dá meia-noite local, o dia civil certo.
      localDate: DateTime.parse(json['local_date'] as String),
      status: _parseStatus(json['status']),
      locationName: location?['name'] as String?,
      locationAddress: location?['address'] as String?,
      neighborhood: location?['neighborhood'] as String?,
      hostName: json['host_name'] as String?,
      group: CalendarGroupModel.fromJson(json['group'] as Map<String, dynamic>),
    );
  }

  static CalendarMeetingStatus _parseStatus(dynamic value) {
    return switch (value) {
      'CREATED' => CalendarMeetingStatus.created,
      'SCHEDULED' => CalendarMeetingStatus.scheduled,
      'IN_PROGRESS' => CalendarMeetingStatus.inProgress,
      'ENDED' => CalendarMeetingStatus.ended,
      'CONCLUDED' => CalendarMeetingStatus.concluded,
      _ => CalendarMeetingStatus.unknown,
    };
  }

  /// Corpo da resposta da `get-city-calendar`: `{ "meetings": [...] }`.
  ///
  /// Um item malformado é descartado para não esconder o resto do mês.
  static List<CalendarMeetingModel> listFromJson(Map<String, dynamic> json) {
    final meetings = json['meetings'] as List<dynamic>? ?? const [];
    final models = <CalendarMeetingModel>[];
    for (final meeting in meetings) {
      try {
        models.add(
          CalendarMeetingModel.fromJson(meeting as Map<String, dynamic>),
        );
      } on TypeError catch (error) {
        debugPrint('[CalendarMeetingModel] item ignorado: $error');
      } on FormatException catch (error) {
        debugPrint('[CalendarMeetingModel] item ignorado: $error');
      }
    }
    return models;
  }

  CalendarMeetingEntity toDomain() {
    return CalendarMeetingEntity(
      id: id,
      date: date,
      localDate: localDate,
      status: status,
      locationName: locationName,
      locationAddress: locationAddress,
      neighborhood: neighborhood,
      hostName: hostName,
      group: group.toDomain(),
    );
  }
}
