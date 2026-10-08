import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/data/models/group_model.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

void main() {
  test('maps a group returned by get-my-groups', () {
    final group = GroupModel.fromJson(const {
      'id': 'group-1',
      'number': 1,
      'participant_count': 3,
      'city_state': 'Porto Alegre, RS',
      'photo_url': 'https://example.com/group.jpg',
    });

    expect(
      group.toDomain(),
      const GroupEntity(
        id: 'group-1',
        number: 1,
        participantsCount: 3,
        cityState: 'Porto Alegre, RS',
        photoUrl: 'https://example.com/group.jpg',
      ),
    );
  });

  test('decodes the groups response', () {
    final groups = GroupModel.listFromJson(const {
      'groups': [
        {
          'id': 'group-1',
          'name': 'Group 1',
          'participant_count': 1,
          'city_state': 'Porto Alegre, RS',
          'photo_url': null,
        },
      ],
    });

    expect(groups, hasLength(1));
    expect(groups.single.id, 'group-1');
  });

  test('maps the next meeting and the pending presence response', () {
    final group = GroupModel.fromJson(const {
      'id': 'group-1',
      'number': 1,
      'participant_count': 3,
      'city_state': 'Porto Alegre, RS',
      'photo_url': null,
      'has_pending_response': true,
      'next_meeting': {
        'id': 'meeting-1',
        'host_name': 'Ana',
        'book_title': 'Quarto de Despejo',
        'date': '2026-10-12T19:00:00Z',
        'location': 'Porto Alegre, RS',
      },
    });

    expect(
      group.toDomain().nextMeeting,
      const GroupMeeting(
        id: 'meeting-1',
        hostName: 'Ana',
        bookTitle: 'Quarto de Despejo',
        date: '2026-10-12T19:00:00Z',
        location: 'Porto Alegre, RS',
      ),
    );
    expect(group.hasPendingResponse, isTrue);
  });
}
