import 'package:mobile/features/groups/data/models/meeting_photo_model.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';

class MeetingPhotosModel extends MeetingPhotosEntity {
  const MeetingPhotosModel({
    required List<MeetingPhotoModel> super.photos,
    required super.canAddPhotos,
    super.promoText,
  });

  /// Lê a resposta de `get-meeting-photos`:
  /// `{ photos, promo_text, can_add_photos }`.
  ///
  /// Sem `can_add_photos` (backend ainda sem o campo), mantém o botão visível
  /// como antes; o envio continua protegido pelo backend.
  factory MeetingPhotosModel.fromEnvelope(dynamic json) {
    final photos = MeetingPhotoModel.listFromEnvelope(json);
    final map = json as Map<String, dynamic>;
    final canAddPhotos = map['can_add_photos'];
    final promoText = map['promo_text'];
    if ((canAddPhotos != null && canAddPhotos is! bool) ||
        (promoText != null && promoText is! String)) {
      throw const FormatException('Invalid meeting photos response.');
    }

    return MeetingPhotosModel(
      photos: photos,
      canAddPhotos: canAddPhotos as bool? ?? true,
      promoText: promoText as String?,
    );
  }

  MeetingPhotosEntity toDomain() => MeetingPhotosEntity(
    photos: photos
        .map((photo) => (photo as MeetingPhotoModel).toDomain())
        .toList(growable: false),
    canAddPhotos: canAddPhotos,
    promoText: promoText,
  );
}
