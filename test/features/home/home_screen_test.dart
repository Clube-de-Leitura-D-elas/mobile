import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/app_route_observer.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_search_page.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/features/home/presentation/widgets/home_pending_tasks_banner.dart';
import 'package:mobile/features/notifications/domain/entities/notifications_page_entity.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'package:mobile/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockBookRepository extends Mock implements BookRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

Widget withBell(Widget child) => BlocProvider(
  create: (_) {
    final repository = MockNotificationRepository();
    // O sino se atualiza ao voltar para a home (didPopNext).
    when(
      () => repository.getNotifications(page: any(named: 'page')),
    ).thenAnswer(
      (_) async => const Success(
        NotificationsPageEntity(items: [], total: 0, unreadCount: 0),
      ),
    );
    return NotificationBadgeCubit(repository: repository);
  },
  child: child,
);

void main() {
  const group = GroupEntity(
    id: 'group-1',
    number: 1,
    participantsCount: 3,
    cityState: 'Porto Alegre, RS',
  );

  setUp(() {
    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<GroupRepository>(MockGroupRepository.new);

    final books = MockBookRepository();
    when(
      () => books.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => const Success(
        BookPage(items: [], page: 1, pageSize: 20, hasMore: false),
      ),
    );
    serviceLocator.registerFactory<BookRepository>(() => books);
    serviceLocator.registerFactory<BookSearchCubit>(
      () => BookSearchCubit(bookRepository: serviceLocator<BookRepository>()),
    );
  });

  tearDown(() {
    if (serviceLocator.isRegistered<BookSearchCubit>()) {
      serviceLocator.unregister<BookSearchCubit>();
    }
    if (serviceLocator.isRegistered<BookRepository>()) {
      serviceLocator.unregister<BookRepository>();
    }
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
  });

  Widget buildSubject(HomeCubit homeCubit, SessionCubit sessionCubit) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider.value(
        value: sessionCubit,
        child: BlocProvider.value(
          value: homeCubit,
          child: withBell(const HomeScreen()),
        ),
      ),
    );
  }

  testWidgets('shows the notification bell in the header', (tester) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Success([group]));
    final cubit = HomeCubit(groupRepository: repository);

    await tester.pumpWidget(buildSubject(cubit, MockSessionCubit()));
    await tester.pump();

    expect(find.byType(NotificationBell), findsOneWidget);
    expect(find.byTooltip('Notificações'), findsOneWidget);
  });

  testWidgets('renders groups loaded from the repository', (tester) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Success([group]));
    final cubit = HomeCubit(groupRepository: repository);
    final sessionCubit = MockSessionCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, sessionCubit));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(find.text('Meus grupos'), findsOneWidget);
    expect(find.text('Grupo 1'), findsOneWidget);
    expect(find.text('3 participantes'), findsOneWidget);
    expect(find.text('Porto Alegre, RS'), findsOneWidget);
    expect(find.byType(BottomNavigationBarWidget), findsOneWidget);
  });

  testWidgets('hides the pending tasks banner when there are no host tasks', (
    tester,
  ) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Success([group]));
    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, MockSessionCubit()));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(find.byType(HomePendingTasksBanner), findsNothing);
    expect(find.text('Todos'), findsNothing);
  });

  testWidgets('shows the pending tasks banner when the host has tasks', (
    tester,
  ) async {
    final repository = MockGroupRepository();
    when(() => repository.getMyGroups()).thenAnswer(
      (_) async => Success([
        group.copyWith(
          nextMeeting: const GroupMeeting(
            id: 'meeting-1',
            hostName: 'Ana',
            bookTitle: 'Livro',
            date: '08/11/2026',
            location: 'Casa da Ana',
            canManageTasks: true,
            tasksDone: 1,
          ),
        ),
      ]),
    );
    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, MockSessionCubit()));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(find.byType(HomePendingTasksBanner), findsOneWidget);
    expect(find.text('Você tem tarefas pendentes'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Você tem tarefas pendentes, Tarefas'),
      findsOneWidget,
    );
  });

  testWidgets(
    'opens the pending tasks screen and reloads groups when returning',
    (tester) async {
      final repository = MockGroupRepository();
      when(() => repository.getMyGroups()).thenAnswer(
        (_) async => Success([
          group.copyWith(
            nextMeeting: const GroupMeeting(
              id: 'meeting-1',
              hostName: 'Ana',
              bookTitle: 'Livro',
              date: '08/11/2026',
              location: 'Casa da Ana',
              canManageTasks: true,
              tasksDone: 1,
            ),
          ),
        ]),
      );
      final cubit = HomeCubit(groupRepository: repository);
      addTearDown(cubit.close);

      final router = GoRouter(
        initialLocation: QuickAccessRoutes.home,
        observers: [appRouteObserver],
        routes: [
          GoRoute(
            path: QuickAccessRoutes.home,
            builder: (context, state) => BlocProvider.value(
              value: cubit,
              child: withBell(const HomeScreen()),
            ),
          ),
          GoRoute(
            path: HomeRoutes.pendingTasks,
            builder: (context, state) =>
                const Scaffold(body: Text('Tela de tarefas pendentes')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await cubit.loadGroups();
      await tester.pumpAndSettle();

      // O banner inteiro é clicável, não só o chip "Tarefas".
      await tester.tap(find.text('Você tem tarefas pendentes'));
      await tester.pumpAndSettle();

      expect(find.text('Tela de tarefas pendentes'), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      verify(() => repository.getMyGroups()).called(2);
    },
  );

  testWidgets(
    'refreshes groups without the loading state when returning from any screen',
    (tester) async {
      final repository = MockGroupRepository();
      var calls = 0;
      when(() => repository.getMyGroups()).thenAnswer((_) async {
        calls++;
        return Success([group.copyWith(participantsCount: calls == 1 ? 3 : 4)]);
      });
      final cubit = HomeCubit(groupRepository: repository);
      addTearDown(cubit.close);
      final states = <HomeStatus>[];
      final sub = cubit.stream.listen((state) => states.add(state.status));
      addTearDown(sub.cancel);

      final router = GoRouter(
        initialLocation: QuickAccessRoutes.home,
        observers: [appRouteObserver],
        routes: [
          GoRoute(
            path: QuickAccessRoutes.home,
            builder: (context, state) => BlocProvider.value(
              value: cubit,
              child: withBell(const HomeScreen()),
            ),
          ),
          GoRoute(
            path: '/group-details',
            builder: (context, state) =>
                const Scaffold(body: Text('Detalhe do grupo')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await cubit.loadGroups();
      await tester.pumpAndSettle();
      expect(cubit.state.groups.single.participantsCount, 3);
      states.clear();

      unawaited(router.push('/group-details'));
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();

      expect(cubit.state.groups.single.participantsCount, 4);
      expect(states, isNot(contains(HomeStatus.loading)));
      verify(() => repository.getMyGroups()).called(2);
    },
  );

  testWidgets(
    'shows loading instead of the empty state while fetching groups',
    (tester) async {
      final pending = Completer<Result<List<GroupEntity>, GroupFailure>>();
      final repository = MockGroupRepository();
      when(() => repository.getMyGroups()).thenAnswer((_) => pending.future);
      final cubit = HomeCubit(groupRepository: repository);
      final sessionCubit = MockSessionCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit, sessionCubit));
      unawaited(cubit.loadGroups());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.text('Você ainda não participa de nenhum grupo'),
        findsNothing,
      );

      pending.complete(const Success([]));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('renders the empty state when the participant has no groups', (
    tester,
  ) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Success(<GroupEntity>[]));
    final cubit = HomeCubit(groupRepository: repository);
    final sessionCubit = MockSessionCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, sessionCubit));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(
      find.text('Você ainda não participa de nenhum grupo'),
      findsOneWidget,
    );
  });

  testWidgets('renders a retry action when loading groups fails', (
    tester,
  ) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Failure(GroupListFailure()));
    final cubit = HomeCubit(groupRepository: repository);
    final sessionCubit = MockSessionCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, sessionCubit));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar seus grupos. Tente novamente.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('hides retry when loading groups is forbidden', (tester) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Failure(GroupForbiddenFailure()));
    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, MockSessionCubit()));
    await cubit.loadGroups();
    await tester.pumpAndSettle();

    expect(
      find.text('Você não tem permissão para fazer isso.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('offers logout when the session expired', (tester) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Failure(GroupSessionExpiredFailure()));
    final cubit = HomeCubit(groupRepository: repository);
    final sessionCubit = MockSessionCubit();
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit, sessionCubit));
    await cubit.loadGroups();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair'));

    verify(() => sessionCubit.logOut()).called(1);
  });

  testWidgets('navigates to the selected tab from the home screen', (
    tester,
  ) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Success(<GroupEntity>[]));

    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    final router = GoRouter(
      initialLocation: QuickAccessRoutes.home,
      routes: [
        GoRoute(
          path: QuickAccessRoutes.home,
          builder: (context, state) => BlocProvider.value(
            value: cubit,
            child: withBell(const HomeScreen()),
          ),
        ),
        ...QuickAccessRoutes.routes,
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/home');

    await tester.tap(find.bySemanticsLabel('Busca'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/search');
    expect(find.byType(BookSearchPage), findsOneWidget);
  });

  testWidgets('returns to the home tab from the search screen', (tester) async {
    final repository = MockGroupRepository();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Success(<GroupEntity>[]));

    final cubit = HomeCubit(groupRepository: repository);
    addTearDown(cubit.close);

    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: QuickAccessRoutes.home,
          builder: (context, state) => BlocProvider.value(
            value: cubit,
            child: withBell(const HomeScreen()),
          ),
        ),
        ...QuickAccessRoutes.routes,
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/search');
    expect(find.byType(BookSearchPage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Início'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/home');
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets(
    'filters groups using group details label when search query is entered',
    (tester) async {
      final repository = MockGroupRepository();
      when(
        () => repository.getMyGroups(),
      ).thenAnswer((_) async => const Success([group]));

      final cubit = HomeCubit(groupRepository: repository);
      final sessionCubit = MockSessionCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit, sessionCubit));
      await cubit.loadGroups();
      await tester.pumpAndSettle();

      cubit.updateSearch('Grupo 1');
      await tester.pumpAndSettle();

      expect(find.text('Grupo 1'), findsOneWidget);

      cubit.updateSearch('Inexistente');
      await tester.pumpAndSettle();

      expect(find.text('Nenhum grupo encontrado'), findsOneWidget);
    },
  );

  testWidgets(
    'filters groups after the search field debounce and clears the filter',
    (tester) async {
      final repository = MockGroupRepository();
      when(
        () => repository.getMyGroups(),
      ).thenAnswer((_) async => const Success([group]));

      final cubit = HomeCubit(groupRepository: repository);
      final sessionCubit = MockSessionCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(buildSubject(cubit, sessionCubit));
      await cubit.loadGroups();
      await tester.pumpAndSettle();

      expect(find.text('Buscar grupo'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(AppSearchField),
          matching: find.byType(TextField),
        ),
        'Inexistente',
      );
      await tester.pump();

      expect(cubit.state.searchQuery, isEmpty);

      await tester.pump(AppSearchField.defaultDebounce);
      await tester.pumpAndSettle();

      expect(cubit.state.searchQuery, 'Inexistente');
      expect(find.text('Nenhum grupo encontrado'), findsOneWidget);

      await tester.tap(find.byTooltip('Limpar busca'));
      await tester.pumpAndSettle();

      expect(cubit.state.searchQuery, isEmpty);
      expect(find.text('Grupo 1'), findsOneWidget);
    },
  );

  testWidgets(
    'uses onNavigationItemSelected callback and accepts user/profile',
    (tester) async {
      final repository = MockGroupRepository();
      when(
        () => repository.getMyGroups(),
      ).thenAnswer((_) async => const Success(<GroupEntity>[]));

      final cubit = HomeCubit(groupRepository: repository);
      final sessionCubit = MockSessionCubit();
      addTearDown(cubit.close);

      int? selectedIndex;
      const testUser = UserEntity(
        name: 'Ana',
        mail: 'ana@example.com',
        birthday: '01/01/2000',
        phoneNumber: '123',
        instagramUser: '@ana',
        educationDegree: 'Degree',
        jobPosition: 'Dev',
        cityZone: (id: '', name: '', acronym: ''),
      );
      const testProfile = UserProfileEntity(
        id: '1',
        name: 'Ana',
        email: 'ana@example.com',
        address: 'Rua A',
        phoneNumber: '123',
        birthday: '01/01/2000',
        instagram: '@ana',
        educationDegree: 'Degree',
        jobPosition: 'Dev',
        userId: 'u1',
        isActive: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<SessionCubit>.value(
            value: sessionCubit,
            child: BlocProvider<HomeCubit>.value(
              value: cubit,
              child: withBell(
                HomeScreen(
                  user: testUser,
                  profile: testProfile,
                  onNavigationItemSelected: (index) => selectedIndex = index,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Perfil'));
      await tester.pumpAndSettle();

      expect(selectedIndex, QuickAccessItem.profile.index);
    },
  );
}
