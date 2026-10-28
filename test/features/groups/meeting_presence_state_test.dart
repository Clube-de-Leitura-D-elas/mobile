import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/domain/entities/meeting_attendance_entity.dart';
import 'package:mobile/features/groups/domain/entities/meeting_invitation_status.dart';
import 'package:mobile/features/groups/domain/entities/meeting_presence_status.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_presence_state.dart';

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
  final ana = _attendee('u-1', 'Ana');
  final bruno = _attendee('u-2', 'Bruno');

  group('MeetingPresenceLoading', () {
    test('instâncias são iguais e não têm props', () {
      expect(const MeetingPresenceLoading(), const MeetingPresenceLoading());
      expect(const MeetingPresenceLoading().props, isEmpty);
    });
  });

  group('MeetingPresenceError', () {
    test('props contém a mensagem', () {
      expect(const MeetingPresenceError('falhou').props, ['falhou']);
    });

    test('é igual quando a mensagem é a mesma', () {
      expect(
        const MeetingPresenceError('falhou'),
        const MeetingPresenceError('falhou'),
      );
    });

    test('é diferente quando a mensagem muda', () {
      expect(
        const MeetingPresenceError('a') == const MeetingPresenceError('b'),
        isFalse,
      );
    });
  });

  group('MeetingPresenceEditing', () {
    test('usa os valores padrão', () {
      final state = MeetingPresenceEditing(attendees: [ana]);

      expect(state.attendees, [ana]);
      expect(state.marked, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.submitError, isNull);
    });

    test('props contém todos os campos', () {
      final state = MeetingPresenceEditing(
        attendees: [ana],
        marked: const {'u-1'},
        isSubmitting: true,
        submitError: 'erro',
      );

      expect(state.props, [
        [ana],
        {'u-1'},
        true,
        'erro',
      ]);
    });

    test('é igual quando todos os campos são iguais', () {
      expect(
        MeetingPresenceEditing(attendees: [ana], marked: const {'u-1'}),
        MeetingPresenceEditing(attendees: [ana], marked: const {'u-1'}),
      );
    });

    test('é diferente quando algum campo muda', () {
      final base = MeetingPresenceEditing(attendees: [ana]);

      expect(base == MeetingPresenceEditing(attendees: [ana, bruno]), isFalse);
      expect(
        base == MeetingPresenceEditing(attendees: [ana], marked: const {'u-1'}),
        isFalse,
      );
      expect(
        base == MeetingPresenceEditing(attendees: [ana], isSubmitting: true),
        isFalse,
      );
      expect(
        base == MeetingPresenceEditing(attendees: [ana], submitError: 'x'),
        isFalse,
      );
    });

    group('copyWith', () {
      test('sem argumentos mantém todos os valores', () {
        final state = MeetingPresenceEditing(
          attendees: [ana],
          marked: const {'u-1'},
          isSubmitting: true,
          submitError: 'erro',
        );

        expect(state.copyWith(), state);
      });

      test('substitui marked mantendo o resto', () {
        final state = MeetingPresenceEditing(
          attendees: [ana, bruno],
          submitError: 'erro',
        );

        final copy = state.copyWith(marked: const {'u-2'});

        expect(copy.marked, {'u-2'});
        expect(copy.attendees, [ana, bruno]);
        expect(copy.submitError, 'erro');
        expect(copy.isSubmitting, isFalse);
      });

      test('substitui isSubmitting', () {
        final copy = MeetingPresenceEditing(
          attendees: [ana],
        ).copyWith(isSubmitting: true);

        expect(copy.isSubmitting, isTrue);
      });

      test('define um novo submitError', () {
        final copy = MeetingPresenceEditing(
          attendees: [ana],
        ).copyWith(submitError: 'novo erro');

        expect(copy.submitError, 'novo erro');
      });

      test('clearSubmitError remove o erro existente', () {
        final copy = MeetingPresenceEditing(
          attendees: [ana],
          submitError: 'erro',
        ).copyWith(clearSubmitError: true);

        expect(copy.submitError, isNull);
      });

      test('clearSubmitError tem prioridade sobre um novo submitError', () {
        final copy = MeetingPresenceEditing(
          attendees: [ana],
          submitError: 'velho',
        ).copyWith(submitError: 'novo', clearSubmitError: true);

        expect(copy.submitError, isNull);
      });
    });
  });

  group('MeetingPresenceClosed', () {
    test('confirmed é false por padrão', () {
      expect(MeetingPresenceClosed([ana]).confirmed, isFalse);
    });

    test('props contém attendees e confirmed', () {
      final state = MeetingPresenceClosed([ana], confirmed: true);

      expect(state.props, [
        [ana],
        true,
      ]);
    });

    test('é igual quando attendees e confirmed são iguais', () {
      expect(
        MeetingPresenceClosed([ana], confirmed: true),
        MeetingPresenceClosed([ana], confirmed: true),
      );
    });

    test('é diferente quando confirmed ou attendees mudam', () {
      final base = MeetingPresenceClosed([ana]);

      expect(base == MeetingPresenceClosed([ana], confirmed: true), isFalse);
      expect(base == MeetingPresenceClosed([ana, bruno]), isFalse);
    });
  });

  test('estados de tipos diferentes nunca são iguais', () {
    expect(
      const MeetingPresenceLoading() == const MeetingPresenceError('x'),
      isFalse,
    );
    expect(
      MeetingPresenceEditing(attendees: [ana]) == MeetingPresenceClosed([ana]),
      isFalse,
    );
  });
}
