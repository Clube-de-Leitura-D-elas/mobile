import 'package:equatable/equatable.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';

/// Fotos de um encontro e se a participante logada pode adicionar novas
/// (coordenadora do grupo ou anfitriã do encontro).
class MeetingPhotosEntity extends Equatable {
  final List<MeetingPhotoEntity> photos;
  final bool canAddPhotos;

  const MeetingPhotosEntity({required this.photos, required this.canAddPhotos});

  @override
  List<Object?> get props => [photos, canAddPhotos];
}
