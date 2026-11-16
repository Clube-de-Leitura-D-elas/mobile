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

  BookDetailsCubit({required this.repository})
    : super(const BookDetailsState());

  Future<void> load(String bookId) async {
    _bookId = bookId;
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
    if (!state.hasMoreReviews || state.isLoadingMoreReviews) return;
    emit(
      state.copyWith(isLoadingMoreReviews: true, loadMoreReviewsFailed: false),
    );

    final nextPage = state.reviewsPage + 1;
    final result = await repository.getBookDetails(
      bookId: _bookId,
      reviewsPage: nextPage,
    );
    if (isClosed) return;

    switch (result) {
      case Failure():
        emit(
          state.copyWith(
            isLoadingMoreReviews: false,
            loadMoreReviewsFailed: true,
          ),
        );
      case Success(:final data):
        // Avaliação nova desloca as páginas e pode repetir uma já carregada.
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
        emit(
          state.copyWith(
            isRecommending: false,
            notice: failure is BookAlreadyRecommendedFailure
                ? BookDetailsNotice.recommendationAlreadyExists
                : BookDetailsNotice.recommendationFailed,
            recommendationGroups: [
              for (final group in state.recommendationGroups)
                group.id == groupId
                    ? BookRecommendationGroup(
                        id: group.id,
                        name: group.name,
                        photoUrl: group.photoUrl,
                        alreadyRecommended: true,
                      )
                    : group,
            ],
          ),
        );
        return false;
    }
  }
}
