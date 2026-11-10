import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_state.dart';
import 'package:mobile/features/books/presentation/pages/book_search_screen.dart';
import 'package:mobile/features/books/presentation/widgets/book_list_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

const book = BookSummary(
  id: 'book-1',
  title: 'Harry Potter e a Pedra Filosofal',
  author: 'J. K. Rowling',
  genre: 'Fantasia',
  coverUrl: null,
  myStatus: null,
);

Future<void> pumpScreen(
  WidgetTester tester, {
  required BookSearchState state,
  ValueChanged<String>? onQueryChanged,
  VoidCallback? onRetry,
  VoidCallback? onLoadMore,
  ValueChanged<String>? onStatusTap,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BookSearchScreen(
        state: state,
        onQueryChanged: onQueryChanged ?? (_) {},
        onRetry: onRetry ?? () {},
        onLoadMore: onLoadMore ?? () {},
        onStatusTap: onStatusTap ?? (_) {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the popular grid when there is no query', (tester) async {
    await pumpScreen(
      tester,
      state: const BookSearchState(books: [book], page: 1),
    );

    expect(find.text('Populares esse mês'), findsOneWidget);
    expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);
    expect(find.byType(BookListTile), findsNothing);
    expect(find.byType(AppBookCover), findsOneWidget);
  });

  testWidgets('shows result tiles and reports the status tap', (tester) async {
    final taps = <String>[];
    await pumpScreen(
      tester,
      state: const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
      ),
      onStatusTap: taps.add,
    );

    expect(find.byType(BookListTile), findsOneWidget);
    expect(find.text('Marcar como lido'), findsOneWidget);
    await tester.tap(find.text('Marcar como lido'));
    expect(taps, ['book-1']);
  });

  testWidgets('shows the empty copy', (tester) async {
    await pumpScreen(
      tester,
      state: const BookSearchState(
        mode: BookSearchMode.results,
        query: 'zzzz',
        page: 1,
      ),
    );

    expect(find.text('Nenhum livro encontrado'), findsOneWidget);
  });

  testWidgets('shows the loading label', (tester) async {
    await pumpScreen(tester, state: const BookSearchState(isLoading: true));

    expect(find.bySemanticsLabel('Carregando livros'), findsOneWidget);
  });

  testWidgets('retries from the error state', (tester) async {
    var retries = 0;
    await pumpScreen(
      tester,
      state: const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        hasError: true,
      ),
      onRetry: () => retries++,
    );

    await tester.tap(find.text('Tentar novamente'));
    expect(retries, 1);
  });

  testWidgets('does not auto load more after a load-more error', (
    tester,
  ) async {
    var loadMoreCalls = 0;
    var retries = 0;
    await pumpScreen(
      tester,
      state: const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        books: [book],
        page: 1,
        hasMore: true,
        hasLoadMoreError: true,
      ),
      onLoadMore: () => loadMoreCalls++,
      onRetry: () => retries++,
    );

    expect(loadMoreCalls, 0);
    expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);
    expect(
      find.text('Não foi possível carregar os livros. Tente novamente.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tentar novamente'));
    expect(retries, 1);
    expect(loadMoreCalls, 0);
  });

  testWidgets('shows the want-to-read and read chips', (tester) async {
    await pumpScreen(
      tester,
      state: const BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        page: 1,
        books: [
          book,
          BookSummary(
            id: 'book-2',
            title: 'Querendo ler',
            author: 'Autora',
            genre: 'Romance',
            coverUrl: null,
            myStatus: BookReadingStatus.wantToRead,
          ),
          BookSummary(
            id: 'book-3',
            title: 'Livro lido',
            author: 'Autora',
            genre: 'Romance',
            coverUrl: null,
            myStatus: BookReadingStatus.read,
          ),
        ],
      ),
    );

    expect(find.text('Quero ler'), findsOneWidget);
    expect(find.text('Já lido'), findsOneWidget);
  });

  testWidgets('asks for the next page when the list reaches the end', (
    tester,
  ) async {
    var loadMoreCalls = 0;
    await pumpScreen(
      tester,
      state: BookSearchState(
        mode: BookSearchMode.results,
        query: 'harry',
        page: 1,
        hasMore: true,
        books: [
          for (var index = 0; index < 12; index++)
            BookSummary(
              id: 'book-$index',
              title: 'Livro $index',
              author: 'Autora',
              genre: 'Romance',
              coverUrl: null,
              myStatus: null,
            ),
        ],
      ),
      onLoadMore: () => loadMoreCalls++,
    );

    await tester.drag(find.text('Livro 0'), const Offset(0, -800));
    await tester.pump();

    expect(loadMoreCalls, greaterThan(0));
  });
}
