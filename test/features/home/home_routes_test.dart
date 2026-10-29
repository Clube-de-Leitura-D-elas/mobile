import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/features/home/presentation/pages/pending_tasks_screen.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockBuildContext extends Mock implements BuildContext {}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
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

  late MockGroupRepository repository;
  late MockSessionCubit sessionCubit;

  setUp(() {
    repository = MockGroupRepository();
    sessionCubit = MockSessionCubit();
    when(
      () => repository.getMyGroups(),
    ).thenAnswer((_) async => const Success(<GroupEntity>[]));
    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<HomeCubit>(
      () => HomeCubit(groupRepository: repository),
    );
  });

  tearDown(() {
    if (serviceLocator.isRegistered<HomeCubit>()) {
      serviceLocator.unregister<HomeCubit>();
    }
  });

  void stubSession(SessionState state) {
    whenListen(
      sessionCubit,
      const Stream<SessionState>.empty(),
      initialState: state,
    );
  }

  Future<void> pumpRouter(WidgetTester tester, String initialLocation) async {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: HomeRoutes.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp.router(
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
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home route renders HomeScreen for an authenticated session', (
    tester,
  ) async {
    stubSession(const AuthenticatedSession(user: testUser));

    await pumpRouter(tester, HomeRoutes.home);

    expect(find.byType(HomeScreen), findsOneWidget);
    verify(() => repository.getMyGroups()).called(1);
  });

  testWidgets('home route renders an empty page without a session', (
    tester,
  ) async {
    stubSession(const GuestSession());

    await pumpRouter(tester, HomeRoutes.home);

    expect(find.byType(HomeScreen), findsNothing);
    verifyNever(() => repository.getMyGroups());
  });

  testWidgets('pending tasks route renders PendingTasksScreen', (tester) async {
    stubSession(const AuthenticatedSession(user: testUser));

    await pumpRouter(tester, HomeRoutes.pendingTasks);

    expect(find.byType(PendingTasksScreen), findsOneWidget);
    expect(find.text('Você não tem tarefas pendentes'), findsOneWidget);
    verify(() => repository.getMyGroups()).called(1);
  });

  group('HomeRoutes.homeGuard', () {
    late MockBuildContext context;
    late MockGoRouterState routerState;

    setUp(() {
      context = MockBuildContext();
      routerState = MockGoRouterState();
    });

    test('redirects unauthenticated access on /pending-tasks to /login', () {
      when(
        () => routerState.matchedLocation,
      ).thenReturn(HomeRoutes.pendingTasks);

      final redirect = HomeRoutes.homeGuard(
        context,
        routerState,
        const GuestSession(),
      );

      expect(redirect, '/login');
    });

    test('allows authenticated access on /pending-tasks', () {
      when(
        () => routerState.matchedLocation,
      ).thenReturn(HomeRoutes.pendingTasks);

      final redirect = HomeRoutes.homeGuard(
        context,
        routerState,
        const AuthenticatedSession(user: testUser),
      );

      expect(redirect, isNull);
    });
  });
}
