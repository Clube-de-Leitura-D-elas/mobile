import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;
  final date = DateTime(2026, 10, 30, 19, 30);

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = MockGroupRepository();
  });

  void answerWith(Future<Result<void, GroupFailure>> Function() answer) {
    when(
      () => repository.updateMeeting(
        meetingId: any(named: 'meetingId'),
        date: any(named: 'date'),
        googlePlaceId: any(named: 'googlePlaceId'),
        description: any(named: 'description'),
      ),
    ).thenAnswer((_) => answer());
  }

  Future<void> submit(MeetingEditCubit cubit) => cubit.submit(
    meetingId: 'meeting-1',
    date: date,
    googlePlaceId: 'place-1',
    description: 'Trazer o livro',
  );

  blocTest<MeetingEditCubit, MeetingEditState>(
    'given the backend saves, when submitting, then emits submitting and success',
    build: () {
      answerWith(() async => const Success(null));
      return MeetingEditCubit(groupRepository: repository);
    },
    act: submit,
    expect: () => const [MeetingEditSubmitting(), MeetingEditSuccess()],
    verify: (_) {
      verify(
        () => repository.updateMeeting(
          meetingId: 'meeting-1',
          date: date,
          googlePlaceId: 'place-1',
          description: 'Trazer o livro',
        ),
      ).called(1);
    },
  );

  blocTest<MeetingEditCubit, MeetingEditState>(
    'given the meeting is locked, when submitting, then emits the failure message',
    build: () {
      answerWith(() async => const Failure(MeetingNotEditableFailure()));
      return MeetingEditCubit(groupRepository: repository);
    },
    act: submit,
    expect: () => const [
      MeetingEditSubmitting(),
      MeetingEditError('Este encontro não pode mais ser editado.'),
    ],
  );

  blocTest<MeetingEditCubit, MeetingEditState>(
    'given a save in progress, when submitting again, then ignores the second tap',
    build: () {
      final response = Completer<Result<void, GroupFailure>>();
      answerWith(() => response.future);
      addTearDown(() {
        if (!response.isCompleted) response.complete(const Success(null));
      });
      return MeetingEditCubit(groupRepository: repository);
    },
    act: (cubit) {
      unawaited(submit(cubit));
      unawaited(submit(cubit));
    },
    expect: () => const [MeetingEditSubmitting()],
    verify: (_) {
      verify(
        () => repository.updateMeeting(
          meetingId: any(named: 'meetingId'),
          date: any(named: 'date'),
          googlePlaceId: any(named: 'googlePlaceId'),
          description: any(named: 'description'),
        ),
      ).called(1);
    },
  );
}
