import 'package:mobile/features/books/data/models/book_reading_status_model.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';

class BookSummaryModel extends BookSummary {
  const BookSummaryModel({
    required super.id,
    required super.title,
    required super.author,
    required super.genre,
    required super.coverUrl,
    required super.myStatus,
  });

  factory BookSummaryModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid book.');
    }

    final id = json['id'];
    final title = json['title'];
    final author = json['author'];
    final genre = json['genre'];
    final coverUrl = json['cover_url'];

    if (id is! String ||
        title is! String ||
        author is! String ||
        genre is! String ||
        (coverUrl != null && coverUrl is! String)) {
      throw const FormatException('Invalid book.');
    }

    return BookSummaryModel(
      id: id,
      title: title,
      author: author,
      genre: genre,
      coverUrl: coverUrl as String?,
      myStatus: bookReadingStatusFromWire(json['my_status']),
    );
  }

  BookSummary toDomain() => BookSummary(
    id: id,
    title: title,
    author: author,
    genre: genre,
    coverUrl: coverUrl,
    myStatus: myStatus,
  );
}
