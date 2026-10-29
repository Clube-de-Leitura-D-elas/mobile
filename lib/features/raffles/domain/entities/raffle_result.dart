import 'package:equatable/equatable.dart';

class RaffleResult extends Equatable {
  final String meetingId;
  final String winnerId;
  final String winnerName;
  final String? winnerAvatarUrl;
  final String bookTitle;
  final String? bookAuthor;
  final String? bookCoverUrl;
  final DateTime? drawnAt;

  const RaffleResult({
    required this.meetingId,
    required this.winnerId,
    required this.winnerName,
    this.winnerAvatarUrl,
    required this.bookTitle,
    this.bookAuthor,
    this.bookCoverUrl,
    this.drawnAt,
  });

  @override
  List<Object?> get props => [
    meetingId,
    winnerId,
    winnerName,
    winnerAvatarUrl,
    bookTitle,
    bookAuthor,
    bookCoverUrl,
    drawnAt,
  ];
}
