import 'package:equatable/equatable.dart';

class RatedBook extends Equatable {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final String? coverUrl;
  final double rating;
  final String? comment;

  const RatedBook({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [
    id,
    bookId,
    title,
    author,
    coverUrl,
    rating,
    comment,
  ];
}
