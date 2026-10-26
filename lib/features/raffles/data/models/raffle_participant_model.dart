import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';

class RaffleParticipantModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool hasAttended;
  final bool isExcludedByRule;
  final String? exclusionReason;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCoverUrl;

  const RaffleParticipantModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.hasAttended,
    this.isExcludedByRule = false,
    this.exclusionReason,
    this.bookTitle,
    this.bookAuthor,
    this.bookCoverUrl,
  });

  factory RaffleParticipantModel.fromJson(Map<String, dynamic> json) {
    return RaffleParticipantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      hasAttended: json['has_attended'] as bool? ?? false,
      isExcludedByRule: json['is_excluded_by_rule'] as bool? ?? false,
      exclusionReason: json['exclusion_reason'] as String?,
      bookTitle: json['book_title'] as String?,
      bookAuthor: json['book_author'] as String?,
      bookCoverUrl: json['book_cover_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'has_attended': hasAttended,
      'is_excluded_by_rule': isExcludedByRule,
      'exclusion_reason': exclusionReason,
      'book_title': bookTitle,
      'book_author': bookAuthor,
      'book_cover_url': bookCoverUrl,
    };
  }

  RaffleParticipant toDomain() {
    return RaffleParticipant(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      hasAttended: hasAttended,
      isExcludedByRule: isExcludedByRule,
      exclusionReason: exclusionReason,
      isSelected: !isExcludedByRule,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      bookCoverUrl: bookCoverUrl,
    );
  }
}
