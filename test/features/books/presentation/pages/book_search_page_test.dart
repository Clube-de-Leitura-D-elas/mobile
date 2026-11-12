import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
        home: BlocProvider(
          create: (_) => serviceLocator<BookSearchCubit>()..load(),
          child: const BookSearchPage(),
        ),
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

  testWidgets('opens the tapped book and follows its new status on return', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, _) => BlocProvider(
            create: (_) => serviceLocator<BookSearchCubit>()..load(),
            child: const BookSearchPage(),
          ),
        ),
        GoRoute(
          path: '/books/:bookId',
          builder: (context, state) {
            final onChanged = state.extra! as ValueChanged<BookReadingStatus?>;
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  onChanged(BookReadingStatus.read);
                  context.pop();
                },
                child: Text('detalhe ${state.pathParameters['bookId']}'),
              ),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'harry');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Harry Potter e a Pedra Filosofal'));
    await tester.pumpAndSettle();
    expect(find.text('detalhe book-1'), findsOneWidget);

    await tester.tap(find.text('detalhe book-1'));
    await tester.pumpAndSettle();

    expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);
    expect(find.text('Já lido'), findsOneWidget);
  });
}
