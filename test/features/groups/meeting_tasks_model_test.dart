import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/meeting_tasks_model.dart';
import 'package:mobile/features/groups/domain/entities/meeting_tasks_entity.dart';

void main() {
  group('MeetingTasksModel.fromJson', () {
    test('parses the full contract', () {
      final model = MeetingTasksModel.fromJson(const {
        'meeting_id': 'meeting-1',
        'status': 'SCHEDULED',
        'can_manage_tasks': true,
        'can_conclude': false,
        'book_title': 'A Hora da Estrela',
        'book_author': 'Clarice Lispector',
        'group_name': 'Grupo 12',
        'tasks': {
          'schedule': {
            'done': true,
            'date': '2026-08-22T18:00:00Z',
            'location': 'Rua Harmonia, 512',
          },
          'record': {'status': 'LOCKED'},
        },
      });

      expect(model.meetingId, 'meeting-1');
      expect(model.status, MeetingTaskStatus.scheduled);
      expect(model.canManageTasks, isTrue);
      expect(model.canConclude, isFalse);
      expect(model.bookTitle, 'A Hora da Estrela');
      expect(model.bookAuthor, 'Clarice Lispector');
      expect(model.groupName, 'Grupo 12');
      expect(
        model.schedule,
        MeetingScheduleTask(
          done: true,
          date: DateTime.utc(2026, 8, 22, 18),
          location: 'Rua Harmonia, 512',
        ),
      );
      expect(model.record.status, MeetingRecordStatus.locked);
      expect(model.isPublished, isTrue);
      expect(model.completedTasks, 1);
      expect(model.pendingTasks, 1);
    });

    test('maps every meeting and record status', () {
      MeetingTasksModel parse(String status, String record) =>
          MeetingTasksModel.fromJson({
            'meeting_id': 'm',
            'status': status,
            'can_manage_tasks': true,
            'tasks': {
              'schedule': const {'done': false},
              'record': {'status': record},
            },
          });

      expect(parse('CREATED', 'LOCKED').status, MeetingTaskStatus.created);
      expect(
        parse('IN_PROGRESS', 'LOCKED').status,
        MeetingTaskStatus.inProgress,
      );
      expect(parse('ENDED', 'PENDING').status, MeetingTaskStatus.ended);
      expect(parse('ENDED', 'PENDING').hasEnded, isTrue);
      expect(parse('CONCLUDED', 'PENDING').status, MeetingTaskStatus.concluded);
      expect(
        parse('CONCLUDED', 'PENDING').record.status,
        MeetingRecordStatus.pending,
      );
      expect(
        parse('CONCLUDED', 'DRAFT').record.status,
        MeetingRecordStatus.draft,
      );
      final published = parse('CONCLUDED', 'PUBLISHED');
      expect(published.record.status, MeetingRecordStatus.published);
      expect(published.record.done, isTrue);
      expect(published.isConcluded, isTrue);
    });

    test('falls back when tasks and optional fields are missing', () {
      final model = MeetingTasksModel.fromJson(const {
        'meeting_id': 'm',
        'status': 'CREATED',
        'can_manage_tasks': true,
        'book_title': '  ',
      });

      expect(model.canConclude, isFalse);
      expect(model.schedule.done, isFalse);
      expect(model.record.status, MeetingRecordStatus.locked);
      expect(model.bookTitle, isNull);
      expect(model.isPublished, isFalse);
      expect(model.pendingTasks, 2);
    });

    test('throws on invalid payloads', () {
      expect(() => MeetingTasksModel.fromJson(null), throwsFormatException);
      expect(
        () => MeetingTasksModel.fromJson(const {'status': 'CREATED'}),
        throwsFormatException,
      );
      expect(
        () => MeetingTasksModel.fromJson(const {
          'meeting_id': 'm',
          'can_manage_tasks': true,
          'tasks': {
            'schedule': {'done': true, 'date': 'not-a-date'},
          },
        }),
        throwsFormatException,
      );
    });
  });
}
