import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/data/models/discovery_group_model.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/pages/public_group_page.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../group_discovery_fixtures.dart';

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

void main() {
  late MockGroupDiscoveryRepository repository;

  setUp(() {
    repository = MockGroupDiscoveryRepository();
    final allowReassignment = serviceLocator.allowReassignment;
    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<PublicGroupCubit>(
      () => PublicGroupCubit(repository: repository),
    );
    addTearDown(() {
      serviceLocator.unregister<PublicGroupCubit>();
      serviceLocator.allowReassignment = allowReassignment;
    });
  });

  testWidgets('a link without group_id shows the unavailable group', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: GroupDiscoveryRoutes.publicGroup,
      routes: GroupDiscoveryRoutes.routes,
    );

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

    expect(find.byType(PublicGroupPage), findsOneWidget);
    expect(find.text('Este grupo não está disponível.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
    verifyNever(() => repository.getGroup(any()));
  });

  testWidgets('switching group_id on the same route loads the new group', (
    tester,
  ) async {
    const otherId = '22222222-2222-2222-2222-222222222222';
    when(() => repository.getGroup(groupId)).thenAnswer(
      (_) async => Success(
        DiscoveryGroupModel.fromJson(discoveryGroupJson()).toDomain(),
      ),
    );
    when(() => repository.getGroup(otherId)).thenAnswer(
      (_) async => Success(
        DiscoveryGroupModel.fromJson({
          ...discoveryGroupJson(),
          'id': otherId,
          'number': 7,
        }).toDomain(),
      ),
    );
    final router = GoRouter(
      initialLocation: '${GroupDiscoveryRoutes.publicGroup}?group_id=$groupId',
      routes: GroupDiscoveryRoutes.routes,
    );

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
    expect(find.text('Grupo 1'), findsOneWidget);

    router.go('${GroupDiscoveryRoutes.publicGroup}?group_id=$otherId');
    await tester.pumpAndSettle();

    expect(find.text('Grupo 7'), findsOneWidget);
    verify(() => repository.getGroup(otherId)).called(1);
  });
}
