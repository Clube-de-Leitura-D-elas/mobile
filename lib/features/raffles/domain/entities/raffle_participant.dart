import 'package:equatable/equatable.dart';

class RaffleParticipant extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool hasAttended;
  final bool isExcludedByRule;
  final String? exclusionReason;
  final bool isSelected;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCoverUrl;

  const RaffleParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.hasAttended,
    this.isExcludedByRule = false,
    this.exclusionReason,
    this.isSelected = true,
    this.bookTitle,
    this.bookAuthor,
    this.bookCoverUrl,
  });

  RaffleParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? hasAttended,
    bool? isExcludedByRule,
    String? exclusionReason,
    bool? isSelected,
    String? bookTitle,
    String? bookAuthor,
    String? bookCoverUrl,
  }) {
    return RaffleParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasAttended: hasAttended ?? this.hasAttended,
      isExcludedByRule: isExcludedByRule ?? this.isExcludedByRule,
      exclusionReason: exclusionReason ?? this.exclusionReason,
      isSelected: isSelected ?? this.isSelected,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookCoverUrl: bookCoverUrl ?? this.bookCoverUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    hasAttended,
    isExcludedByRule,
    exclusionReason,
    isSelected,
    bookTitle,
    bookAuthor,
    bookCoverUrl,
  ];
}
