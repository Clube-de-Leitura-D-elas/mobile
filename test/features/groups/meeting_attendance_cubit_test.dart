import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_attendance_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;
  late MeetingAttendanceCubit cubit;

  const participant = MeetingAttendanceEntity(
    id: 'user-1',
    name: 'Ana Souza',
    photoUrl: null,
    invitationStatus: MeetingInvitationStatus.confirmed,
    presenceStatus: MeetingPresenceStatus.present,
  );

  setUp(() {
    repository = MockGroupRepository();
    cubit = MeetingAttendanceCubit(
      groupRepository: repository,
      meetingId: 'meeting-1',
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('MeetingAttendanceCubit', () {
    test('inicia no estado de carregamento', () {
      expect(cubit.state, isA<MeetingAttendanceLoading>());
    });

    test('emite Loading e Loaded quando a consulta tem sucesso', () async {
      when(
        () => repository.getMeetingAttendance('meeting-1'),
      ).thenAnswer((_) async => const Success([participant]));

      final states = <MeetingAttendanceState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.fetchAttendance();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<MeetingAttendanceLoading>(),
        const MeetingAttendanceLoaded([participant]),
      ]);
      expect(cubit.state, const MeetingAttendanceLoaded([participant]));

      await subscription.cancel();
      verify(() => repository.getMeetingAttendance('meeting-1')).called(1);
    });

    test('emite Loading e Error quando a consulta falha', () async {
      when(() => repository.getMeetingAttendance('meeting-1')).thenAnswer(
        (_) async =>
            const Failure(GroupDetailsFailure(message: 'Erro de teste')),
      );

      final states = <MeetingAttendanceState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.fetchAttendance();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<MeetingAttendanceLoading>(),
        const MeetingAttendanceError(
          'Não foi possível carregar a lista de presença.',
        ),
      ]);
      expect(
        cubit.state,
        const MeetingAttendanceError(
          'Não foi possível carregar a lista de presença.',
        ),
      );

      await subscription.cancel();
    });

    test('permite buscar novamente após um erro', () async {
      var calls = 0;

      when(() => repository.getMeetingAttendance('meeting-1')).thenAnswer((
        _,
      ) async {
        calls++;

        if (calls == 1) {
          return const Failure(GroupDetailsFailure(message: 'Erro de teste'));
        }

        return const Success([participant]);
      });

      await cubit.fetchAttendance();
      expect(cubit.state, isA<MeetingAttendanceError>());

      await cubit.fetchAttendance();

      expect(cubit.state, const MeetingAttendanceLoaded([participant]));
      expect(calls, 2);
    });

    test('estados Loaded iguais quando os participantes são iguais', () {
      expect(
        const MeetingAttendanceLoaded([participant]),
        const MeetingAttendanceLoaded([participant]),
      );
    });

    test('estados Error iguais quando as mensagens são iguais', () {
      expect(
        const MeetingAttendanceError('Falha'),
        const MeetingAttendanceError('Falha'),
      );
    });
  });
}
