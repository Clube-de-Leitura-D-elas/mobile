import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/features/quick_access/presentation/pages/quick_access_placeholder_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  const group = GroupEntity(
    id: 'group-1',
    number: 1,
    participantsCount: 3,
    cityState: 'Porto Alegre, RS',
  );

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
        child: BlocProvider.value(value: homeCubit, child: const HomeScreen()),
      ),
    );
  }

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
          builder: (context, state) =>
              BlocProvider.value(value: cubit, child: const HomeScreen()),
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
    expect(find.byType(QuickAccessPlaceholderScreen), findsOneWidget);
  });

  testWidgets('returns to the home tab from a placeholder screen', (
    tester,
  ) async {
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
          builder: (context, state) =>
              BlocProvider.value(value: cubit, child: const HomeScreen()),
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
              child: HomeScreen(
                user: testUser,
                profile: testProfile,
                onNavigationItemSelected: (index) => selectedIndex = index,
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
