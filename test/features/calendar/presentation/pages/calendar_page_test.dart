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
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../calendar_fixtures.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockCalendarRepository repository;
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

  setUp(() {
    repository = MockCalendarRepository();
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
            create: (_) =>
                CalendarCubit(repository: repository, now: () => now)..load(),
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
}
