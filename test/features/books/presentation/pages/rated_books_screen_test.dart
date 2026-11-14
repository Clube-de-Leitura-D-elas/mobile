import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/rated_books_state.dart';
import 'package:mobile/features/books/presentation/pages/rated_books_screen.dart';
import 'package:mobile/features/books/presentation/widgets/rated_book_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockRatedBooksCubit extends MockCubit<RatedBooksState>
    implements RatedBooksCubit {}

void main() {
  late MockRatedBooksCubit mockCubit;

  setUp(() {
    mockCubit = MockRatedBooksCubit();
  });

  const tBook = RatedBook(
    id: 'rated-1',
    bookId: 'book-1',
    title: 'Harry Potter e a Pedra Filosofal',
    author: 'J. K. Rowling',
    rating: 4.5,
    comment: 'Maravilhoso!',
  );

  Widget buildScreen({ValueChanged<RatedBook>? onBookTap}) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      home: BlocProvider<RatedBooksCubit>.value(
        value: mockCubit,
        child: RatedBooksScreen(onBookTap: onBookTap),
      ),
    );
  }

  group('RatedBooksScreen', () {
    testWidgets('shows loading indicator when state is RatedBooksLoading', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const RatedBooksLoading());

      await tester.pumpWidget(buildScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when state is RatedBooksEmpty', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(const RatedBooksEmpty());

      await tester.pumpWidget(buildScreen());

      expect(find.text('Nenhum livro avaliado ainda.'), findsOneWidget);
    });

    testWidgets(
      'shows error message and retry button when state is RatedBooksError',
      (tester) async {
        when(
          () => mockCubit.state,
        ).thenReturn(const RatedBooksError(RatedBooksLoadFailure()));
        when(() => mockCubit.refresh()).thenAnswer((_) async {});

        await tester.pumpWidget(buildScreen());

        expect(
          find.text('Não foi possível carregar os livros avaliados.'),
          findsOneWidget,
        );
        expect(find.text('Tentar novamente'), findsOneWidget);

        await tester.tap(find.text('Tentar novamente'));
        await tester.pump();

        verify(() => mockCubit.refresh()).called(1);
      },
    );

    testWidgets('renders list of rated books and handles book tap', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const RatedBooksLoaded(
          books: [tBook],
          hasMore: false,
          isLoadingMore: false,
          currentPage: 1,
        ),
      );

      RatedBook? tappedBook;
      await tester.pumpWidget(buildScreen(onBookTap: (b) => tappedBook = b));

      expect(find.byType(RatedBookTile), findsOneWidget);
      expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);

      await tester.tap(find.byType(RatedBookTile));
      await tester.pump();

      expect(tappedBook, equals(tBook));
    });

    testWidgets('shows bottom loading indicator when isLoadingMore is true', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        const RatedBooksLoaded(
          books: [tBook],
          hasMore: true,
          isLoadingMore: true,
          currentPage: 1,
        ),
      );

      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(RatedBookTile), findsOneWidget);
    });
    testWidgets(
      'shows bottom error state and retries loadMore when loadMoreFailure is present',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const RatedBooksLoaded(
            books: [tBook],
            hasMore: true,
            isLoadingMore: false,
            currentPage: 1,
            loadMoreFailure: RatedBooksLoadFailure(),
          ),
        );
        when(() => mockCubit.loadMore()).thenAnswer((_) async {});

        await tester.pumpWidget(buildScreen());

        expect(find.byType(RatedBookTile), findsOneWidget);
        expect(
          find.text('Não foi possível carregar os livros avaliados.'),
          findsOneWidget,
        );
        expect(find.text('Tentar novamente'), findsOneWidget);

        await tester.tap(find.text('Tentar novamente'));
        await tester.pump();

        verify(() => mockCubit.loadMore()).called(1);
      },
    );

    testWidgets('triggers loadMore on scroll past 80%', (tester) async {
      final manyBooks = List.generate(
        15,
        (i) => RatedBook(
          id: 'rated-$i',
          bookId: 'book-$i',
          title: 'Livro $i',
          author: 'Autora $i',
          rating: 4.0,
        ),
      );

      when(() => mockCubit.state).thenReturn(
        RatedBooksLoaded(
          books: manyBooks,
          hasMore: true,
          isLoadingMore: false,
          currentPage: 1,
        ),
      );
      when(() => mockCubit.loadMore()).thenAnswer((_) async {});

      await tester.pumpWidget(buildScreen());

      // Pequena rolagem: não deve atingir o limiar de 80%
      await tester.drag(find.byType(ListView), const Offset(0, -50));
      await tester.pump();
      verifyNever(() => mockCubit.loadMore());

      // Rolagem grande até o final da lista (ultrapassa 80%)
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();

      verify(() => mockCubit.loadMore()).called(1);
    });

    testWidgets(
      'calls loadMore automatically if content does not fill the screen and hasMore is true',
      (tester) async {
        const loadedState = RatedBooksLoaded(
          books: [tBook],
          hasMore: true,
          isLoadingMore: false,
          currentPage: 1,
        );

        // Usamos whenListen para emitir uma transição de Loading -> Loaded.
        // É isso que faz o 'listener' do BlocConsumer ser engatilhado de verdade.
        whenListen(
          mockCubit,
          Stream.fromIterable([loadedState]),
          initialState: const RatedBooksLoading(),
        );

        when(() => mockCubit.loadMore()).thenAnswer((_) async {});

        await tester.pumpWidget(buildScreen());

        // pumpAndSettle vai aguardar a Stream emitir o novo estado,
        // disparar o listener e rodar o addPostFrameCallback.
        await tester.pumpAndSettle();

        verify(() => mockCubit.loadMore()).called(1);
      },
    );
  });
}
