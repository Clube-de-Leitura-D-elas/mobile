import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_recommendation_group.dart';
import 'package:mobile/features/books/domain/entities/book_recommendation_outcome.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_details_page.dart';
import 'package:mobile/features/books/presentation/routes/book_recommendation_target.dart';
import 'package:mobile/features/books/presentation/widgets/book_detail_header.dart';
import 'package:mobile/features/books/presentation/widgets/book_review_tile.dart';
import 'package:mobile/features/books/presentation/widgets/group_select_tile.dart';
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
    BookRecommendationTarget? recommendationTarget,
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
              recommendationTarget: recommendationTarget,
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
    final session = sessionCubit ?? MockSessionCubit();
    if (sessionCubit == null) {
      when(() => session.state).thenReturn(const GuestSession());
    }
    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(value: session, child: app),
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

    testWidgets('enables both book actions', (tester) async {
      stubDetails(_details());

      await pumpPage(tester);

      expect(button(tester, 'Avaliar').onPressed, isNotNull);
      expect(button(tester, 'Indicar').onPressed, isNotNull);
    });

    testWidgets('opens the recommendation groups dialog', (tester) async {
      stubDetails(_details());
      when(
        () => repository.getBookRecommendationGroups(bookId: 'b1'),
      ).thenAnswer(
        (_) async => const Success([
          BookRecommendationGroup(
            id: 'g1',
            name: 'Grupo Aurora',
            alreadyRecommended: false,
          ),
          BookRecommendationGroup(
            id: 'g2',
            number: 7,
            name: 'Raw Backend Name',
            alreadyRecommended: false,
          ),
        ]),
      );

      await pumpPage(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pumpAndSettle();

      expect(find.text('Selecione o grupo'), findsOneWidget);
      expect(find.text('Grupo Aurora'), findsOneWidget);
      expect(find.text('Grupo 7'), findsOneWidget);
      verify(
        () => repository.getBookRecommendationGroups(bookId: 'b1'),
      ).called(1);
    });

    testWidgets(
      'opens dialog immediately on first tap and prevents duplicate dialogs on double tap',
      (tester) async {
        stubDetails(_details());
        final pending =
            Completer<Result<List<BookRecommendationGroup>, BookFailure>>();
        when(
          () => repository.getBookRecommendationGroups(bookId: 'b1'),
        ).thenAnswer((_) => pending.future);

        await pumpPage(tester);
        final recommendFinder = find.widgetWithText(AppButton, 'Indicar');
        await tester.tap(recommendFinder);
        await tester.pump();
        await tester.tap(recommendFinder, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.bySemanticsLabel('Carregando grupos'), findsOneWidget);
        expect(button(tester, 'Indicar').onPressed, isNull);
        verify(
          () => repository.getBookRecommendationGroups(bookId: 'b1'),
        ).called(1);

        pending.complete(const Success([]));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'shows an empty state when there are no recommendation groups',
      (tester) async {
        stubDetails(_details());
        when(
          () => repository.getBookRecommendationGroups(bookId: 'b1'),
        ).thenAnswer((_) async => const Success([]));

        await pumpPage(tester);
        await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Você ainda não participa de nenhum grupo.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows a retry action when recommendation groups fail', (
      tester,
    ) async {
      stubDetails(_details());
      final pending =
          Completer<Result<List<BookRecommendationGroup>, BookFailure>>();
      when(
        () => repository.getBookRecommendationGroups(bookId: 'b1'),
      ).thenAnswer((_) => pending.future);

      await pumpPage(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pump();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      pending.complete(const Failure(BookDetailsLoadFailure()));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar os grupos.'), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Tentar novamente'),
        findsOneWidget,
      );
    });

    testWidgets(
      'keeps recommendation error visible across unrelated cubit emissions',
      (tester) async {
        stubDetails(_details());
        when(
          () => repository.getBookRecommendationGroups(bookId: 'b1'),
        ).thenAnswer((_) async => const Failure(BookDetailsLoadFailure()));
        when(
          () => repository.setReadingStatus(
            bookId: 'b1',
            status: BookReadingStatus.read,
          ),
        ).thenAnswer((_) async => const Success(BookReadingStatus.read));

        await pumpPage(tester);
        await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(AppButton, 'Tentar novamente'),
          findsOneWidget,
        );

        await tester
            .element(find.byType(Dialog))
            .read<BookDetailsCubit>()
            .toggleReadingStatus();
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(AppButton, 'Tentar novamente'),
          findsOneWidget,
        );
        expect(
          find.text('Você ainda não participa de nenhum grupo.'),
          findsNothing,
        );
      },
    );

    testWidgets('shows loading when retrying recommendation groups', (
      tester,
    ) async {
      stubDetails(_details());

      final pending =
          Completer<Result<List<BookRecommendationGroup>, BookFailure>>();

      var calls = 0;

      when(
        () => repository.getBookRecommendationGroups(bookId: 'b1'),
      ).thenAnswer((_) async {
        calls++;

        if (calls == 1) {
          return const Failure(BookDetailsLoadFailure());
        }

        return pending.future;
      });

      await pumpPage(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Tentar novamente'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      pending.complete(
        const Success([
          BookRecommendationGroup(
            id: 'g1',
            name: 'Grupo Aurora',
            alreadyRecommended: false,
          ),
        ]),
      );

      await tester.pumpAndSettle();

      expect(find.text('Grupo Aurora'), findsOneWidget);
    });

    testWidgets('closes the groups dialog after a successful selection', (
      tester,
    ) async {
      stubDetails(_details());
      when(
        () => repository.getBookRecommendationGroups(bookId: 'b1'),
      ).thenAnswer(
        (_) async => const Success([
          BookRecommendationGroup(
            id: 'g1',
            name: 'Grupo Aurora',
            alreadyRecommended: false,
          ),
        ]),
      );
      when(
        () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
      ).thenAnswer(
        (_) async => const Success(BookRecommendationOutcome.created),
      );

      await pumpPage(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Grupo Aurora'));
      await tester.pumpAndSettle();

      expect(find.text('Selecione o grupo'), findsNothing);
      expect(find.text('Livro indicado ao Grupo Aurora'), findsOneWidget);
    });

    testWidgets(
      'shows update toast and closes dialog when replacing active recommendation',
      (tester) async {
        stubDetails(_details());
        when(
          () => repository.getBookRecommendationGroups(bookId: 'b1'),
        ).thenAnswer(
          (_) async => const Success([
            BookRecommendationGroup(
              id: 'g1',
              number: 1,
              name: 'Grupo 1',
              alreadyRecommended: false,
            ),
          ]),
        );
        when(
          () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
        ).thenAnswer(
          (_) async => const Success(BookRecommendationOutcome.replaced),
        );

        await pumpPage(tester);
        await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Grupo 1'));
        await tester.pumpAndSettle();

        expect(find.text('Selecione o grupo'), findsNothing);
        expect(find.text('Indicação atualizada para o Grupo 1'), findsOneWidget);
      },
    );

    testWidgets(
      'opens informative modal and preserves groups dialog when reader is blocked by host rotation',
      (tester) async {
        stubDetails(_details());
        when(
          () => repository.getBookRecommendationGroups(bookId: 'b1'),
        ).thenAnswer(
          (_) async => const Success([
            BookRecommendationGroup(
              id: 'g1',
              number: 1,
              name: 'Grupo 1',
              alreadyRecommended: false,
              canRecommend: false,
            ),
          ]),
        );
        when(
          () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
        ).thenAnswer(
          (_) async => const Failure(BookRecommendationHostBlockedFailure()),
        );

        await pumpPage(tester);
        await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Grupo 1'));
        await tester.pumpAndSettle();

        expect(find.text('Indicação indisponível'), findsOneWidget);
        expect(
          find.text(
            'Você já foi sorteada como anfitriã neste grupo e não pode indicar livros no momento.',
          ),
          findsOneWidget,
        );
        expect(find.text('Entendi'), findsOneWidget);

        await tester.tap(find.text('Entendi'));
        await tester.pumpAndSettle();

        expect(find.text('Indicação indisponível'), findsNothing);
        expect(find.text('Selecione o grupo'), findsOneWidget);
      },
    );

    testWidgets('closes the groups dialog when tapping close while idle', (
      tester,
    ) async {
      stubDetails(_details());
      when(
        () => repository.getBookRecommendationGroups(bookId: 'b1'),
      ).thenAnswer(
        (_) async => const Success([
          BookRecommendationGroup(
            id: 'g1',
            number: 1,
            name: 'Grupo 1',
            alreadyRecommended: false,
          ),
        ]),
      );

      await pumpPage(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pumpAndSettle();
      expect(find.text('Selecione o grupo'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar'));
      await tester.pumpAndSettle();

      expect(find.text('Selecione o grupo'), findsNothing);
    });

    testWidgets('keeps the dialog open when recommendation fails', (
      tester,
    ) async {
      stubDetails(_details());

      when(
        () => repository.getBookRecommendationGroups(bookId: 'b1'),
      ).thenAnswer(
        (_) async => const Success([
          BookRecommendationGroup(
            id: 'g1',
            name: 'Grupo Aurora',
            alreadyRecommended: false,
          ),
        ]),
      );

      when(
        () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
      ).thenAnswer((_) async => const Failure(BookRecommendationFailure()));

      await pumpPage(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Grupo Aurora'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Selecione o grupo'), findsOneWidget);
      expect(find.text('Grupo Aurora'), findsOneWidget);
      expect(find.text('Não foi possível indicar o livro.'), findsOneWidget);
    });

    testWidgets(
      'disables dialog tiles and closing while recommending in modal',
      (tester) async {
        stubDetails(_details());
        when(
          () => repository.getBookRecommendationGroups(bookId: 'b1'),
        ).thenAnswer(
          (_) async => const Success([
            BookRecommendationGroup(
              id: 'g1',
              number: 1,
              name: 'Grupo 1',
              alreadyRecommended: false,
            ),
            BookRecommendationGroup(
              id: 'g2',
              number: 2,
              name: 'Grupo 2',
              alreadyRecommended: false,
            ),
          ]),
        );
        final pending =
            Completer<Result<BookRecommendationOutcome, BookFailure>>();
        when(
          () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
        ).thenAnswer((_) => pending.future);

        await pumpPage(tester);
        await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Grupo 1'));
        await tester.pump();

        final tiles = tester
            .widgetList<GroupSelectTile>(find.byType(GroupSelectTile))
            .toList();
        expect(tiles.every((tile) => tile.onTap == null), isTrue);

        final popScope = tester.widget<PopScope<dynamic>>(
          find.byWidgetPredicate(
            (w) => w is PopScope && w.child is AppDialog,
          ),
        );
        expect(popScope.canPop, isFalse);

        await tester.tap(find.byTooltip('Fechar'));
        await tester.pump();
        expect(find.text('Selecione o grupo'), findsOneWidget);

        pending.complete(const Success(BookRecommendationOutcome.created));
        await tester.pumpAndSettle();

        expect(find.text('Selecione o grupo'), findsNothing);
        expect(find.text('Livro indicado ao Grupo 1'), findsOneWidget);
      },
    );

    testWidgets('indicates directly for a preselected group', (tester) async {
      stubDetails(_details());
      final pending =
          Completer<Result<BookRecommendationOutcome, BookFailure>>();
      when(
        () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
      ).thenAnswer((_) => pending.future);

      await pumpPage(
        tester,
        recommendationTarget: const BookRecommendationTarget(
          groupId: 'g1',
          groupName: 'Grupo Aurora',
        ),
      );
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pump();

      final recommendBtnFinder = find.byWidgetPredicate(
        (w) => w is AppButton && w.label == 'Indicar',
      );
      final loadingBtn = tester.widget<AppButton>(recommendBtnFinder);
      expect(loadingBtn.isLoading, isTrue);
      expect(
        find.descendant(
          of: recommendBtnFinder,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      pending.complete(const Success(BookRecommendationOutcome.created));
      await tester.pumpAndSettle();

      verify(
        () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
      ).called(1);
      expect(find.text('Livro indicado ao Grupo Aurora'), findsOneWidget);
      expect(button(tester, 'Indicar').isLoading, isFalse);
    });

    testWidgets(
      'opens informative modal when preselected group blocks host',
      (tester) async {
        stubDetails(_details());
        when(
          () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
        ).thenAnswer(
          (_) async => const Failure(BookRecommendationHostBlockedFailure()),
        );

        await pumpPage(
          tester,
          recommendationTarget: const BookRecommendationTarget(
            groupId: 'g1',
            groupName: 'Grupo Aurora',
          ),
        );
        await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
        await tester.pumpAndSettle();

        expect(find.text('Indicação indisponível'), findsOneWidget);
        expect(
          find.text(
            'Você já foi sorteada como anfitriã neste grupo e não pode indicar livros no momento.',
          ),
          findsOneWidget,
        );
        expect(find.text('Entendi'), findsOneWidget);

        await tester.tap(find.text('Entendi'));
        await tester.pumpAndSettle();

        expect(find.text('Indicação indisponível'), findsNothing);
        expect(find.widgetWithText(AppButton, 'Indicar'), findsOneWidget);
      },
    );

    testWidgets('shows an info toast when the book was already indicated', (
      tester,
    ) async {
      stubDetails(_details());
      when(
        () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
      ).thenAnswer((_) async => const Failure(BookAlreadyRecommendedFailure()));

      await pumpPage(
        tester,
        recommendationTarget: const BookRecommendationTarget(
          groupId: 'g1',
          groupName: 'Grupo Aurora',
        ),
      );
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pump();

      expect(
        find.text('Este livro já foi indicado para este grupo.'),
        findsOneWidget,
      );
    });

    testWidgets('shows an error toast when recommendation fails', (
      tester,
    ) async {
      stubDetails(_details());
      when(
        () => repository.recommendBook(bookId: 'b1', groupId: 'g1'),
      ).thenAnswer((_) async => const Failure(BookRecommendationFailure()));

      await pumpPage(
        tester,
        recommendationTarget: const BookRecommendationTarget(
          groupId: 'g1',
          groupName: 'Grupo Aurora',
        ),
      );
      await tester.tap(find.widgetWithText(AppButton, 'Indicar'));
      await tester.pump();

      expect(find.text('Não foi possível indicar o livro.'), findsOneWidget);
    });

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

    testWidgets('shows an error toast when saving a review fails', (
      tester,
    ) async {
      stubDetails(_details());
      when(
        () => repository.upsertBookReview(
          bookId: 'b1',
          rating: 5,
          commentary: null,
        ),
      ).thenAnswer((_) async => const Failure(BookReviewFailure()));

      await pumpPage(tester);
      await tester.tap(find.text('Avaliar'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('5 de 5 estrelas'));
      await tester.pump();
      await tester.tap(find.widgetWithText(AppButton, 'Concluir'));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível salvar sua avaliação.'), findsOneWidget);
      expect(find.text('Avaliar livro'), findsOneWidget);
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

    testWidgets('shows the reader own review first, with her name', (
      tester,
    ) async {
      final sessionCubit = MockSessionCubit();
      when(() => sessionCubit.state).thenReturn(
        const AuthenticatedSession(
          user: UserEntity(
            name: 'Ana Leitora',
            mail: 'ana@example.com',
            birthday: '01/01/1990',
            phoneNumber: '51999999999',
            instagramUser: '@ana',
            educationDegree: 'Superior',
            jobPosition: 'Professora',
            cityZone: (id: 'z1', name: 'Centro', acronym: 'POA'),
          ),
          profile: UserProfileEntity(
            id: 'p1',
            name: 'Ana Leitora',
            email: 'ana@example.com',
            address: '',
            phoneNumber: '51999999999',
            birthday: '01/01/1990',
            instagram: '@ana',
            educationDegree: 'Superior',
            jobPosition: 'Professora',
            userId: 'u1',
            isActive: true,
          ),
        ),
      );
      stubDetails(
        _details(
          myReview: MyBookReviewEntity(
            rating: 4,
            commentary: 'Meu comentário',
            evaluatedAt: DateTime.utc(2026, 11, 1),
          ),
        ),
      );

      await pumpPage(tester, sessionCubit: sessionCubit);

      final mine = tester.widget<BookReviewTile>(
        find.byType(BookReviewTile).first,
      );
      expect(mine.name, 'Ana Leitora');
      expect(mine.rating, 4);
      expect(mine.comment, 'Meu comentário');

      await tester.scrollUntilVisible(find.text('Leitora r1'), 200);
      expect(
        tester.getTopLeft(find.text('Leitora r1')).dy,
        greaterThan(tester.getTopLeft(find.text('Ana Leitora')).dy),
      );
    });

    testWidgets('does not say there are no comments when only hers exists', (
      tester,
    ) async {
      stubDetails(
        _details(
          reviews: [],
          myReview: MyBookReviewEntity(
            rating: 5,
            commentary: 'Só o meu',
            evaluatedAt: DateTime.utc(2026, 11, 1),
          ),
        ),
      );

      await pumpPage(tester);

      expect(find.text('Só o meu'), findsOneWidget);
      expect(find.text('Você'), findsOneWidget);
      expect(find.text('Ainda não há comentários'), findsNothing);
    });

    testWidgets('opens an existing review with its previous commentary', (
      tester,
    ) async {
      stubDetails(
        _details(
          status: BookReadingStatus.read,
          myReview: MyBookReviewEntity(
            rating: 4,
            commentary: 'Minha avaliação anterior',
            evaluatedAt: DateTime.utc(2026, 11, 1),
          ),
        ),
      );

      await pumpPage(tester);

      await tester.tap(find.text('Editar avaliação'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'Minha avaliação anterior',
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

    testWidgets('shows loading while updating the reading status', (
      tester,
    ) async {
      stubDetails(_details());

      final pending = Completer<Result<BookReadingStatus?, BookFailure>>();

      when(
        () => repository.setReadingStatus(
          bookId: 'b1',
          status: BookReadingStatus.read,
        ),
      ).thenAnswer((_) => pending.future);

      await pumpPage(tester);

      await tester.tap(find.text('Marcar como lido'));
      await tester.pump();

      final header = tester.widget<BookDetailHeader>(
        find.byType(BookDetailHeader),
      );

      expect(header.isStatusLoading, isTrue);

      pending.complete(const Success(BookReadingStatus.read));
      await tester.pumpAndSettle();

      final updatedHeader = tester.widget<BookDetailHeader>(
        find.byType(BookDetailHeader),
      );

      expect(updatedHeader.isStatusLoading, isFalse);
      expect(updatedHeader.status, ReadingStatusChipState.read);
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
    testWidgets('does not load more reviews when there are none available', (
      tester,
    ) async {
      stubDetails(_details(hasMore: false));

      await pumpPage(tester);

      expect(find.byType(BookReviewTile), findsOneWidget);

      verifyNever(
        () => repository.getBookDetails(bookId: 'b1', reviewsPage: 2),
      );
    });

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
