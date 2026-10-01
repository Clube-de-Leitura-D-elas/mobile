import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';

class NextEventModel extends NextEventEntity {
  const NextEventModel({
    required super.location,
    required super.date,
    required super.hostName,
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

    final locationName = json['location_name'];
    final date = json['date'];
    final hostName = json['host_name'];

    if (date is! String || hostName is! String) {
      throw const FormatException('Invalid next event response.');
    }
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) {
      throw const FormatException('Invalid next event date.');
    }

    return NextEventModel(
      // location_name pode ser null quando o encontro não tem local definido.
      location: locationName is String ? locationName : '',
      date: parsedDate,
      hostName: hostName,
    );
  }

  NextEventEntity toDomain() {
    return NextEventEntity(location: location, date: date, hostName: hostName);
  }
}
