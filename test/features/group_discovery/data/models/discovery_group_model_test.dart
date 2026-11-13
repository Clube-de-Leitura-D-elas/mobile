import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/group_discovery/data/models/discovery_group_model.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';

import '../../group_discovery_fixtures.dart';

void main() {
  group('DiscoveryGroupModel', () {
    test('parses a get-city-groups item into the entity', () {
      final entity = DiscoveryGroupModel.fromJson(
        discoveryGroupJson(membershipStatus: 'REQUESTED'),
      ).toDomain();

      expect(
        entity,
        const DiscoveryGroupEntity(
          id: groupId,
          number: 1,
          description: 'Leituras de ficção contemporânea.',
          cityState: 'Porto Alegre, RS',
          photoUrl: 'https://example.com/g1.png',
          genres: ['Ficção', 'Aventura'],
          participantCount: 34,
          membershipStatus: GroupMembershipStatus.requested,
        ),
      );
    });

    test('parses the null and empty fields', () {
      final entity = DiscoveryGroupModel.fromJson({
        ...discoveryGroupJson(cityState: '', photoUrl: null),
        'description': null,
        'genres': <dynamic>[],
      }).toDomain();

      expect(entity.cityState, isNull);
      expect(entity.photoUrl, isNull);
      expect(entity.description, isEmpty);
      expect(entity.genres, isEmpty);
      expect(entity.membershipStatus, GroupMembershipStatus.none);
      expect(entity.canRequestJoin, isTrue);
    });

    final statuses = <Object?, GroupMembershipStatus>{
      'MEMBER': GroupMembershipStatus.member,
      'REQUESTED': GroupMembershipStatus.requested,
      'REJECTED': GroupMembershipStatus.rejected,
      'PENDING': GroupMembershipStatus.pending,
      null: GroupMembershipStatus.none,
      'SOMETHING_NEW': GroupMembershipStatus.none,
    };
    for (final MapEntry(key: raw, value: status) in statuses.entries) {
      test('maps membership_status $raw', () {
        final entity = DiscoveryGroupModel.fromJson(
          discoveryGroupJson(membershipStatus: raw),
        ).toDomain();

        expect(entity.membershipStatus, status);
        expect(
          entity.canRequestJoin,
          status == GroupMembershipStatus.none ||
              status == GroupMembershipStatus.rejected,
        );
      });
    }

    test('reads the items of the response, empty included', () {
      expect(
        DiscoveryGroupModel.listFromJson({
          'items': [discoveryGroupJson()],
          'total': 1,
          'genres': <dynamic>[],
        }).single.id,
        groupId,
      );
      expect(
        DiscoveryGroupModel.listFromJson({
          'items': <dynamic>[],
          'total': 0,
          'genres': <dynamic>[],
        }),
        isEmpty,
      );
    });
  });
}
