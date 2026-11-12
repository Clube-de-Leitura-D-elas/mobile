import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_state.dart';

class RatedBooksCubit extends Cubit<RatedBooksState> {
  final BookRepository bookRepository;
  static const int pageSize = 10;

  RatedBooksCubit({required this.bookRepository})
      : super(const RatedBooksInitial());

  Future<void> loadInitial() async {
    emit(const RatedBooksLoading());

    final result = await bookRepository.getRatedBooks(
      page: 1,
      limit: pageSize,
    );

    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(const RatedBooksEmpty());
        } else {
          emit(
            RatedBooksLoaded(
              books: data,
              hasMore: data.length >= pageSize,
              isLoadingMore: false,
              currentPage: 1,
            ),
          );
        }
      case Failure(:final failure):
        emit(RatedBooksError(failure));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! RatedBooksLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await bookRepository.getRatedBooks(
      page: nextPage,
      limit: pageSize,
    );

    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(
            currentState.copyWith(
              hasMore: false,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(
            currentState.copyWith(
              books: [...currentState.books, ...data],
              hasMore: data.length >= pageSize,
              isLoadingMore: false,
              currentPage: nextPage,
            ),
          );
        }
      case Failure():
        // Mantém os livros já carregados e desativa o loading da próxima página
        emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}
