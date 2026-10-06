import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';

class MeetingPhotoModel extends MeetingPhotoEntity {
  const MeetingPhotoModel({required super.id, required super.url});

  factory MeetingPhotoModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid meeting photo response.');
    }

    final id = json['id'];
    final url = json['url'];
    if (id is! String || url is! String) {
      throw const FormatException('Invalid meeting photo response.');
    }

    return MeetingPhotoModel(id: id, url: url);
  }

  static List<MeetingPhotoModel> listFromEnvelope(dynamic json) {
    if (json is! Map<String, dynamic> || json['photos'] is! List) {
      throw const FormatException('Invalid meeting photos response.');
    }

    return (json['photos'] as List)
        .map(MeetingPhotoModel.fromJson)
        .toList(growable: false);
  }

  static MeetingPhotoModel fromEnvelope(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid meeting photo response.');
    }

    return MeetingPhotoModel.fromJson(json['photo']);
  }

  MeetingPhotoEntity toDomain() => MeetingPhotoEntity(id: id, url: url);
}
