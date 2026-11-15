import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';

void main() {
  test('builds the join requests route for the group', () {
    expect(
      GroupJoinRequestsRoutePaths.joinRequestsFor('g 1'),
      '/group-join-requests?group_id=g+1',
    );
  });
}
