import 'dart:async';

import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_details_page.dart';
import 'package:mobile/features/books/presentation/widgets/book_detail_header.dart';
import 'package:mobile/features/books/presentation/widgets/book_review_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

BookReviewEntity _review(String id) => BookReviewEntity(
  id: id,
  userName: 'Leitora $id',
  rating: 5,
  commentary: 'Comentário $id',
  evaluatedAt: DateTime.utc(2026, 11, 1),
);

BookDetailsEntity _details({
  BookReadingStatus? status,
  MyBookReviewEntity? myReview,
  String? synopsis = 'Um garoto descobre que é bruxo.',
  List<BookReviewEntity>? reviews,
  bool hasMore = false,
}) => BookDetailsEntity(
  id: 'b1',
  title: 'Harry Potter e a Pedra Filosofal',
  author: 'J. K. Rowling',
  genre: 'Fantasia',
  publisher: 'Rocco',
  synopsis: synopsis,
  ratingAverage: 4.5,
  ratingsCount: 10,
  myStatus: status,
  myReview: myReview,
  reviews: reviews ?? [_review('r1')],
  hasMoreReviews: hasMore,
);

void main() {
  late MockBookRepository repository;

  setUpAll(() => registerFallbackValue(BookReadingStatus.read));

  setUp(() {
    repository = MockBookRepository();
  });

  void stubDetails(BookDetailsEntity details, {int page = 1}) {
    when(
      () => repository.getBookDetails(bookId: 'b1', reviewsPage: page),
    ).thenAnswer((_) async => Success(details));
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    bool settle = true,
    ReadingStatusChanged? onReadingStatusChanged,
    SessionCubit? sessionCubit,
    String initialLocation = '/books/b1',
  }) async {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: QuickAccessRoutes.search,
          builder: (context, _) => Scaffold(
            body: Column(
              children: [
                const TextField(),
                TextButton(
                  onPressed: () => context.push('/books/b1'),
                  child: const Text('tela de busca'),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/books/:bookId',
          builder: (_, state) => BlocProvider(
            create: (_) =>
                BookDetailsCubit(repository: repository)
                  ..load(state.pathParameters['bookId']!),
            child: BookDetailsPage(
              onReadingStatusChanged: onReadingStatusChanged,
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    final app = MaterialApp.router(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      routerConfig: router,
    );
    await tester.pumpWidget(
      sessionCubit == null
          ? app
          : BlocProvider<SessionCubit>.value(value: sessionCubit, child: app),
    );
    if (settle) await tester.pumpAndSettle();
  }

  AppButton button(WidgetTester tester, String label) =>
      tester.widget<AppButton>(find.widgetWithText(AppButton, label));

  group('content', () {
    testWidgets('shows the header, actions, synopsis and reviews', (
      tester,
    ) async {
      stubDetails(_details());

      await pumpPage(tester);

      final header = tester.widget<BookDetailHeader>(
        find.byType(BookDetailHeader),
      );
      expect(header.title, 'Harry Potter e a Pedra Filosofal');
      expect(header.author, 'J. K. Rowling');
      expect(header.rating, 4.5);
      expect(header.status, ReadingStatusChipState.markAsRead);
      expect(find.text('Avaliar'), findsOneWidget);
      expect(find.text('Indicar'), findsOneWidget);
      expect(find.text('Sinopse'), findsOneWidget);
      expect(find.text('Um garoto descobre que é bruxo.'), findsOneWidget);
      expect(find.text('Comentários'), findsOneWidget);
      expect(find.text('Leitora r1'), findsOneWidget);
      expect(find.text('Comentário r1'), findsOneWidget);
      expect(find.byType(BottomNavigationBarWidget), findsOneWidget);
    });

    testWidgets(
      'enables rate and keeps recommend disabled until its task exists',
      (tester) async {
        stubDetails(_details());

        await pumpPage(tester);

        expect(button(tester, 'Avaliar').onPressed, isNotNull);
        expect(button(tester, 'Indicar').onPressed, isNull);
      },
    );

    testWidgets('opens and saves a new review', (tester) async {
      var detailsCalls = 0;
      when(
        () => repository.getBookDetails(bookId: 'b1', reviewsPage: 1),
      ).thenAnswer((_) async {
        detailsCalls++;
        return Success(
          _details(
            status: detailsCalls == 1 ? null : BookReadingStatus.read,
            myReview: detailsCalls == 1
                ? null
                : MyBookReviewEntity(
                    rating: 5,
                    commentary: 'Gostei muito',
                    evaluatedAt: DateTime.utc(2026, 11, 13),
                  ),
          ),
        );
      });
      when(
        () => repository.upsertBookReview(
          bookId: 'b1',
          rating: 5,
          commentary: 'Gostei muito',
        ),
      ).thenAnswer((_) async => const Success(null));

      await pumpPage(tester);
      await tester.tap(find.text('Avaliar'));
      await tester.pumpAndSettle();

      expect(find.text('Avaliar livro'), findsOneWidget);
      expect(find.text('Sua nota'), findsOneWidget);
      expect(find.text('Adicione seu comentário (opcional)'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Concluir'), findsOneWidget);

      final dialogRatingFinder = find.descendant(
        of: find.byType(Dialog),
        matching: find.byType(AppStarRating),
      );
      final rating = tester.widget<AppStarRating>(dialogRatingFinder);
      expect(rating.emptyColor, AppColorTokens.light.textMuted);
      expect(
        tester.getCenter(dialogRatingFinder).dx,
        closeTo(tester.getCenter(find.byType(Dialog)).dx, 0.1),
      );

      await tester.tap(find.bySemanticsLabel('5 de 5 estrelas'));
      await tester.enterText(find.byType(TextField), 'Gostei muito');
      await tester.tap(find.widgetWithText(AppButton, 'Concluir'));
      await tester.pumpAndSettle();

      verify(
        () => repository.upsertBookReview(
          bookId: 'b1',
          rating: 5,
          commentary: 'Gostei muito',
        ),
      ).called(1);
      expect(find.text('Avaliar livro'), findsNothing);
      expect(find.text('Já lido'), findsOneWidget);
    });

    testWidgets('meets the 48px touch target on the actions', (tester) async {
      stubDetails(_details());

      await pumpPage(tester);

      expect(
        tester.getSize(find.widgetWithText(AppButton, 'Avaliar')).height,
        greaterThanOrEqualTo(48),
      );
    });

    testWidgets('offers to edit when the reader already reviewed', (
      tester,
    ) async {
      stubDetails(
        _details(
          status: BookReadingStatus.read,
          myReview: MyBookReviewEntity(
            rating: 4,
            evaluatedAt: DateTime.utc(2026, 11, 1),
          ),
        ),
      );

      await pumpPage(tester);

      expect(find.text('Editar avaliação'), findsOneWidget);
      expect(find.text('Avaliar'), findsNothing);
      expect(
        tester.widget<BookDetailHeader>(find.byType(BookDetailHeader)).status,
        ReadingStatusChipState.read,
      );
    });

    testWidgets('explains a missing synopsis and missing reviews', (
      tester,
    ) async {
      stubDetails(_details(synopsis: '  ', reviews: []));

      await pumpPage(tester);

      expect(find.text('Sinopse'), findsOneWidget);
      expect(find.text('Este livro ainda não tem sinopse.'), findsOneWidget);
      expect(find.text('Ainda não há comentários'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('shows loading while the book is fetched', (tester) async {
      final pending = Completer<Result<BookDetailsEntity, BookFailure>>();
      when(
        () => repository.getBookDetails(bookId: 'b1'),
      ).thenAnswer((_) => pending.future);

      await pumpPage(tester, settle: false);
      await tester.pump();

      expect(find.bySemanticsLabel('Carregando livro'), findsOneWidget);
      expect(find.text('Detalhes do livro'), findsOneWidget);

      pending.complete(Success(_details()));
      await tester.pumpAndSettle();
    });

    testWidgets('shows the error and retries', (tester) async {
      when(
        () => repository.getBookDetails(bookId: 'b1'),
      ).thenAnswer((_) async => const Failure(BookDetailsLoadFailure()));

      await pumpPage(tester);

      expect(find.text('Não foi possível carregar o livro.'), findsOneWidget);
      expect(
        tester
            .getSize(find.widgetWithText(AppButton, 'Tentar novamente'))
            .height,
        greaterThanOrEqualTo(48),
      );

      stubDetails(_details());
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailHeader), findsOneWidget);
    });

    testWidgets('explains a missing connection, without the logout exit', (
      tester,
    ) async {
      when(
        () => repository.getBookDetails(bookId: 'b1'),
      ).thenAnswer((_) async => const Failure(BookNetworkFailure()));

      await pumpPage(tester);

      expect(
        find.text(
          'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.text('Sair'), findsNothing);
    });

    testWidgets('offers to log out when the session expired', (tester) async {
      final sessionCubit = MockSessionCubit();
      when(() => sessionCubit.state).thenReturn(const GuestSession());
      when(() => sessionCubit.logOut()).thenAnswer((_) async {});
      when(
        () => repository.getBookDetails(bookId: 'b1'),
      ).thenAnswer((_) async => const Failure(BookSessionExpiredFailure()));

      await pumpPage(tester, sessionCubit: sessionCubit);

      expect(
        find.text(
          'Sua sessão expirou. Saia do app e entre de novo na sua conta.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Sair'));
      verify(() => sessionCubit.logOut()).called(1);
    });

    testWidgets('says when the book does not exist, without retry', (
      tester,
    ) async {
      when(
        () => repository.getBookDetails(bookId: 'b1'),
      ).thenAnswer((_) async => const Failure(BookNotFoundFailure()));

      await pumpPage(tester);

      expect(find.text('Livro não encontrado.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    });
  });

  group('reading status chip', () {
    testWidgets('marks the book as read', (tester) async {
      stubDetails(_details());
      when(
        () => repository.setReadingStatus(
          bookId: 'b1',
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) async => const Success(BookReadingStatus.read));

      final changes = <({BookReadingStatus? status, bool isWrite})>[];
      await pumpPage(
        tester,
        onReadingStatusChanged: (status, {required isWrite}) =>
            changes.add((status: status, isWrite: isWrite)),
      );
      // Ao carregar sem status, avisa mesmo assim: a busca pode estar velha.
      expect(changes, [(status: null, isWrite: false)]);

      await tester.tap(find.text('Marcar como lido'));
      await tester.pumpAndSettle();

      expect(find.text('Já lido'), findsOneWidget);
      expect(changes, [
        (status: null, isWrite: false),
        (status: BookReadingStatus.read, isWrite: true),
      ]);
    });

    testWidgets('shows an error toast when the update fails', (tester) async {
      stubDetails(_details());
      when(
        () => repository.setReadingStatus(
          bookId: 'b1',
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) async => const Failure(BookStatusFailure()));

      await pumpPage(tester);
      await tester.tap(find.text('Marcar como lido'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Não foi possível atualizar o status de leitura.'),
        findsOneWidget,
      );
      expect(find.text('Marcar como lido'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  group('reviews pagination', () {
    testWidgets('loads the next page at the end of the list', (tester) async {
      stubDetails(_details(hasMore: true));
      stubDetails(_details(reviews: [_review('r2')], hasMore: false), page: 2);

      await pumpPage(tester);
      await tester.scrollUntilVisible(
        find.text('Leitora r2'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.byType(BookReviewTile), findsNWidgets(2));
      verify(
        () => repository.getBookDetails(bookId: 'b1', reviewsPage: 2),
      ).called(1);
    });

    testWidgets('offers a retry when the next page fails', (tester) async {
      stubDetails(_details(hasMore: true));
      when(
        () => repository.getBookDetails(bookId: 'b1', reviewsPage: 2),
      ).thenAnswer((_) async => const Failure(BookDetailsLoadFailure()));

      await pumpPage(tester);
      await tester.scrollUntilVisible(
        find.widgetWithText(AppButton, 'Tentar novamente'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Não foi possível carregar mais comentários.'),
        findsOneWidget,
      );

      stubDetails(_details(reviews: [_review('r2')]), page: 2);
      // Rola até o botão inteiro aparecer; ele pode ficar sob a barra inferior.
      final retry = find.widgetWithText(AppButton, 'Tentar novamente');
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry);
      await tester.pumpAndSettle();

      expect(find.text('Leitora r2'), findsOneWidget);
    });
  });

  group('bottom navigation', () {
    testWidgets('the search tab goes back to the search that opened the book', (
      tester,
    ) async {
      stubDetails(_details());
      await pumpPage(tester, initialLocation: QuickAccessRoutes.search);
      await tester.enterText(find.byType(TextField), 'harry');
      await tester.tap(find.text('tela de busca'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsPage), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Busca'));
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailsPage), findsNothing);
      expect(find.text('tela de busca'), findsOneWidget);
      // A busca é a mesma, não recriada: a consulta continua lá.
      expect(find.text('harry'), findsOneWidget);
    });

    testWidgets('the search tab opens the search from a direct link', (
      tester,
    ) async {
      stubDetails(_details());
      await pumpPage(tester);

      await tester.tap(find.bySemanticsLabel('Busca'));
      await tester.pumpAndSettle();

      expect(find.text('tela de busca'), findsOneWidget);
    });
  });
}
