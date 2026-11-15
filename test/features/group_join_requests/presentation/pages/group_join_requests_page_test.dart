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
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';
import 'package:mobile/features/group_join_requests/domain/repository/group_join_requests_repository.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_cubit.dart';
import 'package:mobile/features/group_join_requests/presentation/pages/group_join_requests_page.dart';
import 'package:mobile/features/group_join_requests/presentation/routes/group_join_requests_route_paths.dart';
import 'package:mobile/features/group_join_requests/presentation/widgets/review_join_request_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../group_join_requests_fixtures.dart';

class MockGroupJoinRequestsRepository extends Mock
    implements GroupJoinRequestsRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockGroupJoinRequestsRepository repository;
  late MockSessionCubit sessionCubit;

  setUpAll(() {
    registerFallbackValue(JoinRequestDecision.approve);
  });

  setUp(() {
    repository = MockGroupJoinRequestsRepository();
    sessionCubit = MockSessionCubit();
    when(() => sessionCubit.state).thenReturn(const GuestSession());
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
  });

  tearDown(AppToast.dismiss);

  void stubRequests(
    Result<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure> result,
  ) {
    when(() => repository.getRequests(groupId)).thenAnswer((_) async => result);
  }

  void stubReview(
    JoinRequestDecision decision,
    Result<void, GroupJoinRequestsFailure> result,
  ) {
    when(
      () => repository.review(requestId: anaRequestId, decision: decision),
    ).thenAnswer((_) async => result);
  }

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/inicio',
      routes: [
        GoRoute(path: '/inicio', builder: (_, _) => const Text('início')),
        GoRoute(
          path: GroupJoinRequestsRoutePaths.joinRequests,
          builder: (_, state) => BlocProvider(
            create: (_) =>
                GroupJoinRequestsCubit(repository: repository)
                  ..load(state.uri.queryParameters['group_id']!),
            child: const GroupJoinRequestsPage(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

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
    unawaited(
      router.push(GroupJoinRequestsRoutePaths.joinRequestsFor(groupId)),
    );
    await tester.pump();
  }

  /// Toca na ação do pedido e responde a confirmação.
  Future<void> decide(
    WidgetTester tester,
    String action, {
    bool confirm = true,
  }) async {
    await tester.tap(find.text(action).first);
    await tester.pumpAndSettle();
    final dialog = find.byType(ReviewJoinRequestDialog);
    await tester.tap(
      find.descendant(
        of: dialog,
        matching: find.text(confirm ? action : 'Cancelar'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('states', () {
    testWidgets('shows a progress while loading', (tester) async {
      final response =
          Completer<
            Result<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure>
          >();
      when(
        () => repository.getRequests(groupId),
      ).thenAnswer((_) => response.future);

      await pumpPage(tester);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Pedidos de entrada'), findsOneWidget);
      expect(find.bySemanticsLabel('Carregando pedidos de entrada'), findsOne);

      response.complete(const Success([]));
      await tester.pumpAndSettle();
    });

    testWidgets('lists photo, name and the São Paulo request date', (
      tester,
    ) async {
      stubRequests(Success([anaRequest, biaRequest]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('Pedido em 13/11/2026 às 09:30'), findsOneWidget);
      expect(find.text('Bia Lima'), findsOneWidget);
      // Bia não tem data: só a linha da Ana aparece.
      expect(find.textContaining('Pedido em'), findsOneWidget);
      expect(find.text('Aceitar'), findsNWidgets(2));
      expect(find.text('Recusar'), findsNWidgets(2));
      expect(
        find.bySemanticsLabel('Ana Souza, Pedido em 13/11/2026 às 09:30'),
        findsOneWidget,
      );
    });

    testWidgets('the actions name the reader for screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      stubRequests(Success([anaRequest, biaRequest]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      for (final label in [
        'Aceitar pedido de Ana Souza',
        'Recusar pedido de Ana Souza',
        'Aceitar pedido de Bia Lima',
        'Recusar pedido de Bia Lima',
      ]) {
        expect(
          tester.getSemantics(find.bySemanticsLabel(label)),
          isSemantics(
            label: label,
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
          ),
        );
      }
      expect(find.bySemanticsLabel('Aceitar'), findsNothing);
      semantics.dispose();
    });

    testWidgets('the semantic action opens the confirmation', (tester) async {
      final semantics = tester.ensureSemantics();
      stubRequests(Success([anaRequest]));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      tester.semantics.tap(
        find.semantics.byLabel('Recusar pedido de Ana Souza'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recusar pedido?'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('the actions have a 48px touch target', (tester) async {
      stubRequests(Success([anaRequest]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      for (final label in ['Aceitar', 'Recusar']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(AppButton),
        );
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('keeps the end of the list above the system bar', (
      tester,
    ) async {
      stubRequests(Success([anaRequest]));
      tester.view.padding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.resetPadding);

      await pumpPage(tester);
      await tester.pumpAndSettle();

      final padding = tester.widget<ListView>(find.byType(ListView)).padding;
      expect(padding?.resolve(TextDirection.ltr).bottom, 24 + 34);
    });

    testWidgets('shows the empty state', (tester) async {
      stubRequests(const Success([]));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Nenhum pedido de entrada'), findsOneWidget);
      expect(find.text('Aceitar'), findsNothing);
    });

    testWidgets('shows the error and retries', (tester) async {
      stubRequests(const Failure(GroupJoinRequestsNetworkFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
        ),
        findsOneWidget,
      );

      stubRequests(Success([anaRequest]));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Souza'), findsOneWidget);
      verify(() => repository.getRequests(groupId)).called(2);
    });

    testWidgets('a server error shows the generic message', (tester) async {
      stubRequests(const Failure(GroupJoinRequestsServerFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível carregar os pedidos de entrada.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.text('Sair'), findsNothing);
    });

    testWidgets('an expired session offers to log out', (tester) async {
      stubRequests(const Failure(GroupJoinRequestsSessionExpiredFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Sua sessão expirou. Saia do app e entre de novo na sua conta.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Sair'));

      verify(() => sessionCubit.logOut()).called(1);
    });

    testWidgets('a reader who is not coordinator cannot retry', (tester) async {
      stubRequests(const Failure(GroupJoinRequestsNotCoordinatorFailure()));

      await pumpPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Só a coordenação do grupo pode ver os pedidos de entrada.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsNothing);
    });
  });

  group('review', () {
    setUp(() => stubRequests(Success([anaRequest, biaRequest])));

    testWidgets('the confirmation buttons have a 48px touch target', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      for (final action in ['Aceitar', 'Recusar']) {
        await tester.tap(find.text(action).first);
        await tester.pumpAndSettle();
        final dialog = find.byType(ReviewJoinRequestDialog);
        final buttons = find.descendant(
          of: dialog,
          matching: find.byType(AppButton),
        );
        expect(buttons, findsNWidgets(2));
        for (final button in buttons.evaluate()) {
          expect(
            tester.getSize(find.byWidget(button.widget)).height,
            greaterThanOrEqualTo(48),
          );
        }
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('cancelling the confirmation does not decide', (tester) async {
      await pumpPage(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aceitar').first);
      await tester.pumpAndSettle();

      expect(find.text('Aceitar pedido?'), findsOneWidget);
      expect(
        find.text('Ana Souza vai passar a fazer parte do grupo.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewJoinRequestDialog), findsNothing);
      expect(find.text('Ana Souza'), findsOneWidget);
      verifyNever(
        () => repository.review(
          requestId: any(named: 'requestId'),
          decision: any(named: 'decision'),
        ),
      );
    });

    testWidgets('accepting removes the request and shows the toast', (
      tester,
    ) async {
      stubReview(JoinRequestDecision.approve, const Success(null));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await decide(tester, 'Aceitar');

      verify(
        () => repository.review(
          requestId: anaRequestId,
          decision: JoinRequestDecision.approve,
        ),
      ).called(1);
      expect(find.text('Ana Souza'), findsNothing);
      expect(find.text('Bia Lima'), findsOneWidget);
      expect(
        find.text('Pedido aceito! A leitora já faz parte do grupo.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'rejecting asks first, removes the request and shows the toast',
      (tester) async {
        stubReview(JoinRequestDecision.reject, const Success(null));

        await pumpPage(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Recusar').first);
        await tester.pumpAndSettle();

        expect(find.text('Recusar pedido?'), findsOneWidget);
        expect(
          find.text(
            'Ana Souza não vai entrar no grupo agora, mas poderá pedir de novo.',
          ),
          findsOneWidget,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(ReviewJoinRequestDialog),
            matching: find.text('Recusar'),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        verify(
          () => repository.review(
            requestId: anaRequestId,
            decision: JoinRequestDecision.reject,
          ),
        ).called(1);
        expect(find.text('Ana Souza'), findsNothing);
        expect(find.text('Pedido recusado.'), findsOneWidget);
      },
    );

    testWidgets('the last decision leaves the empty state', (tester) async {
      stubRequests(Success([anaRequest]));
      stubReview(JoinRequestDecision.approve, const Success(null));

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await decide(tester, 'Aceitar');

      expect(find.text('Nenhum pedido de entrada'), findsOneWidget);
    });

    testWidgets('a request already decided by another coordinator leaves', (
      tester,
    ) async {
      stubReview(
        JoinRequestDecision.approve,
        const Failure(JoinRequestAlreadyReviewedFailure()),
      );

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await decide(tester, 'Aceitar');

      expect(find.text('Ana Souza'), findsNothing);
      expect(find.text('Este pedido já foi respondido.'), findsOneWidget);
    });

    testWidgets('a request no longer valid warns and reloads the list', (
      tester,
    ) async {
      stubReview(
        JoinRequestDecision.approve,
        const Failure(JoinRequestNoLongerValidFailure()),
      );

      await pumpPage(tester);
      await tester.pumpAndSettle();
      stubRequests(const Success([biaRequest]));
      await decide(tester, 'Aceitar');
      await tester.pump();

      expect(
        find.text(
          'Este pedido não pode mais ser aceito: o grupo ou a conta da leitora foi desativado.',
        ),
        findsOneWidget,
      );
      expect(find.text('Ana Souza'), findsNothing);
      expect(find.text('Bia Lima'), findsOneWidget);
    });

    testWidgets('a failed decision keeps the request and explains why', (
      tester,
    ) async {
      stubReview(
        JoinRequestDecision.approve,
        const Failure(GroupJoinRequestsServerFailure()),
      );

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await decide(tester, 'Aceitar');

      expect(find.text('Ana Souza'), findsOneWidget);
      expect(
        find.text('Não foi possível responder ao pedido. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('the actions are disabled while a decision is pending', (
      tester,
    ) async {
      final response = Completer<Result<void, GroupJoinRequestsFailure>>();
      when(
        () => repository.review(
          requestId: anaRequestId,
          decision: JoinRequestDecision.approve,
        ),
      ).thenAnswer((_) => response.future);

      await pumpPage(tester);
      await tester.pumpAndSettle();
      await decide(tester, 'Aceitar');

      final buttons = tester.widgetList<AppButton>(find.byType(AppButton));
      expect(buttons.where((button) => button.onPressed != null), isEmpty);
      expect(buttons.where((button) => button.isLoading).map((b) => b.label), [
        'Aceitar',
      ]);

      response.complete(const Success(null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
