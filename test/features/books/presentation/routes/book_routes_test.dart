import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_details_page.dart';
import 'package:mobile/features/books/presentation/routes/book_route_paths.dart';
import 'package:mobile/features/books/presentation/routes/book_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository repository;

  setUp(() {
    repository = MockBookRepository();
    serviceLocator
      ..allowReassignment = true
      ..registerFactory<BookDetailsCubit>(
        () => BookDetailsCubit(repository: repository),
      );
  });

  tearDown(() => serviceLocator.unregister<BookDetailsCubit>());

  test('builds the details path from the book id', () {
    expect(BookRoutePaths.detailsFor('b1'), '/books/b1');
    expect(BookRoutePaths.detailsFor('a b'), '/books/a%20b');
  });

  testWidgets('/books/:bookId loads the book from the path', (tester) async {
    when(() => repository.getBookDetails(bookId: 'b-42')).thenAnswer(
      (_) async => const Success(
        BookDetailsEntity(
          id: 'b-42',
          title: 'Dom Casmurro',
          author: 'Machado de Assis',
          genre: '',
          publisher: '',
          ratingsCount: 0,
        ),
      ),
    );
    final router = GoRouter(
      initialLocation: BookRoutePaths.detailsFor('b-42'),
      routes: BookRoutes.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BookDetailsPage), findsOneWidget);
    expect(find.text('Dom Casmurro'), findsOneWidget);
    verify(() => repository.getBookDetails(bookId: 'b-42')).called(1);
  });

  testWidgets('hands the status callback from extra to the page', (
    tester,
  ) async {
    void onChanged(BookReadingStatus? status) {}
    final router = GoRouter(routes: BookRoutes.routes);
    addTearDown(router.dispose);
    when(
      () => repository.getBookDetails(bookId: 'b-42'),
    ).thenAnswer((_) async => const Failure(BookNotFoundFailure()));

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        routerConfig: router,
      ),
    );
    router.go(BookRoutePaths.detailsFor('b-42'), extra: onChanged);
    await tester.pumpAndSettle();

    final page = tester.widget<BookDetailsPage>(find.byType(BookDetailsPage));
    expect(page.onReadingStatusChanged, onChanged);

    router.go(BookRoutePaths.detailsFor('b-42'), extra: 'outra coisa');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BookDetailsPage>(find.byType(BookDetailsPage))
          .onReadingStatusChanged,
      isNull,
    );
  });
}
