import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';

/// Resposta da get-my-profile-summary.
class ProfileSummaryModel {
  final int booksReadCount;
  final List<ProfileGroupModel> groups;
  final List<ProfileReviewedBookModel> reviewedBooks;

  const ProfileSummaryModel({
    required this.booksReadCount,
    required this.groups,
    required this.reviewedBooks,
  });

  /// A function sempre manda os três campos, mesmo vazios. Faltar um é
  /// resposta quebrada: vira erro na tela, não "0 livros lidos".
  factory ProfileSummaryModel.fromJson(Map<String, dynamic> json) {
    final booksReadCount = json['books_read_count'];
    final groups = json['groups'];
    final reviewedBooks = json['reviewed_books'];
    if (booksReadCount is! num ||
        groups is! List<dynamic> ||
        reviewedBooks is! List<dynamic>) {
      throw const FormatException('Invalid profile summary response.');
    }

    return ProfileSummaryModel(
      booksReadCount: booksReadCount.toInt(),
      groups: groups
          .map(
            (item) => ProfileGroupModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      reviewedBooks: reviewedBooks
          .map(
            (item) =>
                ProfileReviewedBookModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  ProfileSummaryEntity toDomain() {
    return ProfileSummaryEntity(
      booksReadCount: booksReadCount,
      groups: groups.map((group) => group.toDomain()).toList(),
      reviewedBooks: reviewedBooks.map((book) => book.toDomain()).toList(),
    );
  }
}

class ProfileGroupModel {
  final String id;
  final int number;
  final String? photoUrl;

  const ProfileGroupModel({
    required this.id,
    required this.number,
    this.photoUrl,
  });

  factory ProfileGroupModel.fromJson(Map<String, dynamic> json) {
    return ProfileGroupModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      photoUrl: json['photo_url'] as String?,
    );
  }

  ProfileGroupEntity toDomain() =>
      ProfileGroupEntity(id: id, number: number, photoUrl: photoUrl);
}

class ProfileReviewedBookModel {
  final String bookId;
  final String title;
  final String? coverUrl;
  final double rating;

  const ProfileReviewedBookModel({
    required this.bookId,
    required this.title,
    required this.rating,
    this.coverUrl,
  });

  factory ProfileReviewedBookModel.fromJson(Map<String, dynamic> json) {
    return ProfileReviewedBookModel(
      bookId: json['book_id'] as String,
      title: json['title'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  ProfileReviewedBookEntity toDomain() => ProfileReviewedBookEntity(
    bookId: bookId,
    title: title,
    coverUrl: coverUrl,
    rating: rating,
  );
}
