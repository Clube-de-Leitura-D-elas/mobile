import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

void main() {
  group('GroupMeeting', () {
    test('stores all meeting details', () {
      const meeting = GroupMeeting(
        hostName: 'Ana Souza',
        bookTitle: 'Quarto de Despejo',
        date: '28 de setembro',
        location: 'Biblioteca Municipal',
      );

      expect(meeting.hostName, 'Ana Souza');
      expect(meeting.bookTitle, 'Quarto de Despejo');
      expect(meeting.date, '28 de setembro');
      expect(meeting.location, 'Biblioteca Municipal');
    });
  });
}
