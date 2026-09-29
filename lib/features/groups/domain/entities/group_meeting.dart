import 'package:equatable/equatable.dart';

class GroupMeeting extends Equatable {
  final String? id;
  final String hostName;
  final String bookTitle;
  final String date;
  final String location;
  final String? bookCoverUrl;

  const GroupMeeting({
    this.id,
    required this.hostName,
    required this.bookTitle,
    required this.date,
    required this.location,
    this.bookCoverUrl,
  });

  @override
  List<Object?> get props => [
    id,
    hostName,
    bookTitle,
    date,
    location,
    bookCoverUrl,
  ];
}
