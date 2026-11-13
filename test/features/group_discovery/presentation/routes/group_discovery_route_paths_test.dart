import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';

import '../../group_discovery_fixtures.dart';

void main() {
  test('builds the public group path with the group id', () {
    expect(
      GroupDiscoveryRoutePaths.publicGroupFor('abc'),
      '/group-public?group_id=abc',
    );
  });

  test('a member goes to the member group details', () {
    expect(
      GroupDiscoveryRoutePaths.detailsFor(
        discoveryGroup(membership: GroupMembershipStatus.member),
      ),
      '/group-details?group_id=$groupId',
    );
  });

  for (final status in GroupMembershipStatus.values.where(
    (status) => status != GroupMembershipStatus.member,
  )) {
    test('a ${status.name} reader goes to the public group page', () {
      expect(
        GroupDiscoveryRoutePaths.detailsFor(discoveryGroup(membership: status)),
        '/group-public?group_id=$groupId',
      );
    });
  }
}
