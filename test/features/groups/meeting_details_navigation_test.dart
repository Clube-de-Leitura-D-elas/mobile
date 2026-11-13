import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/repository/meeting_guest_requests_repository.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

class MockMeetingGuestRequestsRepository extends Mock
    implements MeetingGuestRequestsRepository {}

void main() {
  late MockGroupRepository mockRepository;
  late MockMeetingGuestRequestsRepository guestRequestsRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    guestRequestsRepository = MockMeetingGuestRequestsRepository();
    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<MeetingGuestRequestsCubit>(
      () => MeetingGuestRequestsCubit(repository: guestRequestsRepository),
    );
    serviceLocator.registerFactory<EventHistoryCubit>(
      () => EventHistoryCubit(groupRepository: mockRepository),
    );
    serviceLocator.registerFactory<MeetingDetailsCubit>(
      () => MeetingDetailsCubit(groupRepository: mockRepository),
    );
    serviceLocator.registerFactory<MeetingPhotosCubit>(
      () => MeetingPhotosCubit(
        groupRepository: mockRepository,
        photoPicker: MockPhotoPicker(),
      ),
    );
    when(
      () => mockRepository.getMeetingPhotos(any()),
    ).thenAnswer(
      (_) async => const Success(
        MeetingPhotosEntity(photos: [], canAddPhotos: true),
      ),
    );
  });

  tearDown(() {
    serviceLocator.unregister<EventHistoryCubit>();
    serviceLocator.unregister<MeetingDetailsCubit>();
    serviceLocator.unregister<MeetingPhotosCubit>();
    serviceLocator.unregister<MeetingGuestRequestsCubit>();
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

  testWidgets('builds the meeting details route from meeting_id', (
    tester,
  ) async {
    when(() => mockRepository.getMeetingDetails('meeting-1')).thenAnswer(
      (_) async => const Failure(MeetingDetailsFailure(message: 'Falhou')),
    );

    await pumpRoute(
      tester,
      '${GroupRoutes.meetingDetails}?meeting_id=meeting-1',
    );

    verify(() => mockRepository.getMeetingDetails('meeting-1')).called(1);
    expect(find.text('Falhou'), findsOneWidget);
  });

  testWidgets(
    '"Confira mais detalhes" opens the matching meeting and back returns',
    (tester) async {
      when(() => mockRepository.getEventHistory('group-1')).thenAnswer(
        (_) async => const Success([
          GroupMeeting(
            id: 'meeting-1',
            bookTitle: 'Quarto de Despejo',
            hostName: 'Ana Souza',
            date: '2026-08-22T15:00:00Z',
            location: '',
          ),
          GroupMeeting(
            id: 'meeting-2',
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
            date: '2026-07-22T15:00:00Z',
            location: '',
          ),
        ]),
      );
      when(() => mockRepository.getMeetingDetails('meeting-2')).thenAnswer(
        (_) async => const Success(
          MeetingDetailsEntity(
            id: 'meeting-2',
            number: 12,
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
          ),
        ),
      );

      await pumpRoute(tester, '${GroupRoutes.eventHistory}?group_id=group-1');
      await tester.tap(find.text('Confira mais detalhes').last);
      await tester.pumpAndSettle();

      verify(() => mockRepository.getMeetingDetails('meeting-2')).called(1);
      verify(() => mockRepository.getMeetingPhotos('meeting-2')).called(1);
      expect(find.text('Encontro 12'), findsOneWidget);
      expect(find.text('Fotos do encontro'), findsOneWidget);
      expect(find.text('Livro: Dom Casmurro'), findsOneWidget);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('Histórico de eventos'), findsOneWidget);
      expect(find.text('Encontro 12'), findsNothing);
    },
  );

  for (final route in [GroupRoutes.meetingDetails, GroupRoutes.meetingRecord]) {
    testWidgets('$route checks the guest requests of the same meeting', (
      tester,
    ) async {
      const meetingId = '55555555-5555-5555-5555-555555555555';
      when(() => mockRepository.getMeetingDetails(meetingId)).thenAnswer(
        (_) async => const Success(
          MeetingDetailsEntity(
            id: meetingId,
            number: 3,
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
          ),
        ),
      );
      when(() => guestRequestsRepository.getRequests(meetingId)).thenAnswer(
        (_) async => const Success([
          MeetingGuestRequestEntity(id: 'r-1', userId: 'u-1', name: 'Ana'),
        ]),
      );

      await pumpRoute(tester, '$route?meeting_id=$meetingId');

      verify(() => guestRequestsRepository.getRequests(meetingId)).called(1);
      expect(find.text('Pedidos de participação (1)'), findsOneWidget);
    });
  }
}
