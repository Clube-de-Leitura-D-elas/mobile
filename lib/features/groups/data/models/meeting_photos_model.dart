import 'package:mobile/features/groups/data/models/meeting_photo_model.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';

class MeetingPhotosModel extends MeetingPhotosEntity {
  const MeetingPhotosModel({
    required List<MeetingPhotoModel> super.photos,
    required super.canAddPhotos,
  });

  /// Lê a resposta de `get-meeting-photos`: `{ photos, can_add_photos }`.
  ///
  /// Sem `can_add_photos` (backend ainda sem o campo), mantém o botão visível
  /// como antes; o envio continua protegido pelo backend.
  factory MeetingPhotosModel.fromEnvelope(dynamic json) {
    final photos = MeetingPhotoModel.listFromEnvelope(json);
    final canAddPhotos = (json as Map<String, dynamic>)['can_add_photos'];
    if (canAddPhotos != null && canAddPhotos is! bool) {
      throw const FormatException('Invalid meeting photos response.');
    }

    return MeetingPhotosModel(
      photos: photos,
      canAddPhotos: canAddPhotos as bool? ?? true,
    );
  }

  MeetingPhotosEntity toDomain() => MeetingPhotosEntity(
    photos: photos
        .map((photo) => (photo as MeetingPhotoModel).toDomain())
        .toList(growable: false),
    canAddPhotos: canAddPhotos,
  );
}
