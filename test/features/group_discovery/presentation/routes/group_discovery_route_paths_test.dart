import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';

void main() {
  test('builds the public group path with the group id', () {
    expect(
      GroupDiscoveryRoutePaths.publicGroupFor('abc'),
      '/group-public?group_id=abc',
    );
  });
}
