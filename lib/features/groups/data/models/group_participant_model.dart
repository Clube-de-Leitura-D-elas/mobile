import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';

class GroupParticipantModel extends GroupParticipantEntity {
  static const String coordinatorRole = 'coordinator';

  const GroupParticipantModel({
    required super.id,
    required super.name,
    super.photoUrl,
    super.isCoordinator,
  });

  factory GroupParticipantModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid group participant.');
    }

    final id = json['id'];
    final name = json['name'];
    final photoUrl = json['photo_url'];
    final role = json['role'];

    if (id is! String ||
        name is! String ||
        (photoUrl != null && photoUrl is! String) ||
        (role != null && role is! String)) {
      throw const FormatException('Invalid group participant.');
    }

    final trimmedPhotoUrl = (photoUrl as String?)?.trim();

    return GroupParticipantModel(
      id: id,
      name: name.trim(),
      photoUrl: trimmedPhotoUrl == null || trimmedPhotoUrl.isEmpty
          ? null
          : trimmedPhotoUrl,
      isCoordinator: role == coordinatorRole,
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
    );
  }
}
