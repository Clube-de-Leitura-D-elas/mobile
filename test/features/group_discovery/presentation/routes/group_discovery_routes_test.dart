import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/pages/public_group_page.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

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
}
