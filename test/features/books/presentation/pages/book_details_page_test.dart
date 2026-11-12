import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
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
  }) async {
    final router = GoRouter(
      initialLocation: '/books/b1',
      routes: [
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

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        routerConfig: router,
      ),
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

    testWidgets('keeps rate and recommend disabled until their tasks exist', (
      tester,
    ) async {
      stubDetails(_details());

      await pumpPage(tester);

      expect(button(tester, 'Avaliar').onPressed, isNull);
      expect(button(tester, 'Indicar').onPressed, isNull);
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
}
