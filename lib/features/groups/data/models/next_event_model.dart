import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
import 'package:mobile/features/groups/domain/entities/next_event_result.dart';

class NextEventResponseModel {
  const NextEventResponseModel({
    required this.event,
    required this.isInPreparation,
    required this.draftMeetingId,
  });

  factory NextEventResponseModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid next event response.');
    }

    final isInPreparation = json['is_in_preparation'];
    final draftMeetingId = json['draft_meeting_id'];
    if (isInPreparation is! bool ||
        (draftMeetingId != null && draftMeetingId is! String)) {
      throw const FormatException('Invalid next event response.');
    }
    if (isInPreparation && draftMeetingId == null) {
      throw const FormatException('Missing draft meeting id.');
    }

    final inner = json['next_event'];
    final event = inner == null ? null : NextEventModel.fromJson(inner);
    if (isInPreparation && event != null) {
      throw const FormatException(
        'A next event cannot be scheduled and in preparation.',
      );
    }

    return NextEventResponseModel(
      event: event,
      isInPreparation: isInPreparation,
      draftMeetingId: draftMeetingId as String?,
    );
  }

  final NextEventModel? event;
  final bool isInPreparation;
  final String? draftMeetingId;

  NextEventResult toDomain() {
    if (isInPreparation) {
      return NextEventResult.inPreparation(meetingId: draftMeetingId!);
    }
    final event = this.event;
    return event == null
        ? const NextEventResult.empty()
        : NextEventResult.loaded(event.toDomain());
  }
}

class NextEventModel extends NextEventEntity {
  const NextEventModel({
    required super.location,
    required super.date,
    required super.hostName,
    super.bookTitle,
    super.bookCoverUrl,
    super.id,
  });

  /// Desempacota o envelope `{ next_event: { ... } }` retornado pela edge
  /// function `get-group-next-event`.
  ///
  /// Retorna `null` quando `next_event` é `null` (grupo sem evento agendado).
  static NextEventModel? fromEnvelope(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid next event response.');
    }

    final inner = json['next_event'];
    if (inner == null) return null;

    return NextEventModel.fromJson(inner);
  }

  factory NextEventModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid next event response.');
    }

    final id = json['id'];
    final locationName = json['location_name'];
    final date = json['date'];
    final hostName = json['host_name'];
    final bookTitle = json['book_title'];
    final bookCoverUrl = json['book_cover_url'];

    if ((id != null && id is! String) ||
        date is! String ||
        hostName is! String ||
        (bookTitle != null && bookTitle is! String) ||
        (bookCoverUrl != null && bookCoverUrl is! String)) {
      throw const FormatException('Invalid next event response.');
    }
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) {
      throw const FormatException('Invalid next event date.');
    }

    return NextEventModel(
      id: id as String?,
      // location_name pode ser null quando o encontro não tem local definido.
      location: locationName is String ? locationName : '',
      date: parsedDate,
      hostName: hostName,
      bookTitle: bookTitle as String?,
      bookCoverUrl: bookCoverUrl as String?,
    );
  }

  NextEventEntity toDomain() {
    return NextEventEntity(
      id: id,
      location: location,
      date: date,
      hostName: hostName,
      bookTitle: bookTitle,
      bookCoverUrl: bookCoverUrl,
    );
  }
}
