import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_search_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/quick_access/presentation/pages/quick_access_placeholder_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockBookRepository extends Mock implements BookRepository {}

void _registerBookSearch() {
  final repository = MockBookRepository();
  when(
    () => repository.searchBooks(
      query: any(named: 'query'),
      page: any(named: 'page'),
    ),
  ).thenAnswer(
    (_) async => const Success(
      BookPage(items: [], page: 1, pageSize: 20, hasMore: false),
    ),
  );
  serviceLocator.allowReassignment = true;
  serviceLocator.registerFactory<BookRepository>(() => repository);
  serviceLocator.registerFactory<BookSearchCubit>(
    () => BookSearchCubit(bookRepository: serviceLocator<BookRepository>()),
  );
}

void _unregisterBookSearch() {
  if (serviceLocator.isRegistered<BookSearchCubit>()) {
    serviceLocator.unregister<BookSearchCubit>();
  }
  if (serviceLocator.isRegistered<BookRepository>()) {
    serviceLocator.unregister<BookRepository>();
  }
}

void main() {
  group('QuickAccessRoutes', () {
    test('maps every item to its corresponding path', () {
      expect(QuickAccessItem.values.map(QuickAccessRoutes.pathFor).toList(), [
        '/home',
        '/search',
        '/add',
        '/calendar',
        '/profile',
      ]);
    });

    test('identifies valid tab paths', () {
      for (final item in QuickAccessItem.values) {
        expect(
          QuickAccessRoutes.isTabPath(QuickAccessRoutes.pathFor(item)),
          isTrue,
        );
      }
    });

    test('rejects paths that are not tabs', () {
      expect(QuickAccessRoutes.isTabPath('/'), isFalse);
      expect(QuickAccessRoutes.isTabPath('/settings'), isFalse);
      expect(QuickAccessRoutes.isTabPath('/home/details'), isFalse);
      expect(QuickAccessRoutes.isTabPath(''), isFalse);
    });

    test('does not register a duplicate home route', () {
      final routes = QuickAccessRoutes.routes;

      expect(routes, hasLength(4));
      expect(routes.whereType<GoRoute>().map((route) => route.path), [
        '/search',
        '/add',
        '/calendar',
        '/profile',
      ]);
    });

    testWidgets(
      'renders a placeholder with the selected tab for non-profile routes',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: const QuickAccessPlaceholderScreen(
              item: QuickAccessItem.calendar,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(BottomNavigationBarWidget), findsOneWidget);

        final navigationBar = tester.widget<BottomNavigationBarWidget>(
          find.byType(BottomNavigationBarWidget),
        );

        expect(navigationBar.currentIndex, QuickAccessItem.calendar.index);
      },
    );

    testWidgets(
      'renders the book search on /search and ProfilePage on /profile',
      (tester) async {
        _registerBookSearch();
        addTearDown(_unregisterBookSearch);

        final router = GoRouter(
          initialLocation: '/search',
          routes: QuickAccessRoutes.routes,
        );
        final sessionCubit = MockSessionCubit();
        when(() => sessionCubit.state).thenReturn(const GuestSession());

        // No app o SessionCubit fica acima do MaterialApp (main.dart).
        await tester.pumpWidget(
          BlocProvider<SessionCubit>.value(
            value: sessionCubit,
            child: MaterialApp.router(
              theme: AppTheme.light,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('pt'),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BookSearchPage), findsOneWidget);
        expect(find.byType(ProfilePage), findsNothing);

        router.go('/profile');
        await tester.pumpAndSettle();

        expect(find.byType(ProfilePage), findsOneWidget);
        expect(find.byType(BookSearchPage), findsNothing);

        router.go('/calendar');
        await tester.pumpAndSettle();

        expect(find.byType(QuickAccessPlaceholderScreen), findsOneWidget);
        expect(find.byType(BookSearchPage), findsNothing);
      },
    );
  });

  group('QuickAccessNavigation Extension', () {
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockGoRouter = MockGoRouter();
    });

    Widget buildSubject(int currentIndex) {
      return InheritedGoRouter(
        goRouter: mockGoRouter,
        child: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => context.goToQuickAccessTab(
                QuickAccessItem.profile.index,
                currentIndex: currentIndex,
              ),
              child: const Text('Go'),
            );
          },
        ),
      );
    }

    testWidgets(
      'does not navigate if target index is the same as current index',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: buildSubject(QuickAccessItem.profile.index)),
        );

        await tester.tap(find.text('Go'));
        verifyNever(() => mockGoRouter.go(any()));
      },
    );

    testWidgets('navigates to the correct path if target index is different', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: buildSubject(QuickAccessItem.home.index)),
      );

      await tester.tap(find.text('Go'));
      verify(() => mockGoRouter.go('/profile')).called(1);
    });
  });
}
