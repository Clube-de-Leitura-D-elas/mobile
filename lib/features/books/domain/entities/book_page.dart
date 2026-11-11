import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';

class BookPage extends Equatable {
  const BookPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  final List<BookSummary> items;
  final int page;
  final int pageSize;
  final bool hasMore;

  @override
  List<Object?> get props => [items, page, pageSize, hasMore];
}
