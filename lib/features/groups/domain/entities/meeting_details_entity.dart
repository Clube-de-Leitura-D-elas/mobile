import 'package:equatable/equatable.dart';

class MeetingDetailsEntity extends Equatable {
  final String id;
  final int? number;
  final DateTime? date;
  final String bookTitle;
  final String hostName;
  final String? locationName;
  final String? locationAddress;
  final String? locationGooglePlaceId;
  final String? description;
  final String? coverPhotoUrl;
  final bool canEdit;

  const MeetingDetailsEntity({
    required this.id,
    required this.bookTitle,
    required this.hostName,
    this.number,
    this.date,
    this.locationName,
    this.locationAddress,
    this.locationGooglePlaceId,
    this.description,
    this.coverPhotoUrl,
    this.canEdit = false,
  });

  @override
  List<Object?> get props => [
    id,
    number,
    date,
    bookTitle,
    hostName,
    locationName,
    locationAddress,
    locationGooglePlaceId,
    description,
    coverPhotoUrl,
    canEdit,
  ];
}
