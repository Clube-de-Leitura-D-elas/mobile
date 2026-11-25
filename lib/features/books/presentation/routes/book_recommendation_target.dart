import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';

/// Avisa quem abriu os detalhes (a busca) sobre o status do livro.
/// [isWrite] é `true` quando a leitora mudou o status aqui e `false` quando os
/// detalhes só carregaram o que o backend tem.
typedef ReadingStatusChanged =
    void Function(BookReadingStatus? status, {required bool isWrite});

class BookRecommendationTarget extends Equatable {
  const BookRecommendationTarget({
    required this.groupId,
    required this.groupName,
  });

  final String groupId;
  final String groupName;

  @override
  List<Object?> get props => [groupId, groupName];
}

class BookDetailsRouteExtra {
  const BookDetailsRouteExtra({
    this.onReadingStatusChanged,
    this.recommendationTarget,
    this.bookSource = BookSource.catalog,
  });

  final ReadingStatusChanged? onReadingStatusChanged;
  final BookRecommendationTarget? recommendationTarget;
  final BookSource bookSource;
}
