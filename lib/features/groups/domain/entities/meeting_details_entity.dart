import 'package:equatable/equatable.dart';

class MeetingDetailsEntity extends Equatable {
  final String id;
  final int? number;
  final DateTime? date;
  final String bookTitle;
  final String hostName;
  final String? locationName;
  final String? locationAddress;
  final String? description;
  final String? coverPhotoUrl;

  const MeetingDetailsEntity({
    required this.id,
    required this.bookTitle,
    required this.hostName,
    this.number,
    this.date,
    this.locationName,
    this.locationAddress,
    this.description,
    this.coverPhotoUrl,
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
    description,
    coverPhotoUrl,
  ];
}
