import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_recommendation_group.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';

class BookDetailsCubit extends Cubit<BookDetailsState> {
  final BookRepository repository;
  String _bookId = '';
  int _reviewsRequestGeneration = 0;
  bool _isRefreshingReviews = false;

  BookDetailsCubit({required this.repository})
    : super(const BookDetailsState());

  Future<void> load(String bookId) async {
    _bookId = bookId;
    _reviewsRequestGeneration++;
    _isRefreshingReviews = false;
    emit(const BookDetailsState());

    final result = await repository.getBookDetails(bookId: bookId);
    if (isClosed) return;

    switch (result) {
      case Failure(:final failure):
        emit(
          failure is BookNotFoundFailure
              ? const BookDetailsState(status: BookDetailsStatus.notFound)
              : BookDetailsState(
                  status: BookDetailsStatus.error,
                  failure: failure,
                ),
        );
      case Success(:final data):
        emit(
          BookDetailsState(
            status: BookDetailsStatus.loaded,
            details: data,
            reviews: data.reviews,
            reviewsPage: 1,
            hasMoreReviews: data.hasMoreReviews,
          ),
        );
    }
  }

  Future<void> retry() => load(_bookId);

  Future<void> loadMoreReviews() async {
    if (!state.hasMoreReviews ||
        state.isLoadingMoreReviews ||
        _isRefreshingReviews) {
      return;
    }
    final requestGeneration = _reviewsRequestGeneration;
    emit(
      state.copyWith(isLoadingMoreReviews: true, loadMoreReviewsFailed: false),
    );

    final nextPage = state.reviewsPage + 1;
    final result = await repository.getBookDetails(
      bookId: _bookId,
      reviewsPage: nextPage,
    );
    if (isClosed) return;
    if (requestGeneration != _reviewsRequestGeneration) return;

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            isLoadingMoreReviews: false,
            loadMoreReviewsFailed: true,
          ),
        );
      case Success(:final data):
        final loadedIds = state.reviews.map((review) => review.id).toSet();
        emit(
          state.copyWith(
            reviews: [
              ...state.reviews,
              ...data.reviews.where((review) => !loadedIds.contains(review.id)),
            ],
            reviewsPage: nextPage,
            hasMoreReviews: data.hasMoreReviews,
            isLoadingMoreReviews: false,
          ),
        );
    }
  }

  /// Lido volta para fora da estante; qualquer outro estado vira lido.
  Future<void> toggleReadingStatus() async {
    final details = state.details;
    if (details == null || state.isUpdatingStatus) return;

    final nextStatus = nextReadingStatus(details.myStatus);
    emit(state.copyWith(isUpdatingStatus: true));

    final result = await repository.setReadingStatus(
      bookId: details.id,
      status: nextStatus,
    );
    if (isClosed) return;

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            isUpdatingStatus: false,
            notice: BookDetailsNotice.readingStatusFailed,
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            details: state.details?.withReadingStatus(data),
            isUpdatingStatus: false,
          ),
        );
    }
  }

  Future<void> loadRecommendationGroups() async {
    if (state.isLoadingRecommendationGroups || state.details == null) return;
    emit(state.copyWith(isLoadingRecommendationGroups: true, notice: null));
    final result = await repository.getBookRecommendationGroups(
      bookId: state.details!.id,
    );
    if (isClosed) return;

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            isLoadingRecommendationGroups: false,
            notice: BookDetailsNotice.recommendationGroupsFailed,
          ),
        );
      case Success(:final data):
        emit(
          state.copyWith(
            recommendationGroups: data,
            isLoadingRecommendationGroups: false,
          ),
        );
    }
  }

  Future<bool> recommendBook({
    required String groupId,
    required String groupName,
  }) async {
    final details = state.details;
    if (details == null || state.isRecommending) return false;
    emit(state.copyWith(isRecommending: true, notice: null));

    final result = await repository.recommendBook(
      bookId: details.id,
      groupId: groupId,
    );
    if (isClosed) return false;

    switch (result) {
      case Success():
        emit(
          state.copyWith(
            isRecommending: false,
            notice: BookDetailsNotice.recommendationSucceeded,
            recommendedGroupName: groupName,
          ),
        );
        return true;
      case Failure(:final failure):
        final alreadyRecommended = failure is BookAlreadyRecommendedFailure;
        emit(
          state.copyWith(
            isRecommending: false,
            notice: alreadyRecommended
                ? BookDetailsNotice.recommendationAlreadyExists
                : BookDetailsNotice.recommendationFailed,
            recommendationGroups: alreadyRecommended
                ? [
                    for (final group in state.recommendationGroups)
                      group.id == groupId
                          ? BookRecommendationGroup(
                              id: group.id,
                              name: group.name,
                              photoUrl: group.photoUrl,
                              alreadyRecommended: true,
                            )
                          : group,
                  ]
                : state.recommendationGroups,
          ),
        );
        return false;
    }
  }

  Future<bool> upsertBookReview({
    required int rating,
    required String? commentary,
  }) async {
    final details = state.details;
    if (details == null || state.isSubmittingReview) return false;

    emit(state.copyWith(isSubmittingReview: true));
    final result = await repository.upsertBookReview(
      bookId: details.id,
      rating: rating,
      commentary: commentary,
    );
    if (isClosed) return false;

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            isSubmittingReview: false,
            notice: BookDetailsNotice.reviewFailed,
          ),
        );
        return false;
      case Success():
        _isRefreshingReviews = true;
        final refreshGeneration = ++_reviewsRequestGeneration;
        final refreshed = await repository.getBookDetails(bookId: details.id);
        if (isClosed) return false;
        if (refreshGeneration != _reviewsRequestGeneration) return true;
        switch (refreshed) {
          case Failure():
            emit(
              state.copyWith(
                isSubmittingReview: false,
                isLoadingMoreReviews: false,
                notice: BookDetailsNotice.reviewSaved,
              ),
            );
            _isRefreshingReviews = false;
            return true;
          case Success(:final data):
            _isRefreshingReviews = false;
            emit(
              BookDetailsState(
                status: BookDetailsStatus.loaded,
                details: data.withReadingStatus(
                  data.myStatus ?? BookReadingStatus.read,
                ),
                reviews: data.reviews,
                reviewsPage: 1,
                hasMoreReviews: data.hasMoreReviews,
                notice: BookDetailsNotice.reviewSaved,
              ),
            );
            return true;
        }
    }
  }
}
