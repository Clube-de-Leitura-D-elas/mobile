import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_membership_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_month.dart';
import 'package:mobile/features/calendar/domain/repository/calendar_repository.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../calendar_fixtures.dart';

class MockCalendarRepository extends Mock implements CalendarRepository {}

void main() {
  late MockCalendarRepository repository;

  // 12h de 14/08 em São Paulo.
  final now = DateTime.utc(2026, 8, 14, 15);
  final today = DateTime(2026, 8, 14);
  const august = CalendarMonth(2026, 8);
  const september = CalendarMonth(2026, 9);

  final past = calendarMeeting('past', day: DateTime(2026, 8, 10));
  final upcoming = calendarMeeting('upcoming', day: DateTime(2026, 8, 17));
  // Dia da grade de agosto que pertence a julho.
  final july = calendarMeeting('july', day: DateTime(2026, 7, 28));

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

  CalendarCubit buildCubit({DateTime? at}) =>
      CalendarCubit(repository: repository, now: () => at ?? now);

  final loadedAugust = CalendarState(
    month: august,
    today: today,
    status: CalendarStatus.loaded,
    meetings: [july, past, upcoming],
    upcoming: [upcoming],
    past: [past],
  );

  setUp(() {
    repository = MockCalendarRepository();
  });

  test('starts on the current month, loading', () {
    final cubit = buildCubit();

    expect(cubit.state, CalendarState(month: august, today: today));
  });

  test('takes today and the month from São Paulo, not from the device', () {
    // 02h UTC de 01/09 ainda é 31/08 em São Paulo.
    final cubit = buildCubit(at: DateTime.utc(2026, 9, 1, 2));

    expect(cubit.state.month, august);
    expect(cubit.state.today, DateTime(2026, 8, 31));
  });

  group('load', () {
    blocTest<CalendarCubit, CalendarState>(
      'requests the visible grid and splits the month into upcoming and past',
      setUp: () => stubMonth(august, Success([upcoming, july, past])),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [CalendarState(month: august, today: today), loadedAugust],
      verify: (_) {
        verify(
          () => repository.getMeetings(
            from: DateTime(2026, 7, 26),
            to: DateTime(2026, 9, 5),
          ),
        ).called(1);
      },
    );

    blocTest<CalendarCubit, CalendarState>(
      'emits the failure',
      setUp: () => stubMonth(august, const Failure(CalendarNetworkFailure())),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        CalendarState(month: august, today: today),
        CalendarState(
          month: august,
          today: today,
          status: CalendarStatus.error,
          failure: const CalendarNetworkFailure(),
        ),
      ],
    );
  });

  group('month navigation', () {
    blocTest<CalendarCubit, CalendarState>(
      'loads the next month and drops the selected day, keeping the filter',
      setUp: () => stubMonth(september, const Success([])),
      build: buildCubit,
      seed: () => loadedAugust.copyWith(
        filter: CalendarFilter.past,
        selectedDay: DateTime(2026, 8, 17),
      ),
      act: (cubit) => cubit.showNextMonth(),
      expect: () => [
        CalendarState(
          month: september,
          today: today,
          filter: CalendarFilter.past,
        ),
        CalendarState(
          month: september,
          today: today,
          filter: CalendarFilter.past,
          status: CalendarStatus.loaded,
        ),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'loads the previous month',
      setUp: () => stubMonth(const CalendarMonth(2026, 7), const Success([])),
      build: buildCubit,
      act: (cubit) => cubit.showPreviousMonth(),
      verify: (cubit) {
        expect(cubit.state.month, const CalendarMonth(2026, 7));
        expect(cubit.state.status, CalendarStatus.loaded);
      },
    );

    test('applies only the latest request when an old answer arrives last '
        '(August, September, August)', () async {
      final firstAugust =
          Completer<Result<List<CalendarMeetingEntity>, CalendarFailure>>();
      final augustAnswers = [
        firstAugust.future,
        Future.value(
          Success<List<CalendarMeetingEntity>, CalendarFailure>([upcoming]),
        ),
      ];
      when(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
        ),
      ).thenAnswer((_) => augustAnswers.removeAt(0));
      stubMonth(september, const Success([]));
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final staleLoad = cubit.load();
      await cubit.showNextMonth();
      await cubit.showPreviousMonth();
      firstAugust.complete(Success([past]));
      await staleLoad;

      expect(cubit.state.month, august);
      expect(cubit.state.status, CalendarStatus.loaded);
      expect(cubit.state.meetings, [upcoming]);
    });
  });

  group('upcoming and past', () {
    Future<CalendarState> loadAugust(List<CalendarMeetingEntity> data) async {
      stubMonth(august, Success(data));
      final cubit = buildCubit();
      addTearDown(cubit.close);
      await cubit.load();
      return cubit.state;
    }

    test('splits a meeting of today by the current time', () async {
      final morning = calendarMeeting('morning', day: today, hour: 10);
      final evening = calendarMeeting('evening', day: today, hour: 18);

      final state = await loadAugust([morning, evening]);

      expect(state.past, [morning]);
      expect(state.upcoming, [evening]);
    });

    test('counts a meeting in progress as upcoming', () async {
      final ongoing = calendarMeeting(
        'ongoing',
        day: today,
        hour: 11,
        status: CalendarMeetingStatus.inProgress,
      );

      final state = await loadAugust([ongoing]);

      expect(state.upcoming, [ongoing]);
      expect(state.past, isEmpty);
    });

    test('cuts the month by local_date, not by the UTC date', () async {
      // 23h30 de 31/08 em São Paulo é 02h30 de 01/09 em UTC.
      final lateNight = calendarMeeting(
        'late',
        day: DateTime(2026, 8, 31),
        hour: 23,
        minute: 30,
      );
      expect(lateNight.date, DateTime.utc(2026, 9, 1, 2, 30));

      final state = await loadAugust([lateNight]);

      expect(state.upcoming, [lateNight]);
      expect(state.meetingCountByDay, {DateTime(2026, 8, 31): 1});
    });
  });

  group('day selected while loading', () {
    blocTest<CalendarCubit, CalendarState>(
      'is kept when the month loads',
      setUp: () => stubMonth(august, Success([upcoming])),
      build: buildCubit,
      act: (cubit) async {
        final load = cubit.load();
        cubit.selectDay(DateTime(2026, 8, 17));
        await load;
      },
      verify: (cubit) {
        expect(cubit.state.status, CalendarStatus.loaded);
        expect(cubit.state.selectedDay, DateTime(2026, 8, 17));
        expect(cubit.state.visibleMeetings, [upcoming]);
      },
    );

    blocTest<CalendarCubit, CalendarState>(
      'is kept when the month fails, and through the retry',
      setUp: () => stubMonth(august, const Failure(CalendarLoadFailure())),
      build: buildCubit,
      act: (cubit) async {
        final load = cubit.load();
        cubit.selectDay(DateTime(2026, 8, 17));
        await load;
        expect(cubit.state.status, CalendarStatus.error);
        expect(cubit.state.selectedDay, DateTime(2026, 8, 17));
        stubMonth(august, Success([upcoming]));
        await cubit.load();
      },
      verify: (cubit) {
        expect(cubit.state.status, CalendarStatus.loaded);
        expect(cubit.state.selectedDay, DateTime(2026, 8, 17));
      },
    );
  });

  group('filters and day selection', () {
    blocTest<CalendarCubit, CalendarState>(
      'filters the list',
      build: buildCubit,
      seed: () => loadedAugust,
      act: (cubit) => cubit
        ..selectFilter(CalendarFilter.upcoming)
        ..selectFilter(CalendarFilter.past),
      expect: () => [
        loadedAugust.copyWith(filter: CalendarFilter.upcoming),
        loadedAugust.copyWith(filter: CalendarFilter.past),
      ],
      verify: (cubit) => expect(cubit.state.visibleMeetings, [past]),
    );

    blocTest<CalendarCubit, CalendarState>(
      'selects a day of the month, then clears it on a second tap',
      build: buildCubit,
      seed: () => loadedAugust,
      act: (cubit) => cubit
        ..selectDay(DateTime(2026, 8, 17))
        ..selectDay(DateTime(2026, 8, 17)),
      expect: () => [
        loadedAugust.copyWith(selectedDay: DateTime(2026, 8, 17)),
        loadedAugust,
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'clears the selected day',
      build: buildCubit,
      seed: () => loadedAugust.copyWith(selectedDay: DateTime(2026, 8, 17)),
      act: (cubit) => cubit.clearSelectedDay(),
      expect: () => [loadedAugust],
    );

    blocTest<CalendarCubit, CalendarState>(
      'does not select a day of a neighbor month',
      build: buildCubit,
      seed: () => loadedAugust,
      act: (cubit) => cubit.selectDay(DateTime(2026, 7, 28)),
      expect: () => <CalendarState>[],
    );
  });

  group('CalendarState', () {
    test('lists the whole month in date order under "all"', () {
      expect(loadedAugust.visibleMeetings, [past, upcoming]);
    });

    test('lists only the meetings of the selected day', () {
      final state = loadedAugust.copyWith(selectedDay: DateTime(2026, 8, 10));

      expect(state.visibleMeetings, [past]);
    });

    test('counts the meetings of every grid day, neighbor months included', () {
      expect(loadedAugust.meetingCountByDay, {
        DateTime(2026, 7, 28): 1,
        DateTime(2026, 8, 10): 1,
        DateTime(2026, 8, 17): 1,
      });
    });
  });

  group('requestParticipation', () {
    final guest = calendarMeeting(
      'guest',
      day: DateTime(2026, 8, 20),
      groupNumber: 9,
      membership: CalendarMembershipStatus.none,
      canRequestParticipation: true,
    );
    final requested = guest.asRequested();
    final loaded = CalendarState(
      month: august,
      today: today,
      status: CalendarStatus.loaded,
      meetings: [past, guest],
      upcoming: [guest],
      past: [past],
    );

    final rejectedGuest = calendarMeeting(
      'guest',
      day: DateTime(2026, 8, 20),
      groupNumber: 9,
      membership: CalendarMembershipStatus.none,
      guestStatus: CalendarGuestStatus.rejected,
      canRequestParticipation: true,
    );

    void stubRequest(Result<void, CalendarFailure> result) {
      when(
        () => repository.requestParticipation(any()),
      ).thenAnswer((_) async => result);
    }

    blocTest<CalendarCubit, CalendarState>(
      'marks the card as requested and asks for the success notice',
      setUp: () => stubRequest(const Success(null)),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.requestParticipation('guest'),
      expect: () => [
        loaded.copyWith(requestingIds: {'guest'}),
        loaded.copyWith(
          meetings: [past, requested],
          upcoming: [requested],
          participationRequested: true,
        ),
      ],
      verify: (_) {
        verify(() => repository.requestParticipation('guest')).called(1);
      },
    );

    test('a double tap sends a single request', () async {
      final answer = Completer<Result<void, CalendarFailure>>();
      when(
        () => repository.requestParticipation(any()),
      ).thenAnswer((_) => answer.future);
      final cubit = buildCubit()..emit(loaded);
      addTearDown(cubit.close);

      final first = cubit.requestParticipation('guest');
      final second = cubit.requestParticipation('guest');
      answer.complete(const Success(null));
      await Future.wait([first, second]);

      verify(() => repository.requestParticipation('guest')).called(1);
      expect(cubit.state.requestingIds, isEmpty);
      expect(
        cubit.state.meetings.last.guestStatus,
        CalendarGuestStatus.requested,
      );
    });

    blocTest<CalendarCubit, CalendarState>(
      'ignores a meeting the backend blocks and one already requested',
      build: buildCubit,
      seed: () => loaded.copyWith(
        meetings: [
          past,
          // Sem vínculo visível, mas o backend não deixa (ex.: ex-membro).
          calendarMeeting(
            'blocked',
            day: DateTime(2026, 8, 20),
            membership: CalendarMembershipStatus.none,
          ),
          requested,
        ],
      ),
      act: (cubit) async {
        await cubit.requestParticipation('blocked');
        await cubit.requestParticipation('guest');
      },
      expect: () => <CalendarState>[],
      verify: (_) {
        verifyNever(() => repository.requestParticipation(any()));
      },
    );

    // Começou com o modal aberto: a leitora confirmou e precisa saber.
    test('a meeting that started before the confirmation reports it as not '
        'open, without sending', () async {
      var clock = now;
      final cubit = CalendarCubit(repository: repository, now: () => clock)
        ..emit(loaded);
      addTearDown(cubit.close);

      clock = guest.date.add(const Duration(minutes: 1));
      await cubit.requestParticipation('guest');

      verifyNever(() => repository.requestParticipation(any()));
      expect(
        cubit.state.participationFailure,
        const CalendarMeetingNotOpenFailure(),
      );
      expect(cubit.state.requestingIds, isEmpty);
    });

    test('an approval loaded while the request is pending is kept', () async {
      final answer = Completer<Result<void, CalendarFailure>>();
      when(
        () => repository.requestParticipation(any()),
      ).thenAnswer((_) => answer.future);
      final accepted = calendarMeeting(
        'guest',
        day: DateTime(2026, 8, 20),
        groupNumber: 9,
        membership: CalendarMembershipStatus.none,
        guestStatus: CalendarGuestStatus.accepted,
      );
      stubMonth(august, Success([past, accepted]));
      final cubit = buildCubit()..emit(loaded);
      addTearDown(cubit.close);

      final request = cubit.requestParticipation('guest');
      await cubit.refresh();
      expect(
        cubit.state.upcoming.single.guestStatus,
        CalendarGuestStatus.accepted,
      );
      answer.complete(const Success(null));
      await request;

      expect(
        cubit.state.upcoming.single.guestStatus,
        CalendarGuestStatus.accepted,
      );
      expect(cubit.state.participationRequested, isTrue);
    });

    blocTest<CalendarCubit, CalendarState>(
      'refresh reloads the month without the skeleton',
      setUp: () => stubMonth(august, Success([past, requested])),
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        loaded.copyWith(meetings: [past, requested], upcoming: [requested]),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'refresh leaves a month that is still loading alone',
      build: buildCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => <CalendarState>[],
      verify: (_) {
        verifyNever(
          () => repository.getMeetings(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        );
      },
    );

    blocTest<CalendarCubit, CalendarState>(
      'a rejected request can be sent again',
      setUp: () => stubRequest(const Success(null)),
      build: buildCubit,
      seed: () => loaded.copyWith(
        meetings: [past, rejectedGuest],
        upcoming: [rejectedGuest],
      ),
      act: (cubit) => cubit.requestParticipation('guest'),
      verify: (cubit) {
        verify(() => repository.requestParticipation('guest')).called(1);
        expect(cubit.state.upcoming, [requested]);
      },
    );

    for (final failure in const <CalendarFailure>[
      CalendarNetworkFailure(),
      CalendarSessionExpiredFailure(),
      CalendarForbiddenFailure(),
      CalendarGuestRecentlyRejectedFailure(),
      CalendarMeetingNoReviewerFailure(),
      CalendarGuestRequestFailure(),
    ]) {
      blocTest<CalendarCubit, CalendarState>(
        'keeps the card and reports ${failure.runtimeType} without reloading',
        setUp: () => stubRequest(Failure(failure)),
        build: buildCubit,
        seed: () => loaded,
        act: (cubit) => cubit.requestParticipation('guest'),
        expect: () => [
          loaded.copyWith(requestingIds: {'guest'}),
          loaded.copyWith(participationFailure: failure),
        ],
        verify: (_) {
          verifyNever(
            () => repository.getMeetings(
              from: any(named: 'from'),
              to: any(named: 'to'),
            ),
          );
        },
      );
    }

    for (final failure in const <CalendarFailure>[
      CalendarGuestAlreadyRequestedFailure(),
      CalendarGuestAlreadyMemberFailure(),
      CalendarMeetingNotOpenFailure(),
      CalendarMeetingUnavailableFailure(),
      CalendarMeetingNotFoundFailure(),
    ]) {
      blocTest<CalendarCubit, CalendarState>(
        '${failure.runtimeType} reloads the month without the skeleton, '
        'keeping the card busy until the real status arrives',
        setUp: () {
          stubRequest(Failure(failure));
          stubMonth(august, Success([past, requested]));
        },
        build: buildCubit,
        seed: () => loaded,
        act: (cubit) => cubit.requestParticipation('guest'),
        expect: () => [
          loaded.copyWith(requestingIds: {'guest'}),
          loaded.copyWith(
            requestingIds: {'guest'},
            participationFailure: failure,
          ),
          loaded.copyWith(
            meetings: [past, requested],
            upcoming: [requested],
            requestingIds: {'guest'},
            participationFailure: failure,
          ),
          loaded.copyWith(
            meetings: [past, requested],
            upcoming: [requested],
            participationFailure: failure,
          ),
        ],
      );
    }

    blocTest<CalendarCubit, CalendarState>(
      'a failed reload after a stale answer keeps the month on screen',
      setUp: () {
        stubRequest(const Failure(CalendarGuestAlreadyRequestedFailure()));
        stubMonth(august, const Failure(CalendarNetworkFailure()));
      },
      build: buildCubit,
      seed: () => loaded,
      act: (cubit) => cubit.requestParticipation('guest'),
      skip: 2,
      expect: () => [
        loaded.copyWith(
          participationFailure: const CalendarGuestAlreadyRequestedFailure(),
        ),
      ],
    );

    test('a load started before a successful request keeps the request '
        'on the card', () async {
      final staleMonth =
          Completer<Result<List<CalendarMeetingEntity>, CalendarFailure>>();
      when(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
        ),
      ).thenAnswer((_) => staleMonth.future);
      stubRequest(const Success(null));
      final cubit = buildCubit()..emit(loaded);
      addTearDown(cubit.close);

      final reload = cubit.load();
      // A lista some durante a carga, mas a leitora já confirmou no modal:
      // o pedido segue mesmo sem o encontro na lista.
      expect(cubit.state.meetings, isEmpty);
      await cubit.requestParticipation('guest');
      verify(() => repository.requestParticipation('guest')).called(1);
      expect(cubit.state.participationRequested, isTrue);
      staleMonth.complete(Success([past, guest]));
      await reload;

      expect(cubit.state.status, CalendarStatus.loaded);
      expect(
        cubit.state.upcoming.single.guestStatus,
        CalendarGuestStatus.requested,
      );
    });

    blocTest<CalendarCubit, CalendarState>(
      'clearParticipationFeedback drops the notice',
      build: buildCubit,
      seed: () => loaded.copyWith(
        participationRequested: true,
        participationFailure: const CalendarNetworkFailure(),
      ),
      act: (cubit) => cubit.clearParticipationFeedback(),
      expect: () => [loaded],
    );

    blocTest<CalendarCubit, CalendarState>(
      'a reload keeps the requests in progress',
      setUp: () => stubMonth(august, Success([past, guest])),
      build: buildCubit,
      seed: () => loaded.copyWith(requestingIds: {'guest'}),
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.status, CalendarStatus.loaded);
        expect(cubit.state.requestingIds, {'guest'});
      },
    );

    test('a stale answer while another month loads skips the reload and '
        'frees the card', () async {
      final answer = Completer<Result<void, CalendarFailure>>();
      when(
        () => repository.requestParticipation(any()),
      ).thenAnswer((_) => answer.future);
      final september =
          Completer<Result<List<CalendarMeetingEntity>, CalendarFailure>>();
      when(
        () => repository.getMeetings(
          from: const CalendarMonth(2026, 9).firstVisibleDay,
          to: const CalendarMonth(2026, 9).lastVisibleDay,
        ),
      ).thenAnswer((_) => september.future);
      final cubit = buildCubit()..emit(loaded);
      addTearDown(cubit.close);

      final request = cubit.requestParticipation('guest');
      final navigation = cubit.showNextMonth();
      expect(cubit.state.status, CalendarStatus.loading);
      answer.complete(const Failure(CalendarGuestAlreadyRequestedFailure()));
      await request;

      expect(cubit.state.requestingIds, isEmpty);
      expect(
        cubit.state.participationFailure,
        const CalendarGuestAlreadyRequestedFailure(),
      );
      verifyNever(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
        ),
      );
      september.complete(const Success([]));
      await navigation;
      expect(cubit.state.month, const CalendarMonth(2026, 9));
    });

    test('a month change during the silent reload drops its answer and '
        'frees the card', () async {
      stubRequest(const Failure(CalendarGuestAlreadyRequestedFailure()));
      final refresh =
          Completer<Result<List<CalendarMeetingEntity>, CalendarFailure>>();
      when(
        () => repository.getMeetings(
          from: august.firstVisibleDay,
          to: august.lastVisibleDay,
        ),
      ).thenAnswer((_) => refresh.future);
      stubMonth(september, const Success([]));
      final cubit = buildCubit()..emit(loaded);
      addTearDown(cubit.close);

      final request = cubit.requestParticipation('guest');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.requestingIds, {'guest'});
      await cubit.showNextMonth();
      refresh.complete(Success([past, requested]));
      await request;

      expect(cubit.state.month, september);
      expect(cubit.state.status, CalendarStatus.loaded);
      expect(cubit.state.meetings, isEmpty);
      expect(cubit.state.requestingIds, isEmpty);
    });
  });
}
