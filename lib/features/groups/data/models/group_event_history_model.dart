import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

class GroupEventHistoryModel extends GroupMeeting {
  const GroupEventHistoryModel({
    required super.id,
    required super.hostName,
    required super.bookTitle,
    required super.date,
    super.bookCoverUrl,
  }) : super(location: '');

  factory GroupEventHistoryModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid event history item response.');
    }

    final id = json['id'];
    final bookTitle = json['book_title'];
    final bookCoverUrl = json['book_cover_url'];
    final hostName = json['host_name'];
    final date = json['date'];

    if (id is! String ||
        bookTitle is! String ||
        (bookCoverUrl != null && bookCoverUrl is! String) ||
        hostName is! String ||
        date is! String) {
      throw const FormatException('Invalid event history item response.');
    }

    return GroupEventHistoryModel(
      id: id,
      bookTitle: bookTitle,
      bookCoverUrl: bookCoverUrl as String?,
      hostName: hostName,
      date: date,
    );
  }

  static List<GroupEventHistoryModel> listFromJson(dynamic json) {
    if (json is! Map<String, dynamic> || json['items'] is! List) {
      throw const FormatException('Invalid event history response.');
    }

    return (json['items'] as List)
        .map(GroupEventHistoryModel.fromJson)
        .toList(growable: false);
  }

  GroupMeeting toDomain() {
    return GroupMeeting(
      id: id,
      hostName: hostName,
      bookTitle: bookTitle,
      date: date,
      location: location,
      bookCoverUrl: bookCoverUrl,
    );
  }
}
