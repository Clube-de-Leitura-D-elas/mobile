import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';
import 'package:mobile/features/calendar/domain/repository/calendar_repository.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mobile/features/calendar/presentation/pages/calendar_page.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_list_skeleton.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_meeting_tile.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_month_grid.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/membership_status_indicator.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/cities/presentation/widgets/city_filter_dropdown.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/cities/domain/entities/city_scope.dart';
import 'package:mocktail/mocktail.dart';

import '../../../cities/cities_fixtures.dart';
import '../../calendar_fixtures.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockCalendarRepository repository;
  late MockDiscoveryCitiesRepository citiesRepository;
  late MockSessionCubit sessionCubit;

  // 12h de 14/08 em São Paulo.
  final now = DateTime.utc(2026, 8, 14, 15);
  const august = CalendarMonth(2026, 8);

  final pastMeeting = calendarMeeting(
    'past',
    day: DateTime(2026, 8, 10),
    hour: 15,
    groupNumber: 27,
    participantCount: 37,
    locationName: 'Café Central',
    hostName: 'Gabriela',
  );
  final memberMeeting = calendarMeeting(
    'member',
    day: DateTime(2026, 8, 17),
    groupNumber: 5,
    locationName: 'Livraria Cultura',
    hostName: 'Gabriela',
  );
  final otherGroupMeeting = calendarMeeting(
    'other',
    day: DateTime(2026, 8, 20),
    groupNumber: 9,
    participantCount: 8,
    membership: CalendarMembershipStatus.none,
    locationName: 'Café Secreto',
    neighborhood: 'Moinhos',
    hostName: 'Ana',
  );

  void stubMonth(
    CalendarMonth month,
    Result<List<CalendarMeetingEntity>, CalendarFailure> result,
  ) {
    when(
      () => repository.getMeetings(
        from: month.firstVisibleDay,
        to: month.lastVisibleDay,
      ),
    ).thenAnswer((_) async => result);
  }

  tearDown(AppToast.dismiss);

  setUp(() {
    repository = MockCalendarRepository();
    citiesRepository = MockDiscoveryCitiesRepository();
    // Sem a lista de cidades, a tela de antes do filtro.
    stubCitiesFailure(citiesRepository);
    sessionCubit = MockSessionCubit();
    when(() => sessionCubit.state).thenReturn(const GuestSession());
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    // Tela alta: a lista fica abaixo da grade e precisa estar construída.
    Size size = const Size(800, 2400),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: QuickAccessRoutes.calendar,
      routes: [
        GoRoute(
          path: QuickAccessRoutes.calendar,
          builder: (_, _) => BlocProvider(
            create: (_) => CalendarCubit(
              repository: repository,
              citiesRepository: citiesRepository,
              now: () => now,
            )..load(),
            child: const CalendarPage(),
          ),
        ),
        for (final path in [
          GroupRoutePaths.groupDetails,
          GroupDiscoveryRoutePaths.publicGroup,
        ])
          GoRoute(
            path: path,
            builder: (_, state) => Text('destino: ${state.uri}'),
          ),
      ],
    );

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
          locale: const Locale('pt', 'BR'),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
  }

  Finder tileOf(String id) => find.byKey(ValueKey(id));

  group('loaded month', () {
    setUp(
      () => stubMonth(
        august,
        Success([pastMeeting, memberMeeting, otherGroupMeeting]),
      ),
    );

    testWidgets('shows the month, the grid marks and the bottom bar', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Agosto 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Agosto de 2026'), findsOneWidget);
      for (final day in [10, 17, 20]) {
        expect(
          find.byKey(ValueKey('calendar-marker-${DateTime(2026, 8, day)}')),
          findsOneWidget,
        );
      }
      expect(
        find.byKey(ValueKey('calendar-marker-${DateTime(2026, 8, 14)}')),
        findsNothing,
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('14 de agosto, sem encontros'),
        ),
        isSemantics(isButton: true, value: 'Hoje'),
      );
      expect(
        tester
            .widget<BottomNavigationBarWidget>(
              find.byType(BottomNavigationBarWidget),
            )
            .currentIndex,
        QuickAccessItem.calendar.index,
      );
    });

    testWidgets('leaves the days of neighbor months out of the semantics', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('26 de julho, sem encontros'), findsNothing);
      expect(find.text('26'), findsNWidgets(2));
    });

    testWidgets('shows the filter chips with the upcoming count', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Próximos eventos (2)'), findsOneWidget);
      expect(find.text('Eventos passados'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Todos')),
        isSemantics(isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Eventos passados')),
        isSemantics(isButton: true, isSelected: false),
      );
    });

    testWidgets('lists the month meetings with date, time, size and place', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.byType(CalendarMeetingTile), findsNWidgets(3));
      expect(find.text('10/08/2026 - Encontro Grupo 27'), findsOneWidget);
      expect(find.text('15:00'), findsOneWidget);
      expect(find.text('37 participantes'), findsOneWidget);
      expect(find.text('Café Central'), findsOneWidget);
      expect(find.text('17/08/2026 - Encontro Grupo 5'), findsOneWidget);
    });

    testWidgets('shows only the neighborhood to a non-member', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      final tile = tileOf('other');
      expect(
        find.descendant(of: tile, matching: find.text('Moinhos')),
        findsOneWidget,
      );
      expect(find.text('Café Secreto'), findsNothing);
      expect(find.text('Ana (Anfitriã)'), findsNothing);
    });

    testWidgets('filters the list by the chips', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eventos passados'));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarMeetingTile), findsOneWidget);
      expect(tileOf('past'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Eventos passados')),
        isSemantics(isSelected: true),
      );

      await tester.tap(find.text('Próximos eventos (2)'));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarMeetingTile), findsNWidgets(2));
      expect(tileOf('past'), findsNothing);
    });

    testWidgets('selecting a day lists its meetings with the host, and the '
        'close button goes back to the month', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('17'));
      await tester.pumpAndSettle();

      expect(find.text('Segunda-feira, 17 de agosto'), findsOneWidget);
      expect(find.text('Todos'), findsNothing);
      expect(find.byType(CalendarMeetingTile), findsOneWidget);
      expect(find.text('Encontro Grupo 5'), findsOneWidget);
      expect(find.text('Gabriela (Anfitriã)'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('17 de agosto, 1 encontro')),
        isSemantics(isButton: true, isSelected: true),
      );

      await tester.tap(find.byTooltip('Limpar dia selecionado'));
      await tester.pumpAndSettle();

      expect(find.text('Segunda-feira, 17 de agosto'), findsNothing);
      expect(find.byType(CalendarMeetingTile), findsNWidgets(3));
    });

    testWidgets('shows the empty message for a day without meetings', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('18'));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum encontro neste dia.'), findsOneWidget);
    });

    testWidgets('opens the group details of a member meeting', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(tileOf('member'));
      await tester.pumpAndSettle();

      expect(
        find.text('destino: /group-details?group_id=group-member'),
        findsOneWidget,
      );
    });

    testWidgets('opens the public group page of a non-member meeting', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      final tile = tileOf('other');
      expect(
        find.descendant(of: tile, matching: find.byIcon(Icons.chevron_right)),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(tile),
        isSemantics(isButton: true, hasTapAction: true),
      );

      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(
        find.text('destino: /group-public?group_id=group-other'),
        findsOneWidget,
      );
    });

    testWidgets('loads the next month with its grid range', (tester) async {
      const september = CalendarMonth(2026, 9);
      stubMonth(september, const Success([]));
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();

      expect(find.text('Setembro 2026'), findsOneWidget);
      expect(find.text('Nenhum encontro neste mês.'), findsOneWidget);
      verify(
        () => repository.getMeetings(
          from: DateTime(2026, 8, 30),
          to: DateTime(2026, 10, 10),
        ),
      ).called(1);
    });
  });

  group('São Paulo day and time', () {
    // 23h30 de 14/08 em São Paulo é 02h30 de 15/08 em UTC.
    final lateNight = calendarMeeting(
      'late',
      day: DateTime(2026, 8, 14),
      hour: 23,
      minute: 30,
    );

    testWidgets('marks, selects and shows the time by the São Paulo day', (
      tester,
    ) async {
      expect(lateNight.date, DateTime.utc(2026, 8, 15, 2, 30));
      stubMonth(august, Success([lateNight]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(ValueKey('calendar-marker-${DateTime(2026, 8, 14)}')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey('calendar-marker-${DateTime(2026, 8, 15)}')),
        findsNothing,
      );
      expect(find.text('14/08/2026 - Encontro Grupo 5'), findsOneWidget);
      expect(find.text('23:30'), findsOneWidget);

      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();

      expect(find.text('Sexta-feira, 14 de agosto'), findsOneWidget);
      expect(tileOf('late'), findsOneWidget);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum encontro neste dia.'), findsOneWidget);
    });
  });

  testWidgets('tags a draft meeting', (tester) async {
    stubMonth(
      august,
      Success([
        calendarMeeting(
          'draft',
          day: DateTime(2026, 8, 20),
          status: CalendarMeetingStatus.created,
        ),
        memberMeeting,
      ]),
    );

    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: tileOf('draft'), matching: find.text('Rascunho')),
      findsOneWidget,
    );
    expect(find.text('Rascunho'), findsOneWidget);
  });

  testWidgets('lays out a narrow screen with doubled font without overflow', (
    tester,
  ) async {
    stubMonth(august, Success([pastMeeting, memberMeeting, otherGroupMeeting]));

    await pumpPage(tester, size: const Size(360, 3000), textScale: 2);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(CalendarDayCell).first).width,
      greaterThanOrEqualTo(48),
    );
    // O número cabe inteiro, numa linha, dentro do círculo do dia.
    final number = find.text('17');
    final paragraph = tester.renderObject<RenderParagraph>(number);
    expect(
      paragraph.getMaxIntrinsicWidth(double.infinity),
      lessThanOrEqualTo(paragraph.size.width + 0.01),
    );
    expect(
      paragraph.getMinIntrinsicHeight(paragraph.size.width),
      lessThanOrEqualTo(paragraph.size.height + 0.01),
    );
    final circle = find
        .ancestor(of: number, matching: find.byType(Container))
        .first;
    final circleRect = tester.getRect(circle).inflate(0.01);
    final numberRect = tester.getRect(number);
    expect(circleRect.contains(numberRect.topLeft), isTrue);
    expect(circleRect.contains(numberRect.bottomRight), isTrue);

    await tester.tap(find.text('17'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CalendarMeetingTile), findsOneWidget);
  });

  group('states', () {
    testWidgets('shows the skeleton while loading', (tester) async {
      final pending =
          Completer<Result<List<CalendarMeetingEntity>, CalendarFailure>>();
      when(
        () => repository.getMeetings(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => pending.future);

      await pumpPage(tester);
      await tester.pump();

      expect(find.byType(CalendarListSkeleton), findsOneWidget);
      expect(find.bySemanticsLabel('Carregando encontros'), findsOneWidget);
      expect(find.text('Todos'), findsNothing);
    });

    testWidgets('shows the empty month message', (tester) async {
      stubMonth(august, const Success([]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Nenhum encontro neste mês.'), findsOneWidget);
      expect(find.text('Próximos eventos (0)'), findsOneWidget);
    });

    testWidgets('shows the error and reloads on retry', (tester) async {
      stubMonth(august, const Failure(CalendarLoadFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível carregar o calendário.'),
        findsOneWidget,
      );

      stubMonth(august, Success([memberMeeting]));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarMeetingTile), findsOneWidget);
    });

    testWidgets('offers logout when the session expired', (tester) async {
      stubMonth(august, const Failure(CalendarSessionExpiredFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Sua sessão expirou. Saia do app e entre de novo na sua conta.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Sair'));

      verify(() => sessionCubit.logOut()).called(1);
    });

    testWidgets('does not offer retry to an inactive account', (tester) async {
      stubMonth(august, const Failure(CalendarForbiddenFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Você não tem permissão para fazer isso.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsNothing);
    });
  });

  group('guest participation', () {
    CalendarMeetingEntity guestMeeting({
      CalendarGuestStatus? guestStatus,
      DateTime? day,
      CalendarMeetingStatus status = CalendarMeetingStatus.scheduled,
      // Como o backend: sem pedido ou recusado (fora das 24 h) pode pedir.
      bool? canRequest,
    }) => calendarMeeting(
      'guest',
      day: day ?? DateTime(2026, 8, 20),
      groupNumber: 9,
      participantCount: 8,
      status: status,
      membership: CalendarMembershipStatus.none,
      locationName: 'Café Secreto',
      neighborhood: 'Moinhos',
      hostName: 'Ana',
      guestStatus: guestStatus,
      canRequestParticipation:
          canRequest ??
          (guestStatus == null || guestStatus == CalendarGuestStatus.rejected),
    );

    Finder inTile(Finder matching) =>
        find.descendant(of: tileOf('guest'), matching: matching);

    Future<void> pumpWith(
      WidgetTester tester,
      List<CalendarMeetingEntity> meetings,
    ) async {
      stubMonth(august, Success(meetings));
      await pumpPage(tester);
      await tester.pumpAndSettle();
    }

    Future<void> confirmRequest(WidgetTester tester) async {
      await tester.tap(inTile(find.text('Solicitar participação')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar'));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('offers the request on a scheduled future meeting without '
        'request, as its own button in the semantics tree', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWith(tester, [guestMeeting(), memberMeeting]);

      expect(inTile(find.text('Solicitar participação')), findsOneWidget);
      expect(inTile(find.text('Aguardando aprovação')), findsNothing);
      expect(
        tester.getSemantics(
          inTile(find.bySemanticsLabel(RegExp('^Solicitar participação'))),
        ),
        isSemantics(isButton: true, hasTapAction: true, isEnabled: true),
      );
      // O card segue um botão rotulado, com o pedido como nó filho.
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(RegExp(r'^20/08/2026 - Encontro Grupo 9, ')),
        ),
        isSemantics(
          isButton: true,
          hasTapAction: true,
          children: [isSemantics(isButton: true, hasTapAction: true)],
        ),
      );
      expect(
        tester
            .getSize(
              inTile(find.bySemanticsLabel(RegExp('^Solicitar participação'))),
            )
            .height,
        greaterThanOrEqualTo(48),
      );
      // Membro não vê nada do pedido.
      expect(
        find.descendant(
          of: tileOf('member'),
          matching: find.text('Solicitar participação'),
        ),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('a pending request shows waiting, with no action', (
      tester,
    ) async {
      await pumpWith(tester, [
        guestMeeting(guestStatus: CalendarGuestStatus.requested),
      ]);
      expect(inTile(find.text('Aguardando aprovação')), findsOneWidget);
      expect(inTile(find.byType(AppButton)), findsNothing);
    });

    testWidgets('an accepted guest sees the place and host like a member', (
      tester,
    ) async {
      await pumpWith(tester, [
        guestMeeting(guestStatus: CalendarGuestStatus.accepted),
      ]);

      expect(inTile(find.text('Participação confirmada')), findsOneWidget);
      expect(inTile(find.text('Café Secreto')), findsOneWidget);
      expect(inTile(find.text('Ana (Anfitriã)')), findsOneWidget);
      expect(inTile(find.byType(AppButton)), findsNothing);
    });

    testWidgets('confirmed participation stays on a meeting in progress or '
        'already over', (tester) async {
      await pumpWith(tester, [
        calendarMeeting(
          'in-progress',
          day: DateTime(2026, 8, 21),
          status: CalendarMeetingStatus.inProgress,
          membership: CalendarMembershipStatus.none,
          guestStatus: CalendarGuestStatus.accepted,
        ),
        calendarMeeting(
          'over',
          day: DateTime(2026, 8, 11),
          status: CalendarMeetingStatus.concluded,
          membership: CalendarMembershipStatus.none,
          guestStatus: CalendarGuestStatus.accepted,
        ),
      ]);

      for (final id in ['in-progress', 'over']) {
        expect(
          find.descendant(
            of: tileOf(id),
            matching: find.text('Participação confirmada'),
          ),
          findsOneWidget,
          reason: id,
        );
      }
    });

    testWidgets('a guest rejected less than 24 hours ago sees the refusal '
        'without asking again', (tester) async {
      await pumpWith(tester, [
        guestMeeting(
          guestStatus: CalendarGuestStatus.rejected,
          canRequest: false,
        ),
      ]);

      expect(inTile(find.text('Pedido recusado')), findsOneWidget);
      expect(inTile(find.byType(AppButton)), findsNothing);
    });

    testWidgets('a rejected guest can ask again', (tester) async {
      when(
        () => repository.requestParticipation('guest'),
      ).thenAnswer((_) async => const Success(null));
      await pumpWith(tester, [
        guestMeeting(guestStatus: CalendarGuestStatus.rejected),
      ]);

      expect(inTile(find.text('Pedido recusado')), findsOneWidget);
      await tester.tap(inTile(find.text('Pedir novamente')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar'));
      await tester.pump();
      await tester.pump();

      verify(() => repository.requestParticipation('guest')).called(1);
      expect(inTile(find.text('Aguardando aprovação')), findsOneWidget);
    });

    testWidgets('hides the request and stale statuses when the backend '
        'blocks it or the meeting is no longer open', (tester) async {
      await pumpWith(tester, [
        // Ex-membro (vínculo INACTIVE chega como null) ou convidada antiga.
        calendarMeeting(
          'blocked',
          day: DateTime(2026, 8, 23),
          membership: CalendarMembershipStatus.none,
        ),
        guestMeeting(day: DateTime(2026, 8, 10)),
        calendarMeeting(
          'past-requested',
          day: DateTime(2026, 8, 12),
          membership: CalendarMembershipStatus.none,
          guestStatus: CalendarGuestStatus.requested,
        ),
        calendarMeeting(
          'in-progress',
          day: DateTime(2026, 8, 21),
          status: CalendarMeetingStatus.inProgress,
          membership: CalendarMembershipStatus.none,
          guestStatus: CalendarGuestStatus.rejected,
        ),
        calendarMeeting(
          'unknown',
          day: DateTime(2026, 8, 22),
          membership: CalendarMembershipStatus.none,
          guestStatus: CalendarGuestStatus.unknown,
        ),
      ]);

      expect(find.byType(CalendarMeetingTile), findsNWidgets(5));
      expect(find.byType(AppButton), findsNothing);
      expect(find.byType(MembershipStatusIndicator), findsNothing);
    });

    testWidgets('asks for confirmation; cancelling sends nothing', (
      tester,
    ) async {
      await pumpWith(tester, [guestMeeting()]);

      await tester.tap(inTile(find.text('Solicitar participação')));
      await tester.pumpAndSettle();

      expect(find.text('Solicitar participação?'), findsOneWidget);
      expect(
        find.text(
          'A anfitriã ou a coordenação do Grupo 9 vai analisar o seu pedido.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => repository.requestParticipation(any()));
      expect(inTile(find.text('Solicitar participação')), findsOneWidget);
    });

    testWidgets('on success turns the card into waiting and shows the toast', (
      tester,
    ) async {
      final answer = Completer<Result<void, CalendarFailure>>();
      when(
        () => repository.requestParticipation('guest'),
      ).thenAnswer((_) => answer.future);
      await pumpWith(tester, [guestMeeting()]);

      await confirmRequest(tester);
      // Ocupado: um segundo toque não envia outro pedido.
      final button = tester.widget<AppButton>(inTile(find.byType(AppButton)));
      expect(button.isLoading, isTrue);
      await tester.tap(inTile(find.byType(AppButton)));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Solicitar participação?'), findsNothing);
      // Nem abre o grupo por baixo do botão.
      expect(find.textContaining('destino:'), findsNothing);

      answer.complete(const Success(null));
      await tester.pump();
      await tester.pump();

      verify(() => repository.requestParticipation('guest')).called(1);
      expect(inTile(find.text('Aguardando aprovação')), findsOneWidget);
      expect(
        find.text('Pedido enviado! Agora é só aguardar a aprovação.'),
        findsOneWidget,
      );
    });

    final messages = <CalendarFailure, String>{
      const CalendarNetworkFailure(): 'Sem conexão',
      const CalendarSessionExpiredFailure(): 'Sua sessão expirou',
      const CalendarForbiddenFailure():
          'Você não tem permissão para fazer isso.',
      const CalendarGuestRecentlyRejectedFailure():
          'Você poderá pedir de novo 24 horas depois da recusa.',
      const CalendarMeetingNoReviewerFailure():
          'Este encontro ainda não tem quem analise pedidos.',
      const CalendarGuestRequestFailure():
          'Não foi possível enviar o pedido. Tente novamente.',
      const CalendarMeetingNotOpenFailure():
          'Este encontro não está mais aberto a pedidos.',
      const CalendarGuestAlreadyRequestedFailure():
          'Você já pediu para participar deste encontro.',
      const CalendarGuestAlreadyMemberFailure():
          'Você já tem um vínculo ou pedido com este grupo.',
      const CalendarMeetingUnavailableFailure():
          'Este encontro não está disponível para você.',
      const CalendarMeetingNotFoundFailure(): 'Este encontro não existe mais.',
    };
    for (final MapEntry(key: failure, value: message) in messages.entries) {
      testWidgets('shows the ${failure.runtimeType} message once', (
        tester,
      ) async {
        when(
          () => repository.requestParticipation('guest'),
        ).thenAnswer((_) async => Failure(failure));
        await pumpWith(tester, [guestMeeting()]);

        await confirmRequest(tester);
        await tester.pump();

        expect(find.textContaining(message), findsOneWidget);
        expect(inTile(find.text('Solicitar participação')), findsOneWidget);
      });
    }

    testWidgets('already requested reloads the month and shows the real '
        'status', (tester) async {
      when(() => repository.requestParticipation('guest')).thenAnswer(
        (_) async => const Failure(CalendarGuestAlreadyRequestedFailure()),
      );
      await pumpWith(tester, [guestMeeting()]);
      final reload =
          Completer<Result<List<CalendarMeetingEntity>, CalendarFailure>>();
      when(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
        ),
      ).thenAnswer((_) => reload.future);

      await confirmRequest(tester);
      await tester.pump();

      // Durante a recarga o card continua na tela, ocupado.
      expect(find.byType(CalendarListSkeleton), findsNothing);
      expect(
        tester.widget<AppButton>(inTile(find.byType(AppButton))).isLoading,
        isTrue,
      );

      reload.complete(
        Success([guestMeeting(guestStatus: CalendarGuestStatus.requested)]),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(CalendarListSkeleton), findsNothing);
      expect(inTile(find.text('Aguardando aprovação')), findsOneWidget);
      verify(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
        ),
      ).called(2);
    });

    testWidgets('going to the open calendar tab with a refresh request '
        'reloads the month in place', (tester) async {
      await pumpWith(tester, [
        guestMeeting(guestStatus: CalendarGuestStatus.requested),
      ]);
      final router = GoRouter.of(tester.element(find.byType(CalendarPage)));
      stubMonth(
        august,
        Success([guestMeeting(guestStatus: CalendarGuestStatus.accepted)]),
      );

      // Sem pedido (ex.: toque na aba): nada muda.
      router.go(QuickAccessRoutes.calendar);
      await tester.pumpAndSettle();
      expect(inTile(find.text('Aguardando aprovação')), findsOneWidget);

      router.go(QuickAccessRoutes.calendar, extra: RefreshTabRequest());
      await tester.pump();
      expect(find.byType(CalendarListSkeleton), findsNothing);
      await tester.pumpAndSettle();

      expect(inTile(find.text('Participação confirmada')), findsOneWidget);
      verify(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
        ),
      ).called(2);
    });

    testWidgets('tapping the rest of the card still opens the public group', (
      tester,
    ) async {
      await pumpWith(tester, [guestMeeting()]);

      await tester.tap(inTile(find.text('Moinhos')));
      await tester.pumpAndSettle();

      expect(
        find.text('destino: /group-public?group_id=group-guest'),
        findsOneWidget,
      );
      verifyNever(() => repository.requestParticipation(any()));
    });
  });

  group('city filter', () {
    final saoPauloMeeting = calendarMeeting(
      'sp',
      day: DateTime(2026, 8, 21),
      groupNumber: 3,
      membership: CalendarMembershipStatus.none,
      cityState: 'São Paulo, SP',
      neighborhood: 'Pinheiros',
      canRequestParticipation: true,
    );

    Finder cityDropdown() => find.byType(CityFilterDropdown);

    testWidgets('without the city list there is no filter', (tester) async {
      stubMonth(august, Success([memberMeeting]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(cityDropdown(), findsNothing);
      expect(find.text('Livraria Cultura'), findsOneWidget);
    });

    testWidgets('opens on the reader city, without the city on the cards', (
      tester,
    ) async {
      stubCities(citiesRepository);
      stubMonth(august, Success([memberMeeting]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(cityDropdown(), findsOneWidget);
      expect(
        find.descendant(
          of: cityDropdown(),
          matching: find.text('Porto Alegre, RS'),
        ),
        findsOneWidget,
      );
      expect(find.text('Livraria Cultura'), findsOneWidget);
      expect(find.textContaining('Livraria Cultura,'), findsNothing);
    });

    testWidgets('"Todas as cidades" reloads the month and shows the city of '
        'each group, keeping the participation request', (tester) async {
      stubCities(citiesRepository);
      stubMonth(august, Success([memberMeeting]));
      when(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
          city: CityScope.all,
        ),
      ).thenAnswer((_) async => Success([memberMeeting, saoPauloMeeting]));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await tester.tap(cityDropdown());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Todas as cidades').last);
      await tester.pumpAndSettle();

      verify(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
          city: CityScope.all,
        ),
      ).called(1);
      expect(
        find.descendant(
          of: cityDropdown(),
          matching: find.text('Todas as cidades'),
        ),
        findsOneWidget,
      );
      expect(find.text('Livraria Cultura, Porto Alegre, RS'), findsOneWidget);
      expect(find.text('Pinheiros, São Paulo, SP'), findsOneWidget);
      expect(
        find.descendant(
          of: tileOf('sp'),
          matching: find.text('Solicitar participação'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('another city reloads the month with its id', (tester) async {
      stubCities(citiesRepository);
      stubMonth(august, Success([memberMeeting]));
      when(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
          city: CityScope.only(saoPaulo.id),
        ),
      ).thenAnswer((_) async => Success([saoPauloMeeting]));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await tester.tap(cityDropdown());
      await tester.pumpAndSettle();
      await tester.tap(find.text('São Paulo, SP').last);
      await tester.pumpAndSettle();

      expect(tileOf('sp'), findsOneWidget);
      expect(tileOf('member'), findsNothing);
      // Uma cidade só: o card mostra o bairro, sem repetir a cidade.
      expect(find.text('Pinheiros'), findsOneWidget);
    });
  });
}
