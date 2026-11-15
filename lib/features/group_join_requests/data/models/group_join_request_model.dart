import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';

class GroupJoinRequestModel {
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;
  final DateTime? requestedAt;

  const GroupJoinRequestModel({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.requestedAt,
  });

  factory GroupJoinRequestModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final requestedAt = json['requested_at'] as String?;
    return GroupJoinRequestModel(
      id: json['group_user_id'] as String,
      userId: user['id'] as String,
      name: user['name'] as String,
      photoUrl: user['photo_url'] as String?,
      requestedAt: requestedAt == null ? null : DateTime.tryParse(requestedAt),
    );
  }

  /// Itens da resposta da `get-group-join-requests`: `{ "requests": [...] }`.
  static List<GroupJoinRequestModel> listFromJson(Map<String, dynamic> json) {
    final requests = json['requests'] as List<dynamic>;
    return [
      for (final request in requests)
        GroupJoinRequestModel.fromJson(request as Map<String, dynamic>),
    ];
  }

  GroupJoinRequestEntity toDomain() {
    return GroupJoinRequestEntity(
      id: id,
      userId: userId,
      name: name,
      photoUrl: photoUrl,
      requestedAt: requestedAt,
    );
  }
}
