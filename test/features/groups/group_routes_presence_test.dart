// test/features/groups/presentation/routes/group_routes_presence_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_presence_page.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;

  setUp(() async {
    repository = MockGroupRepository();

    await serviceLocator.reset();
    serviceLocator.registerFactory<MeetingPresenceCubit>(
      () => MeetingPresenceCubit(repository: repository),
    );

    when(() => repository.getMeetingAttendance(any())).thenAnswer(
      (_) async => const Success<List<MeetingAttendanceEntity>, GroupFailure>([
        MeetingAttendanceEntity(
          id: 'u-1',
          name: 'Ana',
          invitationStatus: MeetingInvitationStatus.confirmed,
          presenceStatus: MeetingPresenceStatus.present,
        ),
      ]),
    );
  });

  tearDown(() async => serviceLocator.reset());

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

  group('GroupRoutes.meetingPresence', () {
    test('o path da rota é o de GroupRoutes.meetingPresence', () {
      final paths = GroupRoutes.routes.whereType<GoRoute>().map(
        (route) => route.path,
      );

      expect(paths, contains(GroupRoutes.meetingPresence));
    });

    testWidgets('abre a MeetingPresencePage e carrega o encontro da query', (
      tester,
    ) async {
      await pumpRoute(
        tester,
        '${GroupRoutes.meetingPresence}?meeting_id=meeting-1',
      );

      expect(find.byType(MeetingPresencePage), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      verify(() => repository.getMeetingAttendance('meeting-1')).called(1);
    });

    testWidgets('sem meeting_id carrega com id vazio', (tester) async {
      await pumpRoute(tester, GroupRoutes.meetingPresence);

      expect(find.byType(MeetingPresencePage), findsOneWidget);
      verify(() => repository.getMeetingAttendance('')).called(1);
    });
  });
}
