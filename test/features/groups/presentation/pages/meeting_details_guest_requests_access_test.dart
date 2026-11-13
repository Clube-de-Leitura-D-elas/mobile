import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photos_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_page.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';
import 'package:mobile/features/meeting_guest_requests/domain/repository/meeting_guest_requests_repository.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/routes/meeting_guest_requests_route_paths.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockMeetingGuestRequestsRepository extends Mock
    implements MeetingGuestRequestsRepository {}

class MockPhotoPicker extends Mock implements PhotoPicker {}

const _meetingId = '44444444-4444-4444-4444-444444444444';

final _meeting = MeetingDetailsEntity(
  id: _meetingId,
  number: 12,
  bookTitle: 'Dom Casmurro',
  hostName: 'Beatriz Souza',
  canEdit: true,
  status: 'SCHEDULED',
  date: DateTime.now().add(const Duration(days: 30)),
);

MeetingGuestRequestEntity _request(String id) =>
    MeetingGuestRequestEntity(id: id, userId: 'user-$id', name: 'Leitora $id');

void main() {
  late MockGroupRepository groupRepository;
  late MockMeetingGuestRequestsRepository guestRequestsRepository;

  setUp(() {
    groupRepository = MockGroupRepository();
    guestRequestsRepository = MockMeetingGuestRequestsRepository();
    when(() => groupRepository.getMeetingPhotos(any())).thenAnswer(
      (_) async =>
          const Success(MeetingPhotosEntity(photos: [], canAddPhotos: false)),
    );
    when(
      () => groupRepository.getMeetingDetails(_meetingId),
    ).thenAnswer((_) async => Success(_meeting));
  });

  void stubMeeting(MeetingDetailsEntity meeting) {
    when(
      () => groupRepository.getMeetingDetails(_meetingId),
    ).thenAnswer((_) async => Success(meeting));
  }

  Future<GoRouter> pumpDetails(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    MeetingDetailsCubit(groupRepository: groupRepository)
                      ..load(_meetingId),
              ),
              BlocProvider(
                create: (_) => MeetingPhotosCubit(
                  groupRepository: groupRepository,
                  photoPicker: MockPhotoPicker(),
                )..load(_meetingId),
              ),
              BlocProvider(
                create: (_) => MeetingGuestRequestsCubit(
                  repository: guestRequestsRepository,
                ),
              ),
            ],
            child: const MeetingDetailsPage(),
          ),
        ),
        GoRoute(
          path: GroupRoutePaths.meetingEdit,
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(true),
              child: const Text('close edit'),
            ),
          ),
        ),
        GoRoute(
          path: MeetingGuestRequestsRoutePaths.guestRequests,
          builder: (_, state) => Scaffold(body: Text('pedidos: ${state.uri}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('shows the pending count to whoever decides the requests', (
    tester,
  ) async {
    when(
      () => guestRequestsRepository.getRequests(_meetingId),
    ).thenAnswer((_) async => Success([_request('a'), _request('b')]));

    await pumpDetails(tester);

    expect(find.text('Pedidos de participação (2)'), findsOneWidget);
  });

  testWidgets('shows the access with zero pending requests', (tester) async {
    when(
      () => guestRequestsRepository.getRequests(_meetingId),
    ).thenAnswer((_) async => const Success([]));

    await pumpDetails(tester);

    expect(find.text('Pedidos de participação (0)'), findsOneWidget);
  });

  testWidgets(
    'does not ask for the requests when the meeting cannot be edited',
    (tester) async {
      stubMeeting(
        MeetingDetailsEntity(
          id: _meetingId,
          number: 12,
          bookTitle: 'Dom Casmurro',
          hostName: 'Beatriz Souza',
          status: 'SCHEDULED',
          date: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      await pumpDetails(tester);

      verifyNever(() => guestRequestsRepository.getRequests(any()));
      expect(find.textContaining('Pedidos de participação'), findsNothing);
      expect(find.text('Encontro 12'), findsWidgets);
    },
  );

  testWidgets('hides the access when the meeting date has passed', (
    tester,
  ) async {
    stubMeeting(
      MeetingDetailsEntity(
        id: _meetingId,
        number: 12,
        bookTitle: 'Dom Casmurro',
        hostName: 'Beatriz Souza',
        canEdit: true,
        status: 'SCHEDULED',
        date: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    );
    when(
      () => guestRequestsRepository.getRequests(_meetingId),
    ).thenAnswer((_) async => Success([_request('a')]));

    await pumpDetails(tester);

    expect(find.textContaining('Pedidos de participação'), findsNothing);
  });

  testWidgets('hides the access when the meeting is no longer scheduled', (
    tester,
  ) async {
    stubMeeting(
      MeetingDetailsEntity(
        id: _meetingId,
        number: 12,
        bookTitle: 'Dom Casmurro',
        hostName: 'Beatriz Souza',
        canEdit: true,
        status: 'CREATED',
        date: DateTime.now().add(const Duration(days: 30)),
      ),
    );
    when(
      () => guestRequestsRepository.getRequests(_meetingId),
    ).thenAnswer((_) async => Success([_request('a')]));

    await pumpDetails(tester);

    expect(find.textContaining('Pedidos de participação'), findsNothing);
  });

  testWidgets('hides the access from a reader who cannot decide (403)', (
    tester,
  ) async {
    when(() => guestRequestsRepository.getRequests(_meetingId)).thenAnswer(
      (_) async => const Failure(MeetingGuestRequestsNotReviewerFailure()),
    );

    await pumpDetails(tester);

    expect(find.textContaining('Pedidos de participação'), findsNothing);
    expect(find.text('Encontro 12'), findsWidgets);
  });

  testWidgets('a failed check hides the access without breaking the page', (
    tester,
  ) async {
    when(() => guestRequestsRepository.getRequests(_meetingId)).thenAnswer(
      (_) async => const Failure(MeetingGuestRequestsNetworkFailure()),
    );

    await pumpDetails(tester);

    expect(find.textContaining('Pedidos de participação'), findsNothing);
    expect(find.text('Encontro 12'), findsWidgets);
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('opens the list and updates the count when coming back', (
    tester,
  ) async {
    var calls = 0;
    when(() => guestRequestsRepository.getRequests(_meetingId)).thenAnswer(
      (_) async => calls++ == 0
          ? Success([_request('a'), _request('b')])
          : Success([_request('b')]),
    );

    final router = await pumpDetails(tester);
    await tester.ensureVisible(find.text('Pedidos de participação (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pedidos de participação (2)'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'pedidos: ${MeetingGuestRequestsRoutePaths.guestRequestsFor(_meetingId)}',
      ),
      findsOneWidget,
    );

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Pedidos de participação (1)'), findsOneWidget);
    verify(() => guestRequestsRepository.getRequests(_meetingId)).called(2);
  });

  testWidgets('a double tap opens the list only once', (tester) async {
    when(
      () => guestRequestsRepository.getRequests(_meetingId),
    ).thenAnswer((_) async => Success([_request('a')]));

    final router = await pumpDetails(tester);
    await tester.ensureVisible(find.text('Pedidos de participação (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pedidos de participação (1)'));
    await tester.tap(
      find.text('Pedidos de participação (1)'),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    router.pop();
    await tester.pumpAndSettle();

    expect(find.textContaining('pedidos:'), findsNothing);
    expect(find.text('Encontro 12'), findsWidgets);
    verify(() => guestRequestsRepository.getRequests(_meetingId)).called(2);
  });

  testWidgets('checks the requests only once the meeting loads after a retry', (
    tester,
  ) async {
    var detailsCalls = 0;
    when(() => groupRepository.getMeetingDetails(_meetingId)).thenAnswer(
      (_) async => detailsCalls++ == 0
          ? const Failure(GroupNetworkFailure())
          : Success(_meeting),
    );
    when(
      () => guestRequestsRepository.getRequests(_meetingId),
    ).thenAnswer((_) async => Success([_request('a')]));

    await pumpDetails(tester);
    expect(find.text('Tentar novamente'), findsOneWidget);
    verifyNever(() => guestRequestsRepository.getRequests(any()));

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Pedidos de participação (1)'), findsOneWidget);
    verify(() => guestRequestsRepository.getRequests(_meetingId)).called(1);
  });

  testWidgets('saving an edit reloads the pending count', (tester) async {
    var calls = 0;
    when(() => guestRequestsRepository.getRequests(_meetingId)).thenAnswer(
      (_) async => calls++ == 0
          ? Success([_request('a'), _request('b')])
          : Success([_request('b')]),
    );

    await pumpDetails(tester);
    expect(find.text('Pedidos de participação (2)'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar encontro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('close edit'));
    await tester.pumpAndSettle();

    expect(find.text('Pedidos de participação (1)'), findsOneWidget);
    verify(() => guestRequestsRepository.getRequests(_meetingId)).called(2);
  });
}
