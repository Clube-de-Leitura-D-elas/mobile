import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';

class BookSummary extends Equatable {
  const BookSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.coverUrl,
    required this.myStatus,
  });

  final String id;
  final String title;
  final String author;
  final String genre;
  final String? coverUrl;
  final BookReadingStatus? myStatus;

  BookSummary copyWithStatus(BookReadingStatus? status) {
    return BookSummary(
      id: id,
      title: title,
      author: author,
      genre: genre,
      coverUrl: coverUrl,
      myStatus: status,
    );
  }

  @override
  List<Object?> get props => [id, title, author, genre, coverUrl, myStatus];
}
