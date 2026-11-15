import 'package:equatable/equatable.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';

enum BookDetailsStatus { loading, loaded, error, notFound }

/// Aviso pontual para a tela mostrar como toast.
enum BookDetailsNotice { readingStatusFailed, reviewSaved, reviewFailed }

class BookDetailsState extends Equatable {
  final BookDetailsStatus status;

  /// Motivo do erro ao carregar, para a tela escolher o texto e as saídas.
  final BookFailure? failure;
  final BookDetailsEntity? details;
  final List<BookReviewEntity> reviews;
  final int reviewsPage;
  final bool hasMoreReviews;
  final bool isLoadingMoreReviews;
  final bool loadMoreReviewsFailed;
  final bool isUpdatingStatus;
  final bool isSubmittingReview;
  final BookDetailsNotice? notice;

  const BookDetailsState({
    this.status = BookDetailsStatus.loading,
    this.failure,
    this.details,
    this.reviews = const [],
    this.reviewsPage = 0,
    this.hasMoreReviews = false,
    this.isLoadingMoreReviews = false,
    this.loadMoreReviewsFailed = false,
    this.isUpdatingStatus = false,
    this.isSubmittingReview = false,
    this.notice,
  });

  /// O aviso vale só para a emissão em que aparece: sem [notice], ele é limpo.
  BookDetailsState copyWith({
    BookDetailsEntity? details,
    List<BookReviewEntity>? reviews,
    int? reviewsPage,
    bool? hasMoreReviews,
    bool? isLoadingMoreReviews,
    bool? loadMoreReviewsFailed,
    bool? isUpdatingStatus,
    bool? isSubmittingReview,
    BookDetailsNotice? notice,
  }) {
    return BookDetailsState(
      status: status,
      failure: failure,
      details: details ?? this.details,
      reviews: reviews ?? this.reviews,
      reviewsPage: reviewsPage ?? this.reviewsPage,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
      isLoadingMoreReviews: isLoadingMoreReviews ?? this.isLoadingMoreReviews,
      loadMoreReviewsFailed:
          loadMoreReviewsFailed ?? this.loadMoreReviewsFailed,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    failure,
    details,
    reviews,
    reviewsPage,
    hasMoreReviews,
    isLoadingMoreReviews,
    loadMoreReviewsFailed,
    isUpdatingStatus,
    isSubmittingReview,
    notice,
  ];
}
