import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

MeetingAttendanceEntity _attendee(
  String id,
  String name, {
  MeetingPresenceStatus? presenceStatus,
}) => MeetingAttendanceEntity(
  id: id,
  name: name,
  invitationStatus: MeetingInvitationStatus.confirmed,
  presenceStatus: presenceStatus,
);

void main() {
  late MockGroupRepository repository;
  late MeetingPresenceCubit cubit;

  const meetingId = 'meeting-1';

  setUp(() {
    repository = MockGroupRepository();
    cubit = MeetingPresenceCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  void stubAttendance(List<MeetingAttendanceEntity> attendees) {
    when(() => repository.getMeetingAttendance(meetingId)).thenAnswer(
      (_) async =>
          Success<List<MeetingAttendanceEntity>, GroupFailure>(attendees),
    );
  }

  group('estado inicial', () {
    test('começa em MeetingPresenceLoading', () {
      expect(cubit.state, const MeetingPresenceLoading());
    });
  });

  group('load', () {
    test('emite Loading e depois Editing com participantes ordenados '
        'alfabeticamente sem diferenciar maiúsculas de minúsculas', () async {
      stubAttendance([
        _attendee('u-1', 'bruno'),
        _attendee('u-2', 'Ana'),
        _attendee('u-3', 'carla'),
        _attendee('u-4', 'Ágata'),
      ]);

      final states = <MeetingPresenceState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.load(meetingId);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states.first, const MeetingPresenceLoading());
      expect(states.last, isA<MeetingPresenceEditing>());

      final editing = states.last as MeetingPresenceEditing;
      expect(editing.attendees.map((a) => a.name).toList(), [
        'Ágata',
        'Ana',
        'bruno',
        'carla',
      ]);
      expect(editing.marked, {'u-1', 'u-2', 'u-3', 'u-4'});
      expect(editing.isSubmitting, isFalse);
      expect(editing.submitError, isNull);
      verify(() => repository.getMeetingAttendance(meetingId)).called(1);
    });

    test('emite Editing com lista vazia quando não há participantes', () async {
      stubAttendance([]);

      await cubit.load(meetingId);

      expect(cubit.state, const MeetingPresenceEditing(attendees: []));
    });

    test(
      'emite Closed quando algum participante já tem presenceStatus',
      () async {
        stubAttendance([
          _attendee(
            'u-1',
            'Bruno',
            presenceStatus: MeetingPresenceStatus.present,
          ),
          _attendee('u-2', 'Ana', presenceStatus: MeetingPresenceStatus.absent),
        ]);

        await cubit.load(meetingId);

        expect(cubit.state, isA<MeetingPresenceClosed>());
        final closed = cubit.state as MeetingPresenceClosed;
        expect(closed.confirmed, isFalse);
        expect(closed.attendees.map((a) => a.name).toList(), ['Ana', 'Bruno']);
      },
    );

    test(
      'emite Closed mesmo se apenas um participante tiver presenceStatus',
      () async {
        stubAttendance([
          _attendee('u-1', 'Ana'),
          _attendee(
            'u-2',
            'Bruno',
            presenceStatus: MeetingPresenceStatus.present,
          ),
        ]);

        await cubit.load(meetingId);

        expect(cubit.state, isA<MeetingPresenceClosed>());
      },
    );

    test(
      'emite Error com a mensagem da falha quando o repositório falha',
      () async {
        const failure = MeetingAttendanceFailure();
        when(() => repository.getMeetingAttendance(meetingId)).thenAnswer(
          (_) async =>
              const Failure<List<MeetingAttendanceEntity>, GroupFailure>(
                failure,
              ),
        );

        await cubit.load(meetingId);

        expect(cubit.state, MeetingPresenceError(failure.message));
      },
    );
  });

  group('toggle', () {
    setUp(() async {
      stubAttendance([_attendee('u-1', 'Ana'), _attendee('u-2', 'Bruno')]);
      await cubit.load(meetingId);
    });

    test('desmarca um participante marcado', () {
      cubit.toggle('u-1');

      final state = cubit.state as MeetingPresenceEditing;
      expect(state.marked, {'u-2'});
    });

    test('marca de novo um participante desmarcado', () {
      cubit
        ..toggle('u-1')
        ..toggle('u-1');

      final state = cubit.state as MeetingPresenceEditing;
      expect(state.marked, {'u-1', 'u-2'});
    });

    test('permite desmarcar vários participantes', () {
      cubit
        ..toggle('u-1')
        ..toggle('u-2');

      final state = cubit.state as MeetingPresenceEditing;
      expect(state.marked, isEmpty);
    });

    test('limpa o submitError ao alternar uma marcação', () async {
      cubit.toggle('u-1');
      when(() => repository.setMeetingPresence(meetingId, any())).thenAnswer(
        (_) async =>
            const Failure<void, GroupFailure>(MeetingPresenceFailure()),
      );
      await cubit.confirm();
      expect((cubit.state as MeetingPresenceEditing).submitError, isNotNull);

      cubit.toggle('u-2');

      expect((cubit.state as MeetingPresenceEditing).submitError, isNull);
    });

    test('não faz nada enquanto está enviando', () async {
      final blocker = Completer<Result<void, GroupFailure>>();
      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) => blocker.future);

      cubit.toggle('u-1');
      final pending = cubit.confirm();
      expect((cubit.state as MeetingPresenceEditing).isSubmitting, isTrue);

      cubit.toggle('u-2');

      expect((cubit.state as MeetingPresenceEditing).marked, {'u-2'});

      blocker.complete(const Success<void, GroupFailure>(null));
      await pending;
    });

    test('não faz nada quando o estado não é Editing', () {
      final loadingCubit = MeetingPresenceCubit(repository: repository);

      loadingCubit.toggle('u-1');

      expect(loadingCubit.state, const MeetingPresenceLoading());
      loadingCubit.close();
    });
  });

  group('confirm', () {
    setUp(() async {
      stubAttendance([
        _attendee('u-1', 'Ana'),
        _attendee('u-2', 'Bruno'),
        _attendee('u-3', 'Carla'),
      ]);
      await cubit.load(meetingId);
    });

    test(
      'em sucesso envia os ids marcados e emite Closed confirmado',
      () async {
        when(
          () => repository.setMeetingPresence(meetingId, any()),
        ).thenAnswer((_) async => const Success<void, GroupFailure>(null));

        cubit.toggle('u-2');

        final states = <MeetingPresenceState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.confirm();
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(states.first, isA<MeetingPresenceEditing>());
        expect((states.first as MeetingPresenceEditing).isSubmitting, isTrue);

        expect(states.last, isA<MeetingPresenceClosed>());
        final closed = states.last as MeetingPresenceClosed;
        expect(closed.confirmed, isTrue);
        expect(closed.attendees.map((a) => a.presenceStatus).toList(), [
          MeetingPresenceStatus.present,
          MeetingPresenceStatus.absent,
          MeetingPresenceStatus.present,
        ]);
        expect(closed.attendees.map((a) => a.id).toList(), [
          'u-1',
          'u-2',
          'u-3',
        ]);

        verify(
          () => repository.setMeetingPresence(
            meetingId,
            any(that: unorderedEquals(['u-1', 'u-3'])),
          ),
        ).called(1);
      },
    );

    test('em sucesso sem alterações marca todos como presentes', () async {
      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) async => const Success<void, GroupFailure>(null));

      await cubit.confirm();

      final closed = cubit.state as MeetingPresenceClosed;
      expect(
        closed.attendees.every(
          (a) => a.presenceStatus == MeetingPresenceStatus.present,
        ),
        isTrue,
      );
      verify(
        () => repository.setMeetingPresence(
          meetingId,
          any(that: unorderedEquals(['u-1', 'u-2', 'u-3'])),
        ),
      ).called(1);
    });

    test('em sucesso sem marcações marca todos como ausentes', () async {
      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) async => const Success<void, GroupFailure>(null));

      cubit
        ..toggle('u-1')
        ..toggle('u-2')
        ..toggle('u-3');
      await cubit.confirm();

      final closed = cubit.state as MeetingPresenceClosed;
      expect(
        closed.attendees.every(
          (a) => a.presenceStatus == MeetingPresenceStatus.absent,
        ),
        isTrue,
      );
    });

    test('mantém invitationStatus e photoUrl dos participantes', () async {
      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) async => const Success<void, GroupFailure>(null));

      final original = (cubit.state as MeetingPresenceEditing).attendees;

      await cubit.confirm();

      final closed = cubit.state as MeetingPresenceClosed;
      for (var i = 0; i < original.length; i++) {
        expect(
          closed.attendees[i].invitationStatus,
          original[i].invitationStatus,
        );
        expect(closed.attendees[i].photoUrl, original[i].photoUrl);
        expect(closed.attendees[i].name, original[i].name);
      }
    });

    for (final failure in <GroupFailure>[
      const MeetingPresenceForbiddenFailure(),
      const MeetingPresenceAlreadyRegisteredFailure(),
      const MeetingPresenceFailure(),
    ]) {
      test('em falha ${failure.runtimeType} mantém marcações e expõe '
          'submitError', () async {
        when(
          () => repository.setMeetingPresence(meetingId, any()),
        ).thenAnswer((_) async => Failure<void, GroupFailure>(failure));

        cubit.toggle('u-2');
        await cubit.confirm();

        expect(cubit.state, isA<MeetingPresenceEditing>());
        final editing = cubit.state as MeetingPresenceEditing;
        expect(editing.isSubmitting, isFalse);
        expect(editing.submitError, failure.message);
        expect(editing.marked, {'u-1', 'u-3'});
      });
    }

    test('permite nova tentativa após falha', () async {
      when(() => repository.setMeetingPresence(meetingId, any())).thenAnswer(
        (_) async =>
            const Failure<void, GroupFailure>(MeetingPresenceFailure()),
      );
      cubit.toggle('u-1');
      await cubit.confirm();

      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) async => const Success<void, GroupFailure>(null));
      await cubit.confirm();

      expect(cubit.state, isA<MeetingPresenceClosed>());
      expect((cubit.state as MeetingPresenceClosed).confirmed, isTrue);
    });

    test('ignora chamadas quando já está enviando', () async {
      final blocker = Completer<Result<void, GroupFailure>>();
      when(
        () => repository.setMeetingPresence(meetingId, any()),
      ).thenAnswer((_) => blocker.future);

      final first = cubit.confirm();
      await cubit.confirm();

      verify(() => repository.setMeetingPresence(meetingId, any())).called(1);

      blocker.complete(const Success<void, GroupFailure>(null));
      await first;
    });

    test('não faz nada quando o estado não é Editing', () async {
      final loadingCubit = MeetingPresenceCubit(repository: repository);

      await loadingCubit.confirm();

      expect(loadingCubit.state, const MeetingPresenceLoading());
      verifyNever(() => repository.setMeetingPresence(any(), any()));
      await loadingCubit.close();
    });
  });
}
