import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockGroupParticipantsRepository extends Mock
    implements GroupParticipantsRepository {}

void main() {
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    serviceLocator.allowReassignment = true;
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
    if (serviceLocator.isRegistered<GroupDetailsCubit>()) {
      serviceLocator.unregister<GroupDetailsCubit>();
    }
    if (serviceLocator.isRegistered<EventHistoryCubit>()) {
      serviceLocator.unregister<EventHistoryCubit>();
    }
    serviceLocator.registerFactory<GroupRepository>(() => mockRepository);
    serviceLocator.registerFactory<GroupDetailsCubit>(
      () => GroupDetailsCubit(groupRepository: mockRepository),
    );
    serviceLocator.registerFactory<EventHistoryCubit>(
      () => EventHistoryCubit(groupRepository: mockRepository),
    );
    final mockParticipantsRepository = MockGroupParticipantsRepository();
    when(
      () => mockParticipantsRepository.getParticipants(any()),
    ).thenAnswer((_) async => const Success([]));
    if (serviceLocator.isRegistered<GroupParticipantsCubit>()) {
      serviceLocator.unregister<GroupParticipantsCubit>();
    }
    serviceLocator.registerFactory<GroupParticipantsCubit>(
      () => GroupParticipantsCubit(
        participantsRepository: mockParticipantsRepository,
      ),
    );
  });

  tearDown(() {
    if (serviceLocator.isRegistered<GroupParticipantsCubit>()) {
      serviceLocator.unregister<GroupParticipantsCubit>();
    }
    if (serviceLocator.isRegistered<GroupDetailsCubit>()) {
      serviceLocator.unregister<GroupDetailsCubit>();
    }
    if (serviceLocator.isRegistered<EventHistoryCubit>()) {
      serviceLocator.unregister<EventHistoryCubit>();
    }
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
  });

  Future<void> pumpRoute(WidgetTester tester, String location) async {
    final router = GoRouter(
      initialLocation: location,
      routes: GroupRoutes.routes,
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
  }

  testWidgets('builds group details using the group_id query parameter', (
    tester,
  ) async {
    when(() => mockRepository.getGroupDetails('group-1')).thenAnswer(
      (_) async =>
          const Failure(GroupDetailsFailure(message: 'Not used in this test')),
    );

    await pumpRoute(tester, '/group-details?group_id=group-1');

    verify(() => mockRepository.getGroupDetails('group-1')).called(1);
    expect(find.text('Not used in this test'), findsOneWidget);
  });

  testWidgets('uses an empty group_id when the query parameter is absent', (
    tester,
  ) async {
    when(() => mockRepository.getGroupDetails('')).thenAnswer(
      (_) async =>
          const Failure(GroupDetailsFailure(message: 'Missing group id')),
    );

    await pumpRoute(tester, '/group-details');

    verify(() => mockRepository.getGroupDetails('')).called(1);
    expect(find.text('Missing group id'), findsOneWidget);
  });

  testWidgets('builds the event history route for the requested group', (
    tester,
  ) async {
    when(() => mockRepository.getEventHistory('group-1')).thenAnswer(
      (_) async => const Success([
        GroupMeeting(
          id: 'meeting-1',
          bookTitle: 'Quarto de Despejo',
          hostName: 'Ana Souza',
          date: '2026-08-22T00:00:00Z',
          location: '',
        ),
      ]),
    );

    await pumpRoute(tester, '${GroupRoutes.eventHistory}?group_id=group-1');

    expect(find.text('Histórico de eventos'), findsOneWidget);
    expect(find.text('Quarto de Despejo'), findsOneWidget);
    verify(() => mockRepository.getEventHistory('group-1')).called(1);
  });

  testWidgets(
    'opens event history from group details using the current group ID',
    (tester) async {
      when(() => mockRepository.getGroupDetails('group-1')).thenAnswer(
        (_) async => const Success(
          GroupDetailsEntity(
            name: 'Grupo 1',
            genres: ['Ficção'],
            participantCount: 5,
            city: 'Porto Alegre',
            stateCode: 'RS',
          ),
        ),
      );
      when(() => mockRepository.getEventHistory('group-1')).thenAnswer(
        (_) async => const Success([
          GroupMeeting(
            id: 'meeting-1',
            bookTitle: 'Quarto de Despejo',
            hostName: 'Ana Souza',
            date: '2026-08-22T00:00:00Z',
            location: '',
          ),
        ]),
      );

      await pumpRoute(tester, '/group-details?group_id=group-1');
      final historyAction = find.text('Histórico de eventos');
      await tester.ensureVisible(historyAction);
      await tester.tap(historyAction);
      await tester.pumpAndSettle();

      expect(find.text('Quarto de Despejo'), findsOneWidget);
      verify(() => mockRepository.getEventHistory('group-1')).called(1);
    },
  );
}
