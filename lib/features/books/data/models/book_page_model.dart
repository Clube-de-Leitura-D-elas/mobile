import 'package:mobile/features/books/data/models/book_summary_model.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';

class BookPageModel {
  const BookPageModel({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  final List<BookSummaryModel> items;
  final int page;
  final int pageSize;
  final bool hasMore;

  factory BookPageModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic> || json['items'] is! List) {
      throw const FormatException('Invalid book page.');
    }

    final page = json['page'];
    final pageSize = json['page_size'];
    final hasMore = json['has_more'];
    if (page is! int || pageSize is! int || hasMore is! bool) {
      throw const FormatException('Invalid book page.');
    }

    return BookPageModel(
      items: (json['items'] as List)
          .map(BookSummaryModel.fromJson)
          .toList(growable: false),
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  BookPage toDomain() => BookPage(
    items: items.map((item) => item.toDomain()).toList(growable: false),
    page: page,
    pageSize: pageSize,
    hasMore: hasMore,
  );
}
