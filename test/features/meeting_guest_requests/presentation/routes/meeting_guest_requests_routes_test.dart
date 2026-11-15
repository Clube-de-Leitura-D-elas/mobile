import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/meeting_guest_requests/domain/repository/meeting_guest_requests_repository.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/pages/meeting_guest_requests_page.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/routes/meeting_guest_requests_route_paths.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/routes/meeting_guest_requests_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../meeting_guest_requests_fixtures.dart';

class MockMeetingGuestRequestsRepository extends Mock
    implements MeetingGuestRequestsRepository {}

void main() {
  late MockMeetingGuestRequestsRepository repository;

  setUp(() {
    repository = MockMeetingGuestRequestsRepository();
    final allowReassignment = serviceLocator.allowReassignment;
    serviceLocator.allowReassignment = true;
    serviceLocator.registerFactory<MeetingGuestRequestsCubit>(
      () => MeetingGuestRequestsCubit(repository: repository),
    );
    addTearDown(() {
      serviceLocator.unregister<MeetingGuestRequestsCubit>();
      serviceLocator.allowReassignment = allowReassignment;
    });
  });

  Future<void> pumpRoute(WidgetTester tester, String location) async {
    final router = GoRouter(
      initialLocation: location,
      routes: MeetingGuestRequestsRoutes.routes,
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

  testWidgets('loads the requests of the meeting in the link', (tester) async {
    when(
      () => repository.getRequests(meetingId),
    ).thenAnswer((_) async => Success([anaRequest]));

    await pumpRoute(
      tester,
      MeetingGuestRequestsRoutePaths.guestRequestsFor(meetingId),
    );

    expect(find.byType(MeetingGuestRequestsPage), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);
    verify(() => repository.getRequests(meetingId)).called(1);
  });

  testWidgets('a link without meeting_id shows the unavailable meeting', (
    tester,
  ) async {
    await pumpRoute(tester, MeetingGuestRequestsRoutes.guestRequests);

    expect(find.byType(MeetingGuestRequestsPage), findsOneWidget);
    expect(find.text('Este encontro não está disponível.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsNothing);
    verifyNever(() => repository.getRequests(any()));
  });
}
