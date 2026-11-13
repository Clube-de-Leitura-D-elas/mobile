import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_status.dart';
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
}
