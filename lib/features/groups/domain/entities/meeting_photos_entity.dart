import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';

/// Registro de um encontro (fotos e texto de divulgação) e se a participante
/// logada pode mexer nele (coordenadora do grupo ou anfitriã do encontro).
class MeetingPhotosEntity extends Equatable {
  final List<MeetingPhotoEntity> photos;
  final String? promoText;
  final bool canAddPhotos;

  const MeetingPhotosEntity({
    required this.photos,
    required this.canAddPhotos,
    this.promoText,
  });

  @override
  List<Object?> get props => [photos, promoText, canAddPhotos];
}
