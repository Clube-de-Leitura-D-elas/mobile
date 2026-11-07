import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/domain/entities/book_summary.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_search_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  const book = BookSummary(
    id: 'book-1',
    title: 'Harry Potter e a Pedra Filosofal',
    author: 'J. K. Rowling',
    genre: 'Fantasia',
    coverUrl: null,
    myStatus: null,
  );

  late MockBookRepository repository;

  setUp(() {
    repository = MockBookRepository();
    when(
      () => repository.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((invocation) async {
      final query = invocation.namedArguments[#query] as String?;
      return Success(
        BookPage(
          items: query == 'harry' ? const [book] : const [],
          page: 1,
          pageSize: 20,
          hasMore: false,
        ),
      );
    });
    when(
      () => repository.setReadingStatus(
        bookId: 'book-1',
        status: BookReadingStatus.wantToRead,
      ),
    ).thenAnswer((_) async => const Failure(BookStatusFailure()));

    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<BookRepository>(() => repository);
    serviceLocator.registerFactory<BookSearchCubit>(
      () => BookSearchCubit(bookRepository: serviceLocator<BookRepository>()),
    );
  });

  tearDown(() {
    AppToast.dismiss();
    if (serviceLocator.isRegistered<BookSearchCubit>()) {
      serviceLocator.unregister<BookSearchCubit>();
    }
    if (serviceLocator.isRegistered<BookRepository>()) {
      serviceLocator.unregister<BookRepository>();
    }
  });

  testWidgets('shows the status error toast again after the flag is cleared', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BookSearchPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'harry');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Marcar como lido'));
    await tester.pump();

    expect(
      find.text('Não foi possível atualizar o status de leitura.'),
      findsOneWidget,
    );
    expect(find.text('Marcar como lido'), findsOneWidget);

    AppToast.dismiss();
    await tester.pump();

    await tester.tap(find.text('Marcar como lido'));
    await tester.pump();

    expect(
      find.text('Não foi possível atualizar o status de leitura.'),
      findsOneWidget,
    );

    AppToast.dismiss();
  });
}
