import 'package:equatable/equatable.dart';

class GroupMeeting extends Equatable {
  final String hostName;
  final String bookTitle;
  final String date;
  final String location;

  const GroupMeeting({
    required this.hostName,
    required this.bookTitle,
    required this.date,
    required this.location,
  });

  @override
  List<Object?> get props => [hostName, bookTitle, date, location];
}
