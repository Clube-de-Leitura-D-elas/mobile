import 'package:mobile/features/books/domain/entities/rated_book.dart';

class RatedBookModel {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final String? coverUrl;
  final double rating;
  final String? comment;

  const RatedBookModel({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.rating,
    this.comment,
  });

  factory RatedBookModel.fromJson(Map<String, dynamic> json) {
    final resolvedBookId =
        (json['book_id'] ?? json['bookId'] ?? json['id'] ?? '') as String;
    final resolvedId = (json['id'] as String?) ?? resolvedBookId;

    return RatedBookModel(
      id: resolvedId,
      bookId: resolvedBookId,
      title: (json['title'] ?? '') as String,
      author: (json['author'] ?? '') as String,
      coverUrl: (json['cover_url'] ?? json['coverUrl']) as String?,
      rating: ((json['rating'] ?? 0.0) as num).toDouble(),
      comment: (json['commentary'] ?? json['comment']) as String?,
    );
  }

  static List<RatedBookModel> listFromJson(dynamic data) {
    if (data == null) return const [];
    if (data is List) {
      return data
          .map((item) => RatedBookModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final rawList = data['items'] ?? data['books'];
      if (rawList is List) {
        return rawList
            .map(
              (item) => RatedBookModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    }
    throw FormatException(
      'Formato de resposta inesperado para RatedBookModel: ${data.runtimeType}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'rating': rating,
      'commentary': comment,
    };
  }

  RatedBook toDomain() {
    return RatedBook(
      id: id,
      bookId: bookId,
      title: title,
      author: author,
      coverUrl: coverUrl,
      rating: rating,
      comment: comment,
    );
  }
}
