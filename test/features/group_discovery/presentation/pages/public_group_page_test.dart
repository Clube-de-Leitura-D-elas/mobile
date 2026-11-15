import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/public_group_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/pages/public_group_page.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/join_request_dialog.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../group_discovery_fixtures.dart';

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockGroupDiscoveryRepository repository;
  late MockSessionCubit sessionCubit;

  setUp(() {
    repository = MockGroupDiscoveryRepository();
    sessionCubit = MockSessionCubit();
    when(() => sessionCubit.state).thenReturn(const GuestSession());
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
  });

  tearDown(AppToast.dismiss);

  void stubGroup(Result<DiscoveryGroupEntity, GroupDiscoveryFailure> result) {
    when(() => repository.getGroup(groupId)).thenAnswer((_) async => result);
  }

  /// Abre a tela empilhada sobre uma rota inicial, como vinda do calendário.
  Future<GoRouter> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/inicio',
      routes: [
        GoRoute(path: '/inicio', builder: (_, _) => const Text('início')),
        GoRoute(
          path: GroupDiscoveryRoutePaths.publicGroup,
          builder: (_, state) => BlocProvider(
            create: (_) =>
                PublicGroupCubit(repository: repository)
                  ..load(state.uri.queryParameters['group_id']!),
            child: const PublicGroupPage(),
          ),
        ),
        GoRoute(
          path: GroupRoutePaths.groupDetails,
          builder: (_, state) => Text('destino: ${state.uri}'),
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt', 'BR'),
          routerConfig: router,
        ),
      ),
    );
    unawaited(router.push(GroupDiscoveryRoutePaths.publicGroupFor(groupId)));
    await tester.pump();
    return router;
  }

  Future<void> confirmJoin(WidgetTester tester, String button) async {
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Solicitar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('loaded group', () {
    testWidgets('shows the name, genres, participants, city and description', (
      tester,
    ) async {
      stubGroup(Success(discoveryGroup()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Grupo 1'), findsOneWidget);
      expect(find.text('Ficção'), findsOneWidget);
      expect(find.text('Aventura'), findsOneWidget);
      expect(find.text('34 participantes'), findsOneWidget);
      expect(find.text('Porto Alegre, RS'), findsOneWidget);
      expect(find.text('Leituras de ficção contemporânea.'), findsOneWidget);
      expect(find.byTooltip('Voltar'), findsOneWidget);
    });

    testWidgets('hides the city line when there is no city', (tester) async {
      stubGroup(Success(discoveryGroup(cityState: null)));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('34 participantes'), findsOneWidget);
      expect(find.text('Porto Alegre, RS'), findsNothing);
    });

    final byStatus = <GroupMembershipStatus, (String?, String?)>{
      GroupMembershipStatus.none: (null, 'Solicitar entrada'),
      GroupMembershipStatus.requested: ('Aguardando aprovação', null),
      GroupMembershipStatus.rejected: (
        'Solicitação recusada',
        'Pedir novamente',
      ),
      GroupMembershipStatus.pending: ('Aguardando criação de conta', null),
      GroupMembershipStatus.member: (
        'Você já faz parte deste grupo',
        'Ver grupo',
      ),
    };
    for (final MapEntry(key: status, value: (indicator, button))
        in byStatus.entries) {
      testWidgets('shows the right status and action for ${status.name}', (
        tester,
      ) async {
        stubGroup(Success(discoveryGroup(membership: status)));

        await pumpPage(tester);
        await tester.pumpAndSettle();

        final buttons = tester.widgetList<AppButton>(find.byType(AppButton));
        expect(buttons.map((button) => button.label), [?button]);
        if (indicator != null) {
          expect(find.text(indicator), findsOneWidget);
        }
        for (final other in byStatus.values) {
          final otherIndicator = other.$1;
          if (otherIndicator != null && otherIndicator != indicator) {
            expect(find.text(otherIndicator), findsNothing);
          }
        }
      });
    }

    testWidgets('a member swaps this page for the full group details', (
      tester,
    ) async {
      stubGroup(
        Success(discoveryGroup(membership: GroupMembershipStatus.member)),
      );

      final router = await pumpPage(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver grupo'));
      await tester.pumpAndSettle();

      expect(
        find.text('destino: /group-details?group_id=$groupId'),
        findsOneWidget,
      );

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('início'), findsOneWidget);
      expect(find.byType(PublicGroupPage), findsNothing);
    });
  });

  group('join request', () {
    setUp(() => stubGroup(Success(discoveryGroup())));

    testWidgets('cancelling the confirmation does not ask', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Solicitar entrada'));
      await tester.pumpAndSettle();

      expect(find.byType(JoinRequestDialog), findsOneWidget);
      expect(
        find.text('A coordenação do Grupo 1 vai analisar o seu pedido.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(JoinRequestDialog), findsNothing);
      verifyNever(() => repository.requestJoin(any()));
    });

    testWidgets('confirming asks, shows the toast and the waiting status', (
      tester,
    ) async {
      when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) async => const Success(null));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Solicitar entrada'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => repository.requestJoin(groupId)).called(1);
      expect(
        find.text('Pedido enviado! Agora é só aguardar a aprovação.'),
        findsOneWidget,
      );
      expect(find.text('Aguardando aprovação'), findsOneWidget);
      expect(find.text('Solicitar entrada'), findsNothing);
    });

    testWidgets('an already requested answer warns and reloads the status', (
      tester,
    ) async {
      when(() => repository.requestJoin(groupId)).thenAnswer(
        (_) async => const Failure(GroupJoinAlreadyRequestedFailure()),
      );

      await pumpPage(tester);
      await tester.pumpAndSettle();

      stubGroup(
        Success(discoveryGroup(membership: GroupMembershipStatus.requested)),
      );
      await tester.tap(find.text('Solicitar entrada'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Você já pediu entrada ou já faz parte deste grupo.'),
        findsOneWidget,
      );
      expect(find.text('Aguardando aprovação'), findsOneWidget);
      verify(() => repository.getGroup(groupId)).called(2);
    });

    testWidgets('asks again after a rejection, end to end', (tester) async {
      stubGroup(
        Success(discoveryGroup(membership: GroupMembershipStatus.rejected)),
      );
      when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) async => const Success(null));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      expect(find.text('Solicitação recusada'), findsOneWidget);

      await confirmJoin(tester, 'Pedir novamente');

      verify(() => repository.requestJoin(groupId)).called(1);
      expect(find.text('Aguardando aprovação'), findsOneWidget);
      expect(find.text('Solicitação recusada'), findsNothing);
      expect(find.text('Pedir novamente'), findsNothing);
    });

    testWidgets('the button is busy while the request runs', (tester) async {
      final pending = Completer<Result<void, GroupDiscoveryFailure>>();
      when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) => pending.future);

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await confirmJoin(tester, 'Solicitar entrada');

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.isLoading, isTrue);

      // O spinner do botão não para de animar: sem pumpAndSettle.
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(JoinRequestDialog), findsNothing);
      verify(() => repository.requestJoin(groupId)).called(1);

      pending.complete(const Success(null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    final toastByFailure = <GroupDiscoveryFailure, String>{
      const GroupDiscoveryNetworkFailure():
          'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
      const GroupDiscoverySessionExpiredFailure():
          'Sua sessão expirou. Saia do app e entre de novo na sua conta.',
      const GroupDiscoveryInactiveAccountFailure():
          'Você não tem permissão para fazer isso.',
      const GroupDiscoveryServerFailure():
          'Não foi possível enviar o pedido. Tente novamente.',
    };
    for (final MapEntry(key: failure, value: message)
        in toastByFailure.entries) {
      testWidgets('warns ${failure.runtimeType} and keeps the button', (
        tester,
      ) async {
        when(
          () => repository.requestJoin(groupId),
        ).thenAnswer((_) async => Failure(failure));

        await pumpPage(tester);
        await tester.pumpAndSettle();
        await confirmJoin(tester, 'Solicitar entrada');

        expect(find.text(message), findsOneWidget);
        expect(find.text('Solicitar entrada'), findsOneWidget);
      });
    }

    testWidgets('a group without coordinator gets its own message', (
      tester,
    ) async {
      when(
        () => repository.requestJoin(groupId),
      ).thenAnswer((_) async => const Failure(GroupJoinNoCoordinatorFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar entrada'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Este grupo ainda não aceita pedidos de entrada.'),
        findsOneWidget,
      );
      expect(find.text('Solicitar entrada'), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('shows the progress while loading, with a way back', (
      tester,
    ) async {
      final pending =
          Completer<Result<DiscoveryGroupEntity, GroupDiscoveryFailure>>();
      when(
        () => repository.getGroup(groupId),
      ).thenAnswer((_) => pending.future);

      await pumpPage(tester);
      await tester.pump();

      expect(find.bySemanticsLabel('Carregando grupo'), findsOneWidget);
      expect(find.text('Detalhes do grupo'), findsOneWidget);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('início'), findsOneWidget);
      pending.complete(const Failure(GroupDiscoveryServerFailure()));
    });

    testWidgets('the error page goes back too', (tester) async {
      stubGroup(const Failure(GroupDiscoveryServerFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('início'), findsOneWidget);
    });

    testWidgets('shows the unavailable group without retry', (tester) async {
      stubGroup(const Failure(GroupUnavailableFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Este grupo não está disponível.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('shows the error and reloads on retry', (tester) async {
      stubGroup(const Failure(GroupDiscoveryServerFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar o grupo.'), findsOneWidget);

      stubGroup(Success(discoveryGroup()));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Grupo 1'), findsOneWidget);
    });

    testWidgets('offers logout when the session expired', (tester) async {
      stubGroup(const Failure(GroupDiscoverySessionExpiredFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));

      verify(() => sessionCubit.logOut()).called(1);
    });

    testWidgets('does not offer retry to an inactive account', (tester) async {
      stubGroup(const Failure(GroupDiscoveryInactiveAccountFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Você não tem permissão para fazer isso.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsNothing);
    });
  });
}
