import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';

abstract final class MockGroups {
  static const List<GroupEntity> defaultGroups = [
    GroupEntity(
      id: '1',
      name: 'Grupo 1',
      participantsCount: 32,
      cityState: 'Porto Alegre, RS',
      nextMeeting: GroupMeeting(
        hostName: 'Roberta',
        bookTitle: 'Pequeno príncipe',
        date: '29/08/2026',
        location: 'Z Café TECNOPUC',
      ),
      hasPendingResponse: true,
    ),
    GroupEntity(
      id: '27',
      name: 'Grupo 27',
      participantsCount: 18,
      cityState: 'Porto Alegre, RS',
      nextMeeting: GroupMeeting(
        hostName: 'Roberta',
        bookTitle: 'Pequeno príncipe',
        date: '29/08/2026',
        location: 'Z Café TECNOPUC',
      ),
      hasPendingResponse: true,
    ),
    GroupEntity(
      id: '12',
      name: 'Grupo 12',
      participantsCount: 25,
      cityState: 'Porto Alegre, RS',
      nextMeeting: GroupMeeting(
        hostName: 'Roberta',
        bookTitle: 'Pequeno príncipe',
        date: '29/08/2026',
        location: 'Z Café TECNOPUC',
      ),
      hasPendingResponse: true,
    ),
  ];
}
