import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_join_requests/domain/repository/group_join_requests_repository.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_cubit.dart';
import 'package:mobile/features/group_join_requests/presentation/pages/group_join_requests_page.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../group_join_requests_fixtures.dart';

class MockGroupJoinRequestsRepository extends Mock
    implements GroupJoinRequestsRepository {}

void main() {
  late MockGroupJoinRequestsRepository repository;

  setUp(() {
    repository = MockGroupJoinRequestsRepository();
    final allowReassignment = serviceLocator.allowReassignment;
    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<GroupJoinRequestsCubit>(
      () => GroupJoinRequestsCubit(repository: repository),
    );
    addTearDown(() {
      serviceLocator.unregister<GroupJoinRequestsCubit>();
      serviceLocator.allowReassignment = allowReassignment;
    });
  });

  Future<void> pumpRoute(WidgetTester tester, String location) async {
    final router = GoRouter(
      initialLocation: location,
      routes: GroupJoinRequestsRoutes.routes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads the requests of the group in the link', (tester) async {
    when(
      () => repository.getRequests(groupId),
    ).thenAnswer((_) async => Success([anaRequest]));

    await pumpRoute(
      tester,
      GroupJoinRequestsRoutePaths.joinRequestsFor(groupId),
    );

    expect(find.byType(GroupJoinRequestsPage), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);
    verify(() => repository.getRequests(groupId)).called(1);
  });

  testWidgets('a link without group_id shows the unavailable group', (
    tester,
  ) async {
    await pumpRoute(tester, GroupJoinRequestsRoutes.joinRequests);

    expect(find.byType(GroupJoinRequestsPage), findsOneWidget);
    expect(find.text('Este grupo não está disponível.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
    verifyNever(() => repository.getRequests(any()));
  });
}
