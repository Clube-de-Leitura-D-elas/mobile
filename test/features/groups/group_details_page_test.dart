import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/repository/group_join_requests_repository.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_cubit.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';
import 'package:mobile/features/groups/domain/entities/group_details_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_cubit.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_page.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/groups/presentation/widgets/group_next_event.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockGroupParticipantsRepository extends Mock
    implements GroupParticipantsRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockGroupJoinRequestsRepository extends Mock
    implements GroupJoinRequestsRepository {}

void main() {
  late MockGroupRepository mockRepository;
  late MockGroupParticipantsRepository mockParticipantsRepository;
  late MockSessionCubit sessionCubit;
  late MockGroupJoinRequestsRepository joinRequestsRepository;

  const group = GroupDetailsEntity(
    name: '45',
    genres: ['Ficção', 'Aventura'],
    participantCount: 34,
    city: 'Porto Alegre',
    stateCode: 'RS',
  );

  setUp(() {
    mockRepository = MockGroupRepository();
    mockParticipantsRepository = MockGroupParticipantsRepository();
    sessionCubit = MockSessionCubit();
    joinRequestsRepository = MockGroupJoinRequestsRepository();
    when(() => joinRequestsRepository.getRequests(any())).thenAnswer(
      (_) async => const Failure(GroupJoinRequestsNotCoordinatorFailure()),
    );
    when(() => sessionCubit.state).thenReturn(const GuestSession());
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
    when(
      () => mockParticipantsRepository.getParticipants('group-1'),
    ).thenAnswer(
      (_) async => const Success([
        GroupParticipantEntity(id: 'p-1', name: 'Ana Beatriz'),
      ]),
    );
    when(
      () => mockRepository.getNextEvent('group-1'),
    ).thenAnswer((_) async => const Success(null));
    serviceLocator.allowReassignment = true;
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
    serviceLocator.registerFactory<GroupRepository>(() => mockRepository);
  });

  tearDown(() {
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
  });

  Widget buildSubject() => MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt', 'BR'),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>.value(value: sessionCubit),
        BlocProvider(
          create: (_) => GroupDetailsCubit(
            groupRepository: serviceLocator<GroupRepository>(),
          )..load('group-1'),
        ),
        BlocProvider(
          create: (_) =>
              NextEventCubit(groupRepository: serviceLocator<GroupRepository>())
                ..load('group-1'),
        ),
        BlocProvider(
          create: (_) => GroupParticipantsCubit(
            participantsRepository: mockParticipantsRepository,
          )..load('group-1'),
        ),
        BlocProvider(
          create: (_) =>
              GroupJoinRequestsCubit(repository: joinRequestsRepository)
                ..load('group-1'),
        ),
      ],
      child: const GroupDetailsPage(groupId: 'group-1'),
    ),
  );

  testWidgets('renders loading state while the group request is pending', (
    tester,
  ) async {
    final response = Completer<Result<GroupDetailsEntity, GroupFailure>>();
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) => response.future);

    await tester.pumpWidget(buildSubject());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(GroupDetailsScreen), findsNothing);

    response.complete(
      const Failure(GroupDetailsFailure(message: 'Falha ao carregar grupo')),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('renders the error state message', (tester) async {
    when(() => mockRepository.getGroupDetails('group-1')).thenAnswer(
      (_) async => const Failure(
        GroupDetailsFailure(message: 'Falha ao carregar grupo'),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Falha ao carregar grupo'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(GroupDetailsScreen), findsNothing);
  });

  testWidgets('retries the group request from the error state', (tester) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Failure(GroupNetworkFailure()));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    verify(() => mockRepository.getGroupDetails('group-1')).called(2);
  });

  testWidgets('hides retry when the group does not exist', (tester) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Failure(GroupNotFoundFailure()));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Grupo não encontrado.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('renders group details in the loaded state', (tester) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(group));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(GroupDetailsScreen), findsOneWidget);
    expect(find.text('Grupo 45'), findsOneWidget);
    expect(find.text('Ficção'), findsOneWidget);
    expect(find.text('Aventura'), findsOneWidget);
    expect(find.text('34 participantes'), findsOneWidget);
    expect(find.text('Porto Alegre, RS'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Ana Beatriz'), findsOneWidget);
    expect(find.text('Histórico de eventos'), findsOneWidget);
  });

  void stubLoadedGroup() {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(group));
  }

  testWidgets('shows the reason and retries the next event', (tester) async {
    stubLoadedGroup();
    var calls = 0;
    when(() => mockRepository.getNextEvent('group-1')).thenAnswer(
      (_) async => calls++ == 0
          ? const Failure(GroupNetworkFailure())
          : const Success(null),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Tentar novamente'));
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('Nenhum próximo evento agendado'), findsOneWidget);
  });

  testWidgets('offers logout when the session expired', (tester) async {
    stubLoadedGroup();
    when(
      () => mockRepository.getNextEvent('group-1'),
    ).thenAnswer((_) async => const Failure(GroupSessionExpiredFailure()));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sair'));
    await tester.tap(find.text('Sair'));

    verify(() => sessionCubit.logOut()).called(1);
  });

  testWidgets('hides retry when the next event is forbidden', (tester) async {
    stubLoadedGroup();
    when(
      () => mockRepository.getNextEvent('group-1'),
    ).thenAnswer((_) async => const Failure(GroupForbiddenFailure()));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(
      find.text('Você não tem permissão para fazer isso.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('uses the network cover image when the group has a URL', (
    tester,
  ) async {
    const groupWithCover = GroupDetailsEntity(
      name: '45',
      genres: ['Ficção'],
      participantCount: 34,
      city: 'Porto Alegre',
      stateCode: 'RS',
      coverImageUrl: 'https://example.com/group-cover.jpg',
    );
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(groupWithCover));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final screen = tester.widget<GroupDetailsScreen>(
      find.byType(GroupDetailsScreen),
    );
    expect(screen.coverImage, isA<NetworkImage>());
    expect(
      (screen.coverImage! as NetworkImage).url,
      'https://example.com/group-cover.jpg',
    );
  });

  testWidgets('passes whatsappUrl to GroupDetailsScreen when group has it', (
    tester,
  ) async {
    const groupWithWhatsapp = GroupDetailsEntity(
      name: '45',
      genres: ['Ficção'],
      participantCount: 34,
      city: 'Porto Alegre',
      stateCode: 'RS',
      whatsappUrl: 'https://chat.whatsapp.com/ABC123xyz',
    );
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(groupWithWhatsapp));

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    final screen = tester.widget<GroupDetailsScreen>(
      find.byType(GroupDetailsScreen),
    );
    expect(screen.whatsappUrl, 'https://chat.whatsapp.com/ABC123xyz');
  });

  testWidgets('Given a next event with a book cover, '
      'When the page loads, '
      'Then GroupNextEvent receives the book title and a network cover', (
    tester,
  ) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(group));
    when(() => mockRepository.getNextEvent('group-1')).thenAnswer(
      (_) async => Success(
        NextEventEntity(
          location: 'Casa da Fernanda',
          date: DateTime.utc(2026, 10, 13, 22),
          hostName: 'Fernanda Vargas',
          bookTitle: 'Ponciá Vicêncio',
          bookCoverUrl: 'https://example.com/book-cover.jpg',
        ),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final data = tester
        .widget<GroupNextEvent>(find.byType(GroupNextEvent))
        .data;
    expect(data?.bookTitle, 'Ponciá Vicêncio');
    expect(data?.bookCover, isA<NetworkImage>());
    expect(
      (data!.bookCover! as NetworkImage).url,
      'https://example.com/book-cover.jpg',
    );
  });

  testWidgets('Given a next event whose book has an empty cover URL, '
      'When the page loads, '
      'Then GroupNextEvent receives no cover', (tester) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(group));
    when(() => mockRepository.getNextEvent('group-1')).thenAnswer(
      (_) async => Success(
        NextEventEntity(
          location: 'Casa da Fernanda',
          date: DateTime.utc(2026, 10, 13, 22),
          hostName: 'Fernanda Vargas',
          bookTitle: 'Ponciá Vicêncio',
          bookCoverUrl: '',
        ),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final data = tester
        .widget<GroupNextEvent>(find.byType(GroupNextEvent))
        .data;
    expect(data?.bookTitle, 'Ponciá Vicêncio');
    expect(data?.bookCover, isNull);
    expect(find.text('Ponciá Vicêncio'), findsOneWidget);
  });

  testWidgets('Given a next event without a book, '
      'When the page loads, '
      'Then GroupNextEvent shows the undefined-book placeholder', (
    tester,
  ) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(group));
    when(() => mockRepository.getNextEvent('group-1')).thenAnswer(
      (_) async => Success(
        NextEventEntity(
          location: 'Casa da Fernanda',
          date: DateTime.utc(2026, 10, 13, 22),
          hostName: 'Fernanda Vargas',
        ),
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final data = tester
        .widget<GroupNextEvent>(find.byType(GroupNextEvent))
        .data;
    expect(data?.bookTitle, isNull);
    expect(data?.bookCover, isNull);
    expect(find.text('Livro ainda não definido'), findsOneWidget);
  });

  testWidgets('Given a next event with an id, '
      'When tapping Exibir mais detalhes and going back, '
      'Then navigates to meeting details and reloads the next event', (
    tester,
  ) async {
    when(
      () => mockRepository.getGroupDetails('group-1'),
    ).thenAnswer((_) async => const Success(group));
    when(() => mockRepository.getNextEvent('group-1')).thenAnswer(
      (_) async => Success(
        NextEventEntity(
          id: 'meeting-1',
          location: 'Casa da Fernanda',
          date: DateTime.utc(2026, 10, 13, 22),
          hostName: 'Fernanda Vargas',
        ),
      ),
    );

    String? pushedMeetingId;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => GroupDetailsCubit(
                  groupRepository: serviceLocator<GroupRepository>(),
                )..load('group-1'),
              ),
              BlocProvider(
                create: (_) => NextEventCubit(
                  groupRepository: serviceLocator<GroupRepository>(),
                )..load('group-1'),
              ),
              BlocProvider(
                create: (_) => GroupParticipantsCubit(
                  participantsRepository: mockParticipantsRepository,
                )..load('group-1'),
              ),
              BlocProvider(
                create: (_) =>
                    GroupJoinRequestsCubit(repository: joinRequestsRepository)
                      ..load('group-1'),
              ),
            ],
            child: const GroupDetailsPage(groupId: 'group-1'),
          ),
        ),
        GoRoute(
          path: GroupRoutePaths.meetingDetails,
          builder: (_, state) {
            pushedMeetingId = state.uri.queryParameters['meeting_id'];
            return const Scaffold(body: Text('Detalhes do encontro'));
          },
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

    expect(find.text('Exibir mais detalhes'), findsOneWidget);
    expect(find.text('Histórico de eventos'), findsOneWidget);

    await tester.ensureVisible(find.text('Exibir mais detalhes'));
    await tester.tap(find.text('Exibir mais detalhes'));
    await tester.pumpAndSettle();

    expect(pushedMeetingId, 'meeting-1');
    expect(find.text('Detalhes do encontro'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('Detalhes do encontro'), findsNothing);
    verify(() => mockRepository.getNextEvent('group-1')).called(2);
  });

  const joinGroupId = '11111111-1111-1111-1111-111111111111';

  GroupJoinRequestEntity request(String id) =>
      GroupJoinRequestEntity(id: id, userId: 'user-$id', name: 'Leitora $id');

  void stubDetails() {
    when(
      () => mockRepository.getGroupDetails(joinGroupId),
    ).thenAnswer((_) async => const Success(group));
    when(
      () => mockRepository.getNextEvent(joinGroupId),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => mockParticipantsRepository.getParticipants(joinGroupId),
    ).thenAnswer((_) async => const Success([]));
  }

  Future<GoRouter> pumpDetails(WidgetTester tester) async {
    stubDetails();
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<SessionCubit>.value(value: sessionCubit),
              BlocProvider(
                create: (_) =>
                    GroupDetailsCubit(groupRepository: mockRepository)
                      ..load(joinGroupId),
              ),
              BlocProvider(
                create: (_) =>
                    NextEventCubit(groupRepository: mockRepository)
                      ..load(joinGroupId),
              ),
              BlocProvider(
                create: (_) => GroupParticipantsCubit(
                  participantsRepository: mockParticipantsRepository,
                )..load(joinGroupId),
              ),
              BlocProvider(
                create: (_) =>
                    GroupJoinRequestsCubit(repository: joinRequestsRepository)
                      ..load(joinGroupId),
              ),
            ],
            child: const GroupDetailsPage(groupId: joinGroupId),
          ),
        ),
        GoRoute(
          path: GroupJoinRequestsRoutePaths.joinRequests,
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

  testWidgets(
    'join requests access: shows the pending count to the coordinator',
    (tester) async {
      when(
        () => joinRequestsRepository.getRequests(joinGroupId),
      ).thenAnswer((_) async => Success([request('a'), request('b')]));

      await pumpDetails(tester);

      expect(find.text('Pedidos de entrada (2)'), findsOneWidget);
    },
  );

  testWidgets(
    'join requests access: shows the access with zero pending requests',
    (tester) async {
      when(
        () => joinRequestsRepository.getRequests(joinGroupId),
      ).thenAnswer((_) async => const Success([]));

      await pumpDetails(tester);

      expect(find.text('Pedidos de entrada (0)'), findsOneWidget);
    },
  );

  testWidgets(
    'join requests access: hides the access from a reader who is not coordinator',
    (tester) async {
      when(() => joinRequestsRepository.getRequests(joinGroupId)).thenAnswer(
        (_) async => const Failure(GroupJoinRequestsNotCoordinatorFailure()),
      );

      await pumpDetails(tester);

      expect(find.textContaining('Pedidos de entrada'), findsNothing);
      expect(find.text('Grupo 45'), findsOneWidget);
    },
  );

  testWidgets(
    'join requests access: a failed check hides the access without breaking the page',
    (tester) async {
      when(() => joinRequestsRepository.getRequests(joinGroupId)).thenAnswer(
        (_) async => const Failure(GroupJoinRequestsNetworkFailure()),
      );

      await pumpDetails(tester);

      expect(find.textContaining('Pedidos de entrada'), findsNothing);
      expect(find.text('Grupo 45'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    },
  );

  testWidgets(
    'join requests access: opens the list and updates the count when coming back',
    (tester) async {
      var calls = 0;
      when(() => joinRequestsRepository.getRequests(joinGroupId)).thenAnswer(
        (_) async => calls++ == 0
            ? Success([request('a'), request('b')])
            : Success([request('b')]),
      );

      final router = await pumpDetails(tester);
      await tester.tap(find.text('Pedidos de entrada (2)'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'pedidos: ${GroupJoinRequestsRoutePaths.joinRequestsFor(joinGroupId)}',
        ),
        findsOneWidget,
      );

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('Pedidos de entrada (1)'), findsOneWidget);
      verify(() => joinRequestsRepository.getRequests(joinGroupId)).called(2);
    },
  );
}
