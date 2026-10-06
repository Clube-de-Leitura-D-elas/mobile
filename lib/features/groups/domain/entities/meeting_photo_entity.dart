import 'package:equatable/equatable.dart';

class MeetingPhotoEntity extends Equatable {
  final String id;
  final String url;

  const MeetingPhotoEntity({required this.id, required this.url});

  @override
  List<Object?> get props => [id, url];
}

abstract final class MeetingPhotoLimits {
  static const perSelection = 10;
  static const perMeeting = 50;
  static const maxBytes = 5 * 1024 * 1024;
  static const contentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
  };
}
