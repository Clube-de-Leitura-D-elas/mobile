import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';

class MeetingGuestRequestModel {
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;
  final DateTime? requestedAt;

  const MeetingGuestRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.requestedAt,
  });

  factory MeetingGuestRequestModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final requestedAt = json['requested_at'] as String?;
    return MeetingGuestRequestModel(
      id: json['request_id'] as String,
      userId: user['id'] as String,
      name: user['name'] as String,
      photoUrl: user['photo_url'] as String?,
      requestedAt: requestedAt == null ? null : DateTime.tryParse(requestedAt),
    );
  }

  /// Itens da resposta da `get-meeting-guest-requests`: `{ "requests": [...] }`.
  static List<MeetingGuestRequestModel> listFromJson(
    Map<String, dynamic> json,
  ) {
    final requests = json['requests'] as List<dynamic>;
    return [
      for (final request in requests)
        MeetingGuestRequestModel.fromJson(request as Map<String, dynamic>),
    ];
  }

  MeetingGuestRequestEntity toDomain() {
    return MeetingGuestRequestEntity(
      id: id,
      userId: userId,
      name: name,
      photoUrl: photoUrl,
      requestedAt: requestedAt,
    );
  }
}
