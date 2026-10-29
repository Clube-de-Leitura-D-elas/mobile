import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';

class RaffleResultModel {
  final String meetingId;
  final String winnerId;
  final String winnerName;
  final String? winnerAvatarUrl;
  final String bookTitle;
  final String? bookAuthor;
  final String? bookCoverUrl;
  final DateTime? drawnAt;

  const RaffleResultModel({
    required this.meetingId,
    required this.winnerId,
    required this.winnerName,
    this.winnerAvatarUrl,
    required this.bookTitle,
    this.bookAuthor,
    this.bookCoverUrl,
    this.drawnAt,
  });

  factory RaffleResultModel.fromJson(Map<String, dynamic> json) {
    return RaffleResultModel(
      meetingId: (json['meeting_id'] ?? '') as String,
      winnerId: (json['winner_id'] ?? json['participant_id'] ?? '') as String,
      winnerName:
          (json['winner_name'] ?? json['participant_name'] ?? '') as String,
      winnerAvatarUrl:
          (json['winner_avatar_url'] ?? json['avatar_url']) as String?,
      bookTitle: (json['book_title'] ?? '') as String,
      bookAuthor: json['book_author'] as String?,
      bookCoverUrl: json['book_cover_url'] as String?,
      drawnAt: json['drawn_at'] != null
          ? DateTime.tryParse(json['drawn_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meeting_id': meetingId,
      'winner_id': winnerId,
      'winner_name': winnerName,
      'winner_avatar_url': winnerAvatarUrl,
      'book_title': bookTitle,
      'book_author': bookAuthor,
      'book_cover_url': bookCoverUrl,
      'drawn_at': drawnAt?.toIso8601String(),
    };
  }

  RaffleResult toDomain() {
    return RaffleResult(
      meetingId: meetingId,
      winnerId: winnerId,
      winnerName: winnerName,
      winnerAvatarUrl: winnerAvatarUrl,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      bookCoverUrl: bookCoverUrl,
      drawnAt: drawnAt,
    );
  }
}
