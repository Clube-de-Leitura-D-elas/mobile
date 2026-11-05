import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';

class GroupParticipantModel extends GroupParticipantEntity {
  static const String coordinatorRole = 'coordinator';
  static const String hostRole = 'host';

  const GroupParticipantModel({
    required super.id,
    required super.name,
    super.photoUrl,
    super.isCoordinator,
    super.isHost,
  });

  factory GroupParticipantModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid group participant.');
    }

    final id = json['id'];
    final name = json['name'];
    final photoUrl = json['photo_url'];
    final role = json['role'];
    final isCoordinatorFlag = json['is_coordinator'];
    final isHostFlag = json['is_host'];

    if (id is! String ||
        name is! String ||
        (photoUrl != null && photoUrl is! String) ||
        (role != null && role is! String) ||
        (isCoordinatorFlag != null && isCoordinatorFlag is! bool) ||
        (isHostFlag != null && isHostFlag is! bool)) {
      throw const FormatException('Invalid group participant.');
    }

    final trimmedPhotoUrl = (photoUrl as String?)?.trim();

    return GroupParticipantModel(
      id: id,
      name: name.trim(),
      photoUrl: trimmedPhotoUrl == null || trimmedPhotoUrl.isEmpty
          ? null
          : trimmedPhotoUrl,
      isCoordinator: (isCoordinatorFlag as bool?) ?? (role == coordinatorRole),
      isHost: (isHostFlag as bool?) ?? (role == hostRole),
    );
  }

  /// Decodes `{ "participants": [ ... ] }`.
  static List<GroupParticipantModel> listFromJson(dynamic json) {
    if (json is! Map<String, dynamic> || json['participants'] is! List) {
      throw const FormatException('Invalid group participants response.');
    }

    return (json['participants'] as List)
        .map(GroupParticipantModel.fromJson)
        .toList();
  }

  GroupParticipantEntity toDomain() {
    return GroupParticipantEntity(
      id: id,
      name: name,
      photoUrl: photoUrl,
      isCoordinator: isCoordinator,
      isHost: isHost,
    );
  }
}
