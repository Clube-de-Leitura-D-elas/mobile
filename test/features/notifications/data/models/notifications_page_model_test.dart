import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/models/notification_model.dart';
import 'package:mobile/features/notifications/data/models/notifications_page_model.dart';
import 'package:mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:mobile/features/notifications/domain/entities/notification_type.dart';

Map<String, dynamic> _json({
  String id = 'n1',
  bool isRead = false,
  String? meetingId,
  String? groupId,
}) => {
  'id': id,
  'title': 'Encontro amanhã',
  'message': 'Não esqueça do encontro',
  'type': 'MEETING_REMINDER',
  'date': '2026-11-05T12:30:00+00:00',
  'is_read': isRead,
  'read_at': isRead ? '2026-11-05T13:00:00+00:00' : null,
  'meeting_id': meetingId,
  'group_id': groupId,
};

void main() {
  group('NotificationModel', () {
    test('parses the get-my-notifications item into the entity', () {
      final entity = NotificationModel.fromJson(
        _json(isRead: true, meetingId: 'm1', groupId: 'g1'),
      ).toDomain();

      expect(
        entity,
        NotificationEntity(
          id: 'n1',
          title: 'Encontro amanhã',
          message: 'Não esqueça do encontro',
          type: NotificationType.meetingReminder,
          date: DateTime.utc(2026, 11, 5, 12, 30),
          isRead: true,
          meetingId: 'm1',
          groupId: 'g1',
        ),
      );
    });

    const backendTypes = {
      'BIRTHDAY': NotificationType.birthday,
      'BOOK_SUGGESTIONS_REMINDER': NotificationType.bookSuggestionsReminder,
      'COORDINATOR_TASKS_REMINDER': NotificationType.coordinatorTasksReminder,
      'HOST_TASKS_REMINDER': NotificationType.hostTasksReminder,
      'MEETING_REMINDER': NotificationType.meetingReminder,
      'MEETING_SCHEDULE_PENDING': NotificationType.meetingSchedulePending,
      'MEETING_UPDATED': NotificationType.meetingUpdated,
      'DRAW_RESULT': NotificationType.drawResult,
      'GROUP_JOIN_REQUESTED': NotificationType.groupJoinRequested,
      'GROUP_JOIN_APPROVED': NotificationType.groupJoinApproved,
      'GROUP_JOIN_REJECTED': NotificationType.groupJoinRejected,
    };

    backendTypes.forEach((value, type) {
      test('parses the backend type $value', () {
        final entity = NotificationModel.fromJson({
          ..._json(),
          'type': value,
        }).toDomain();

        expect(entity.type, type);
      });
    });

    test('maps an unknown type and accepts missing destinations', () {
      final entity = NotificationModel.fromJson({
        ..._json(),
        'type': 'TYPE_FROM_THE_FUTURE',
      }).toDomain();

      expect(entity.type, NotificationType.unknown);
      expect(entity.meetingId, isNull);
      expect(entity.groupId, isNull);
    });
  });

  group('NotificationsPageModel', () {
    test('reads items, total and unread_count', () {
      final page = NotificationsPageModel.fromJson({
        'notifications': [_json(id: 'n1'), _json(id: 'n2', isRead: true)],
        'total': 45,
        'unread_count': 12,
      }).toDomain();

      expect(page.items.map((item) => item.id), ['n1', 'n2']);
      expect(page.total, 45);
      expect(page.unreadCount, 12);
    });

    test('counts the unread items of the page without unread_count', () {
      final page = NotificationsPageModel.fromJson({
        'notifications': [
          _json(id: 'n1'),
          _json(id: 'n2'),
          _json(id: 'n3', isRead: true),
        ],
        'total': 3,
      }).toDomain();

      expect(page.unreadCount, 2);
    });
  });
}
