import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_state.dart';

class RatedBooksCubit extends Cubit<RatedBooksState> {
  final BookRepository bookRepository;
  static const int pageSize = 10;

  // Identificador de geração para invalidar requisições antigas
  int _generation = 0;

  RatedBooksCubit({required this.bookRepository})
    : super(const RatedBooksInitial());

  Future<void> loadInitial() async {
    // Incrementa a geração sempre que a lista for reiniciada
    _generation++;
    final currentGeneration = _generation;

    emit(const RatedBooksLoading());

    final result = await bookRepository.getRatedBooks(page: 1, limit: pageSize);

    // Descarta a resposta se o cubit fechou ou se uma nova requisição loadInitial começou enquanto esta aguardava
    if (isClosed || currentGeneration != _generation) return;

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

    // Salva a geração atual antes de iniciar a busca
    final currentGeneration = _generation;

    emit(currentState.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));

    final nextPage = currentState.currentPage + 1;
    final result = await bookRepository.getRatedBooks(
      page: nextPage,
      limit: pageSize,
    );

    // Se o cubit fechou ou se o loadInitial/refresh foi chamado durante o loadMore,
    // a geração mudou. Ignoramos o resultado e não atualizamos a tela com dados da geração antiga.
    if (isClosed || currentGeneration != _generation) return;

    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(
            currentState.copyWith(
              hasMore: false,
              isLoadingMore: false,
              clearLoadMoreFailure: true,
            ),
          );
        } else {
          emit(
            currentState.copyWith(
              books: [...currentState.books, ...data],
              hasMore: data.length >= pageSize,
              isLoadingMore: false,
              currentPage: nextPage,
              clearLoadMoreFailure: true,
            ),
          );
        }
      case Failure(:final failure):
        // Mantém os livros já carregados, desativa o loading e registra a falha no estado
        emit(
          currentState.copyWith(
            isLoadingMore: false,
            loadMoreFailure: failure,
          ),
        );
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}
