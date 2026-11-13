import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';

const groupId = '11111111-1111-1111-1111-111111111111';

DiscoveryGroupEntity discoveryGroup({
  GroupMembershipStatus membership = GroupMembershipStatus.none,
  String? cityState = 'Porto Alegre, RS',
  String description = 'Leituras de ficção contemporânea.',
  List<String> genres = const ['Ficção', 'Aventura'],
}) {
  return DiscoveryGroupEntity(
    id: groupId,
    number: 1,
    description: description,
    cityState: cityState,
    genres: genres,
    participantCount: 34,
    membershipStatus: membership,
  );
}

Map<String, dynamic> discoveryGroupJson({
  Object? membershipStatus,
  Object? cityState = 'Porto Alegre, RS',
  Object? photoUrl = 'https://example.com/g1.png',
}) => {
  'id': groupId,
  'number': 1,
  'description': 'Leituras de ficção contemporânea.',
  'city_state': cityState,
  'photo_url': photoUrl,
  'genres': [
    {'id': 'g-1', 'name': 'Ficção'},
    {'id': 'g-2', 'name': 'Aventura'},
  ],
  'participant_count': 34,
  'membership_status': membershipStatus,
};

/// Id determinístico do grupo [number] da lista.
String searchGroupId(int number) =>
    '00000000-0000-0000-0000-${number.toString().padLeft(12, '0')}';

/// Grupo [number] da busca, com id e número próprios.
DiscoveryGroupEntity searchGroup(
  int number, {
  GroupMembershipStatus membership = GroupMembershipStatus.none,
  String? cityState = 'Porto Alegre, RS',
}) {
  return DiscoveryGroupEntity(
    id: searchGroupId(number),
    number: number,
    description: '',
    cityState: cityState,
    genres: const [],
    participantCount: 30 + number,
    membershipStatus: membership,
  );
}
