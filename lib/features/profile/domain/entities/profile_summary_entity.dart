import 'package:equatable/equatable.dart';

/// Resumo do perfil da leitora: contadores, grupos e últimas avaliações.
class ProfileSummaryEntity extends Equatable {
  final int booksReadCount;
  final List<ProfileGroupEntity> groups;

  /// Só as avaliações mais recentes; a lista completa é outra tela.
  final List<ProfileReviewedBookEntity> reviewedBooks;

  const ProfileSummaryEntity({
    required this.booksReadCount,
    this.groups = const [],
    this.reviewedBooks = const [],
  });

  @override
  List<Object?> get props => [booksReadCount, groups, reviewedBooks];
}

class ProfileGroupEntity extends Equatable {
  final String id;
  final int number;
  final String? photoUrl;

  const ProfileGroupEntity({
    required this.id,
    required this.number,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, number, photoUrl];
}

class ProfileReviewedBookEntity extends Equatable {
  final String bookId;
  final String title;
  final String? coverUrl;

  /// Pode ter meio ponto (4.5).
  final double rating;

  const ProfileReviewedBookEntity({
    required this.bookId,
    required this.title,
    required this.rating,
    this.coverUrl,
  });

  @override
  List<Object?> get props => [bookId, title, coverUrl, rating];
}
