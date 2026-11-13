import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
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
import 'package:mobile/features/calendar/domain/repository/calendar_repository.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mobile/features/calendar/presentation/pages/calendar_page.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/pages/group_search_view.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/quick_access/presentation/pages/search_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockBookRepository extends Mock implements BookRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

MockProfileRepository _registerProfileSummary() {
  final repository = MockProfileRepository();
  when(() => repository.getProfileSummary()).thenAnswer(
    (_) async => const Success(ProfileSummaryEntity(booksReadCount: 0)),
  );
  serviceLocator.allowReassignment = true;
  serviceLocator.registerFactory<ProfileSummaryCubit>(
    () => ProfileSummaryCubit(repository: repository),
  );
  return repository;
}

void _unregisterProfileSummary() {
  if (serviceLocator.isRegistered<ProfileSummaryCubit>()) {
    serviceLocator.unregister<ProfileSummaryCubit>();
  }
}

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

class MockCalendarRepository extends Mock implements CalendarRepository {}

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

void _registerGroupSearch() {
  final repository = MockGroupDiscoveryRepository();
  when(
    () => repository.searchGroups(
      page: any(named: 'page'),
      search: any(named: 'search'),
      filters: any(named: 'filters'),
    ),
  ).thenAnswer(
    (_) async =>
        const Success(GroupSearchPageEntity(items: [], total: 0, genres: [])),
  );
  serviceLocator.registerFactory<GroupSearchCubit>(
    () => GroupSearchCubit(repository: repository),
  );
}

void _unregisterGroupSearch() {
  if (serviceLocator.isRegistered<GroupSearchCubit>()) {
    serviceLocator.unregister<GroupSearchCubit>();
  }
}

void _unregisterBookSearch() {
  if (serviceLocator.isRegistered<BookSearchCubit>()) {
    serviceLocator.unregister<BookSearchCubit>();
  }
  if (serviceLocator.isRegistered<BookRepository>()) {
    serviceLocator.unregister<BookRepository>();
  }
}

void _registerCalendar() {
  final repository = MockCalendarRepository();
  when(
    () => repository.getMeetings(
      from: any(named: 'from'),
      to: any(named: 'to'),
    ),
  ).thenAnswer((_) async => const Success([]));
  serviceLocator.registerFactory<CalendarCubit>(
    () => CalendarCubit(repository: repository),
  );
}

void _unregisterCalendar() {
  if (serviceLocator.isRegistered<CalendarCubit>()) {
    serviceLocator.unregister<CalendarCubit>();
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(GroupSearchFilters.empty);
  });

  group('QuickAccessRoutes', () {
    test('maps every item to its corresponding path', () {
      expect(QuickAccessItem.values.map(QuickAccessRoutes.pathFor).toList(), [
        '/home',
        '/search',
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

      expect(routes, hasLength(3));
      expect(routes.whereType<GoRoute>().map((route) => route.path), [
        '/search',
        '/calendar',
        '/profile',
      ]);
    });

    testWidgets(
      'renders the book search, the profile and the calendar on their tabs',
      (tester) async {
        final allowReassignment = serviceLocator.allowReassignment;
        addTearDown(() => serviceLocator.allowReassignment = allowReassignment);
        _registerBookSearch();
        addTearDown(_unregisterBookSearch);
        final profileRepository = _registerProfileSummary();
        addTearDown(_unregisterProfileSummary);
        _registerCalendar();
        addTearDown(_unregisterCalendar);
        _registerGroupSearch();
        addTearDown(_unregisterGroupSearch);

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
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('pt'),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Cada aba marca o próprio item da barra (agora sem o "Adicionar").
        void expectSelected(QuickAccessItem item) {
          final bar = tester.widget<BottomNavigationBarWidget>(
            find.byType(BottomNavigationBarWidget),
          );
          expect(bar.currentIndex, item.index);
        }

        expect(find.byType(SearchPage), findsOneWidget);
        expect(find.byType(BookSearchPage), findsOneWidget);
        expect(find.byType(ProfilePage), findsNothing);
        expectSelected(QuickAccessItem.search);

        await tester.tap(find.text('Grupos'));
        await tester.pumpAndSettle();

        expect(find.byType(GroupSearchView), findsOneWidget);

        router.go('/profile');
        await tester.pumpAndSettle();

        expect(find.byType(ProfilePage), findsOneWidget);
        expect(find.byType(BookSearchPage), findsNothing);
        expectSelected(QuickAccessItem.profile);
        // A aba do perfil já abre carregando livros lidos, grupos e avaliações.
        verify(() => profileRepository.getProfileSummary()).called(1);

        router.go('/calendar');
        await tester.pumpAndSettle();

        expect(find.byType(CalendarPage), findsOneWidget);
        expectSelected(QuickAccessItem.calendar);

        // Tocar num item da barra abre a aba dele, pela ordem nova.
        await tester.tap(find.bySemanticsLabel('Perfil'));
        await tester.pumpAndSettle();
        expect(find.byType(ProfilePage), findsOneWidget);
        expectSelected(QuickAccessItem.profile);

        await tester.tap(find.bySemanticsLabel('Calendário'));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        expectSelected(QuickAccessItem.calendar);

        await tester.tap(find.bySemanticsLabel('Busca'));
        await tester.pumpAndSettle();
        expect(find.byType(SearchPage), findsOneWidget);
        expectSelected(QuickAccessItem.search);
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
