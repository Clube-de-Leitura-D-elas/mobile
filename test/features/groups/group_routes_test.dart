import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    serviceLocator.allowReassignment = true;
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
    serviceLocator.registerFactory<GroupRepository>(() => mockRepository);
  });

  tearDown(() {
    if (serviceLocator.isRegistered<GroupRepository>()) {
      serviceLocator.unregister<GroupRepository>();
    }
  });

  Future<void> pumpRoute(WidgetTester tester, String location) async {
    final router = GoRouter(
      initialLocation: location,
      routes: GroupRoutes.routes,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('builds group details using the group_id query parameter', (
    tester,
  ) async {
    when(() => mockRepository.getGroupDetails('group-1')).thenAnswer(
      (_) async => const Failure(
        FunctionSupabaseFailure(message: 'Not used in this test'),
      ),
    );

    await pumpRoute(tester, '/group-details?group_id=group-1');

    verify(() => mockRepository.getGroupDetails('group-1')).called(1);
    expect(find.text('Not used in this test'), findsOneWidget);
  });

  testWidgets('uses an empty group_id when the query parameter is absent', (
    tester,
  ) async {
    when(() => mockRepository.getGroupDetails('')).thenAnswer(
      (_) async =>
          const Failure(FunctionSupabaseFailure(message: 'Missing group id')),
    );

    await pumpRoute(tester, '/group-details');

    verify(() => mockRepository.getGroupDetails('')).called(1);
    expect(find.text('Missing group id'), findsOneWidget);
  });
}
