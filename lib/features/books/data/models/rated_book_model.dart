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
    return RatedBookModel(
      id: (json['id'] ?? '') as String,
      bookId: (json['book_id'] ?? json['bookId'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      author: (json['author'] ?? '') as String,
      coverUrl: (json['cover_url'] ?? json['coverUrl']) as String?,
      rating: ((json['rating'] ?? 0.0) as num).toDouble(),
      comment: json['comment'] as String?,
    );
  }

  static List<RatedBookModel> listFromJson(dynamic data) {
    if (data == null) return const [];
    if (data is List) {
      return data
          .map((item) => RatedBookModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic> && data['books'] is List) {
      return (data['books'] as List)
          .map((item) => RatedBookModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'rating': rating,
      'comment': comment,
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
