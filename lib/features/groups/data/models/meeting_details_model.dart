import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';

class MeetingDetailsModel extends MeetingDetailsEntity {
  const MeetingDetailsModel({
    required super.id,
    required super.bookTitle,
    required super.hostName,
    super.number,
    super.date,
    super.locationName,
    super.locationAddress,
    super.description,
    super.coverPhotoUrl,
  });

  factory MeetingDetailsModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid meeting details response.');
    }

    final id = json['id'];
    final number = json['number'];
    final date = json['date'];
    final bookTitle = json['book_title'];
    final hostName = json['host_name'];
    final locationName = json['location_name'];
    final locationAddress = json['location_address'];
    final description = json['description'];
    final coverPhotoUrl = json['cover_photo_url'];

    if (id is! String ||
        (number != null && number is! int) ||
        (date != null && date is! String) ||
        bookTitle is! String ||
        hostName is! String ||
        (locationName != null && locationName is! String) ||
        (locationAddress != null && locationAddress is! String) ||
        (description != null && description is! String) ||
        (coverPhotoUrl != null && coverPhotoUrl is! String)) {
      throw const FormatException('Invalid meeting details response.');
    }

    final parsedDate = date == null ? null : DateTime.tryParse(date as String);
    if (date != null && parsedDate == null) {
      throw const FormatException('Invalid meeting details response.');
    }

    return MeetingDetailsModel(
      id: id,
      number: number as int?,
      date: parsedDate,
      bookTitle: bookTitle,
      hostName: hostName,
      locationName: locationName as String?,
      locationAddress: locationAddress as String?,
      description: description as String?,
      coverPhotoUrl: coverPhotoUrl as String?,
    );
  }

  MeetingDetailsEntity toDomain() {
    return MeetingDetailsEntity(
      id: id,
      number: number,
      date: date,
      bookTitle: bookTitle,
      hostName: hostName,
      locationName: locationName,
      locationAddress: locationAddress,
      description: description,
      coverPhotoUrl: coverPhotoUrl,
    );
  }
}
