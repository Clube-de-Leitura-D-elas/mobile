import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/features/groups/data/group_failure_mapper.dart';
import 'package:mobile/features/groups/domain/entities/group_failure.dart';

void main() {
  const fallback = GroupListFailure();

  test('maps a network failure to GroupNetworkFailure', () {
    expect(
      groupFailureFrom(
        const FunctionSupabaseFailure(
          message: 'raw',
          kind: SupabaseFailureKind.network,
        ),
        fallback,
      ),
      const GroupNetworkFailure(),
    );
  });

  test('maps an unauthorized failure to GroupSessionExpiredFailure', () {
    expect(
      groupFailureFrom(
        const FunctionSupabaseFailure(
          message: 'raw',
          code: '401',
          kind: SupabaseFailureKind.unauthorized,
        ),
        fallback,
      ),
      const GroupSessionExpiredFailure(),
    );
  });

  for (final kind in [
    SupabaseFailureKind.server,
    SupabaseFailureKind.notFound,
    SupabaseFailureKind.conflict,
    SupabaseFailureKind.unknown,
  ]) {
    test('keeps the action failure for $kind', () {
      expect(
        groupFailureFrom(
          FunctionSupabaseFailure(message: 'raw', kind: kind),
          fallback,
        ),
        fallback,
      );
    });
  }
}
