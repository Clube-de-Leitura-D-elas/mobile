import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_execution_page.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_page.dart';
import 'package:mobile/features/raffles/presentation/routes/raffle_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockRaffleRepository extends Mock implements RaffleRepository {}

void main() {
  late MockRaffleRepository mockRepository;

  setUp(() {
    mockRepository = MockRaffleRepository();
    serviceLocator.allowReassignment = true;
    when(
      () => mockRepository.getEligibleParticipants(any()),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => mockRepository.getRaffleResult(any()),
    ).thenAnswer((_) async => const Success(null));

    serviceLocator.registerFactory<RaffleRepository>(() => mockRepository);
    serviceLocator.registerFactory<RafflePreparationCubit>(
      () => RafflePreparationCubit(repository: mockRepository),
    );
    serviceLocator.registerFactory<RaffleExecutionCubit>(
      () => RaffleExecutionCubit(repository: mockRepository),
    );
  });

  tearDown(() {
    if (serviceLocator.isRegistered<RaffleExecutionCubit>()) {
      serviceLocator.unregister<RaffleExecutionCubit>();
    }
    if (serviceLocator.isRegistered<RafflePreparationCubit>()) {
      serviceLocator.unregister<RafflePreparationCubit>();
    }
    if (serviceLocator.isRegistered<RaffleRepository>()) {
      serviceLocator.unregister<RaffleRepository>();
    }
  });

  testWidgets('RaffleRoutes navega para RafflePreparationPage com extra', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        ...RaffleRoutes.routes,
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    router.go(RaffleRoutes.preparation, extra: 'meeting-456');
    await tester.pumpAndSettle();

    final page = tester.widget<RafflePreparationPage>(
      find.byType(RafflePreparationPage),
    );
    expect(page.meetingId, 'meeting-456');
  });

  testWidgets(
    'RaffleRoutes navega para RafflePreparationPage com query parameter',
    (tester) async {
      final router = GoRouter(
        initialLocation: '${RaffleRoutes.preparation}?meeting_id=meeting-789',
        routes: RaffleRoutes.routes,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      final page = tester.widget<RafflePreparationPage>(
        find.byType(RafflePreparationPage),
      );
      expect(page.meetingId, 'meeting-789');
    },
  );

  testWidgets('RaffleRoutes usa query parameters na execução', (tester) async {
    final router = GoRouter(
      initialLocation:
          '${RaffleRoutes.draw}?meeting_id=meeting-query&meeting_title=Setembro',
      routes: RaffleRoutes.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    final page = tester.widget<RaffleExecutionPage>(
      find.byType(RaffleExecutionPage),
    );
    expect(page.meetingId, 'meeting-query');
    expect(page.meetingTitle, 'Setembro');
  });

  testWidgets('RaffleRoutes preserva meetingTitle na preparação', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        ...RaffleRoutes.routes,
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    router.go(
      RaffleRoutes.preparation,
      extra: {'meeting_id': 'meeting-123', 'meeting_title': 'Julho'},
    );
    await tester.pumpAndSettle();

    final page = tester.widget<RafflePreparationPage>(
      find.byType(RafflePreparationPage),
    );
    expect(page.meetingId, 'meeting-123');
    expect(page.meetingTitle, 'Julho');
  });

  testWidgets('RaffleRoutes navega para RaffleExecutionPage com extra Map', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
        ),
        ...RaffleRoutes.routes,
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    router.go(
      RaffleRoutes.draw,
      extra: {'meeting_id': 'meeting-999', 'meeting_title': 'Agosto'},
    );
    await tester.pumpAndSettle();

    final page = tester.widget<RaffleExecutionPage>(
      find.byType(RaffleExecutionPage),
    );
    expect(page.meetingId, 'meeting-999');
    expect(page.meetingTitle, 'Agosto');
  });
}
