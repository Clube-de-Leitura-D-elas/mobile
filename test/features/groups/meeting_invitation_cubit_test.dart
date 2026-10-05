import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;

  setUpAll(() {
    registerFallbackValue(MeetingInvitationStatus.pending);
  });

  setUp(() {
    repository = MockGroupRepository();
  });

  group('MeetingInvitationCubit', () {
    blocTest<MeetingInvitationCubit, MeetingInvitationState>(
      'emits [Submitting, Idle(confirmed)] when respond succeeds',
      build: () {
        when(
          () => repository.setMeetingInvitationResponse(any(), any()),
        ).thenAnswer((_) async => const Success(null));
        return MeetingInvitationCubit(
          groupRepository: repository,
          meetingId: 'meeting-1',
        );
      },
      act: (cubit) => cubit.respond(MeetingInvitationStatus.confirmed),
      expect: () => [
        const MeetingInvitationSubmitting(
          MeetingInvitationStatus.pending,
          MeetingInvitationStatus.confirmed,
        ),
        const MeetingInvitationIdle(MeetingInvitationStatus.confirmed),
      ],
    );

    blocTest<MeetingInvitationCubit, MeetingInvitationState>(
      'emits [Submitting, Error] and keeps the previous status when respond fails',
      build: () {
        when(
          () => repository.setMeetingInvitationResponse(any(), any()),
        ).thenAnswer(
          (_) async => const Failure(GroupMeetingInvitationResponseFailure()),
        );
        return MeetingInvitationCubit(
          groupRepository: repository,
          meetingId: 'meeting-1',
          initialStatus: MeetingInvitationStatus.declined,
        );
      },
      act: (cubit) => cubit.respond(MeetingInvitationStatus.confirmed),
      expect: () => [
        const MeetingInvitationSubmitting(
          MeetingInvitationStatus.declined,
          MeetingInvitationStatus.confirmed,
        ),
        isA<MeetingInvitationError>()
            .having(
              (s) => s.currentStatus,
              'currentStatus',
              MeetingInvitationStatus.declined,
            )
            .having(
              (s) => s.attemptedStatus,
              'attemptedStatus',
              MeetingInvitationStatus.confirmed,
            ),
      ],
    );

    blocTest<MeetingInvitationCubit, MeetingInvitationState>(
      'ignores a respond call while already submitting',
      build: () {
        when(
          () => repository.setMeetingInvitationResponse(any(), any()),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return const Success(null);
        });
        return MeetingInvitationCubit(
          groupRepository: repository,
          meetingId: 'meeting-1',
        );
      },
      act: (cubit) async {
        final firstCall = cubit.respond(MeetingInvitationStatus.confirmed);
        final secondCall = cubit.respond(MeetingInvitationStatus.declined);
        await Future.wait([firstCall, secondCall]);
      },
      expect: () => [
        const MeetingInvitationSubmitting(
          MeetingInvitationStatus.pending,
          MeetingInvitationStatus.confirmed,
        ),
        const MeetingInvitationIdle(MeetingInvitationStatus.confirmed),
      ],
      verify: (_) {
        verify(
          () => repository.setMeetingInvitationResponse(any(), any()),
        ).called(1);
      },
    );
  });
}
