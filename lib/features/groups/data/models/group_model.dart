import 'package:mobile/features/groups/domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.number,
    required super.participantsCount,
    required super.cityState,
    super.photoUrl,
  });

  factory GroupModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid group.');
    }

    final id = json['id'];
    final number = json['number'];
    final participantsCount = json['participant_count'];
    final cityState = json['city_state'];
    final photoUrl = json['photo_url'];

    if (id is! String ||
        number is! int ||
        participantsCount is! int ||
        cityState is! String ||
        (photoUrl != null && photoUrl is! String)) {
      throw const FormatException('Invalid group.');
    }

    return GroupModel(
      id: id,
      number: number,
      participantsCount: participantsCount,
      cityState: cityState,
      photoUrl: photoUrl as String?,
    );
  }

  static List<GroupModel> listFromJson(dynamic json) {
    if (json is! Map<String, dynamic> || json['groups'] is! List) {
      throw const FormatException('Invalid groups response.');
    }

    return (json['groups'] as List).map(GroupModel.fromJson).toList();
  }

  GroupEntity toDomain() {
    return GroupEntity(
      id: id,
      number: number,
      participantsCount: participantsCount,
      cityState: cityState,
      photoUrl: photoUrl,
    );
  }
}