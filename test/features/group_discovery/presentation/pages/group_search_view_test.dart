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
import 'package:mobile/features/cities/domain/entities/city_scope.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/pages/group_search_view.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_card.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_filters_dialog.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_skeleton.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/cities/presentation/widgets/city_filter_dropdown.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../../cities/cities_fixtures.dart';
import '../../group_discovery_fixtures.dart';

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockGroupDiscoveryRepository repository;
  late MockSessionCubit sessionCubit;
  late MockDiscoveryCitiesRepository citiesRepository;

  setUpAll(() {
    registerFallbackValue(GroupSearchFilters.empty);
  });

  setUp(() {
    repository = MockGroupDiscoveryRepository();
    citiesRepository = MockDiscoveryCitiesRepository();
    stubCities(citiesRepository);
    sessionCubit = MockSessionCubit();
    when(() => sessionCubit.state).thenReturn(const GuestSession());
    when(() => sessionCubit.logOut()).thenAnswer((_) async {});
  });

  tearDown(AppToast.dismiss);

  void stubSearch(
    Result<GroupSearchPageEntity, GroupDiscoveryFailure> result, {
    int page = 1,
    String search = '',
    GroupSearchFilters filters = GroupSearchFilters.empty,
    CityScope? city = CityScope.all,
  }) {
    when(
      () => repository.searchGroups(
        page: page,
        search: search,
        filters: filters,
        city: city,
      ),
    ).thenAnswer((_) async => result);
  }

  Success<GroupSearchPageEntity, GroupDiscoveryFailure> pageOf(
    List<DiscoveryGroupEntity> items, {
    int? total,
  }) => Success(
    GroupSearchPageEntity(items: items, total: total ?? items.length),
  );

  Future<void> pumpView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/busca',
      routes: [
        GoRoute(
          path: '/busca',
          builder: (_, _) => Scaffold(
            body: BlocProvider(
              create: (_) => GroupSearchCubit(
                repository: repository,
                citiesRepository: citiesRepository,
              )..load(),
              child: const GroupSearchView(),
            ),
          ),
        ),
        for (final path in [
          GroupDiscoveryRoutePaths.publicGroup,
          GroupRoutePaths.groupDetails,
        ])
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => context.pop(),
                child: Text('destino: ${state.uri}'),
              ),
            ),
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
  }

  List<DiscoveryGroupEntity> fullPage(int first) => [
    for (var i = 0; i < GroupDiscoveryRepository.pageSize; i++)
      searchGroup(first + i),
  ];

  Finder cardOf(int number) => find.byKey(ValueKey(searchGroupId(number)));

  Finder inCard(int number, Finder matching) =>
      find.descendant(of: cardOf(number), matching: matching);

  group('cards', () {
    testWidgets('show name, participants and city', (tester) async {
      stubSearch(pageOf([searchGroup(1), searchGroup(2, cityState: null)]));

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(inCard(1, find.text('Grupo 1')), findsOneWidget);
      expect(inCard(1, find.text('31 participantes')), findsOneWidget);
      expect(inCard(1, find.text('Porto Alegre, RS')), findsOneWidget);
      expect(inCard(2, find.text('Porto Alegre, RS')), findsNothing);
      expect(find.bySemanticsLabel('Ver detalhes do Grupo 2'), findsOneWidget);
    });

    final byStatus = <GroupMembershipStatus, (String?, String?)>{
      GroupMembershipStatus.none: (null, 'Solicitar entrada'),
      GroupMembershipStatus.requested: ('Aguardando aprovação', null),
      GroupMembershipStatus.rejected: (
        'Solicitação recusada',
        'Pedir novamente',
      ),
      GroupMembershipStatus.pending: ('Aguardando criação de conta', null),
      GroupMembershipStatus.member: ('Você já faz parte deste grupo', null),
    };
    for (final MapEntry(key: status, value: (indicator, button))
        in byStatus.entries) {
      testWidgets('show the status and action of a ${status.name} reader', (
        tester,
      ) async {
        stubSearch(pageOf([searchGroup(1, membership: status)]));

        await pumpView(tester);
        await tester.pumpAndSettle();

        expect(
          tester
              .widgetList<AppButton>(inCard(1, find.byType(AppButton)))
              .map((button) => button.label),
          [?button],
        );
        if (indicator != null) {
          expect(inCard(1, find.text(indicator)), findsOneWidget);
        }
      });
    }

    testWidgets('"Ver detalhes" opens the public page and refreshes the '
        'status on return', (tester) async {
      stubSearch(pageOf([searchGroup(1)]));
      when(() => repository.getGroup(searchGroupId(1))).thenAnswer(
        (_) async => Success(
          searchGroup(1, membership: GroupMembershipStatus.requested),
        ),
      );

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(inCard(1, find.text('Ver detalhes')));
      await tester.pumpAndSettle();

      expect(
        find.text('destino: /group-public?group_id=${searchGroupId(1)}'),
        findsOneWidget,
      );

      await tester.tap(find.textContaining('destino:'));
      await tester.pumpAndSettle();

      verify(() => repository.getGroup(searchGroupId(1))).called(1);
      expect(inCard(1, find.text('Aguardando aprovação')), findsOneWidget);
      expect(inCard(1, find.text('Solicitar entrada')), findsNothing);
    });

    testWidgets('"Ver detalhes" of a member opens the member page', (
      tester,
    ) async {
      stubSearch(
        pageOf([searchGroup(1, membership: GroupMembershipStatus.member)]),
      );
      when(() => repository.getGroup(any())).thenAnswer(
        (_) async =>
            Success(searchGroup(1, membership: GroupMembershipStatus.member)),
      );

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(inCard(1, find.text('Ver detalhes')));
      await tester.pumpAndSettle();

      expect(
        find.text('destino: /group-details?group_id=${searchGroupId(1)}'),
        findsOneWidget,
      );
    });

    testWidgets('asks to join from the card after the confirmation', (
      tester,
    ) async {
      stubSearch(pageOf([searchGroup(1), searchGroup(2)]));
      when(
        () => repository.requestJoin(searchGroupId(2)),
      ).thenAnswer((_) async => const Success(null));

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(inCard(2, find.text('Solicitar entrada')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(() => repository.requestJoin(searchGroupId(2))).called(1);
      expect(
        find.text('Pedido enviado! Agora é só aguardar a aprovação.'),
        findsOneWidget,
      );
      expect(inCard(2, find.text('Aguardando aprovação')), findsOneWidget);
      expect(inCard(1, find.text('Solicitar entrada')), findsOneWidget);
    });

    testWidgets('card and confirmation buttons have a 48 touch target', (
      tester,
    ) async {
      stubSearch(
        pageOf([
          searchGroup(1),
          searchGroup(2, membership: GroupMembershipStatus.rejected),
        ]),
      );

      await pumpView(tester);
      await tester.pumpAndSettle();

      for (final label in ['Solicitar entrada', 'Pedir novamente']) {
        expect(
          tester.getSize(find.widgetWithText(AppButton, label)).height,
          greaterThanOrEqualTo(48),
        );
      }

      await tester.tap(find.text('Solicitar entrada'));
      await tester.pumpAndSettle();
      for (final label in ['Cancelar', 'Solicitar']) {
        expect(
          tester.getSize(find.widgetWithText(AppButton, label)).height,
          greaterThanOrEqualTo(48),
        );
      }
    });

    testWidgets('reads name, participants and city as one header', (
      tester,
    ) async {
      stubSearch(pageOf([searchGroup(1)]));

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Grupo 1')),
        isSemantics(
          isHeader: true,
          label: 'Grupo 1\n31 participantes\nPorto Alegre, RS',
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Ver detalhes do Grupo 1')),
        isSemantics(isButton: true),
      );
    });

    testWidgets('cancelling the confirmation does not ask', (tester) async {
      stubSearch(pageOf([searchGroup(1)]));

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar entrada'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => repository.requestJoin(any()));
    });
  });

  group('search and filters', () {
    testWidgets('searches what the reader types', (tester) async {
      stubSearch(pageOf([searchGroup(1), searchGroup(2)]));
      stubSearch(pageOf([searchGroup(2)]), search: 'dois');

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'dois');
      await tester.pump(AppSearchField.defaultDebounce);
      await tester.pumpAndSettle();

      expect(find.byType(GroupSearchCard), findsOneWidget);
      expect(cardOf(2), findsOneWidget);
    });

    testWidgets('applies the filters chosen in the modal', (tester) async {
      const chosen = GroupSearchFilters(
        city: saoPaulo,
        minParticipants: 10,
        maxParticipants: 20,
      );
      stubSearch(pageOf([searchGroup(1), searchGroup(2)]));
      stubSearch(
        pageOf([searchGroup(2)]),
        filters: chosen,
        city: CityScope.only(saoPaulo.id),
      );

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();

      expect(find.byType(GroupSearchFiltersDialog), findsOneWidget);
      await tester.tap(find.text('Todas as cidades'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('São Paulo, SP').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(1), '10');
      await tester.enterText(find.byType(EditableText).at(2), '20');
      await tester.pump();
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();

      verify(
        () => repository.searchGroups(
          page: 1,
          search: '',
          filters: chosen,
          city: CityScope.only(saoPaulo.id),
        ),
      ).called(1);
      expect(find.byType(GroupSearchCard), findsOneWidget);
      expect(
        tester.getSemantics(find.byTooltip('Filtros')),
        isSemantics(value: 'Filtros aplicados'),
      );
    });

    testWidgets('blocks a minimum above the maximum', (tester) async {
      stubSearch(pageOf([searchGroup(1)]));

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(1), '30');
      await tester.enterText(find.byType(EditableText).at(2), '5x');
      await tester.pump();

      expect(
        find.text('O mínimo não pode ser maior que o máximo.'),
        findsOneWidget,
      );
      final apply = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Aplicar filtros'),
      );
      expect(apply.onPressed, isNull);
    });

    testWidgets('an empty filtered list offers to clear the filters', (
      tester,
    ) async {
      const chosen = GroupSearchFilters(minParticipants: 500);
      stubSearch(pageOf([searchGroup(1)]));
      stubSearch(pageOf([]), filters: chosen);

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).at(1), '500');
      await tester.pump();
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Nenhum grupo encontrado. Tente outra busca ou mude os filtros.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();

      expect(find.byType(GroupSearchCard), findsOneWidget);
    });
  });

  group('states', () {
    testWidgets('shows the skeleton while loading', (tester) async {
      final pending =
          Completer<Result<GroupSearchPageEntity, GroupDiscoveryFailure>>();
      when(
        () => repository.searchGroups(
          page: 1,
          search: '',
          filters: GroupSearchFilters.empty,
          city: CityScope.all,
        ),
      ).thenAnswer((_) => pending.future);

      await pumpView(tester);
      await tester.pump();

      expect(find.byType(GroupSearchSkeleton), findsOneWidget);
      expect(find.bySemanticsLabel('Carregando grupos'), findsOneWidget);
    });

    testWidgets('shows the empty message', (tester) async {
      stubSearch(pageOf([]));

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('Ainda não há grupos ativos.'), findsOneWidget);
      expect(find.text('Limpar filtros'), findsNothing);
    });

    testWidgets('asks each next page once and stops at the end', (
      tester,
    ) async {
      // O total promete mais do que vem: a página incompleta encerra.
      stubSearch(pageOf(fullPage(1), total: 100));
      stubSearch(pageOf(fullPage(21), total: 100), page: 2);
      stubSearch(pageOf([searchGroup(41)], total: 100), page: 3);

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.text('Você chegou ao fim da lista.'),
        find.byType(ListView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      expect(cardOf(41), findsOneWidget);
      for (final page in [1, 2, 3]) {
        verify(
          () => repository.searchGroups(
            page: page,
            search: '',
            filters: GroupSearchFilters.empty,
            city: CityScope.all,
          ),
        ).called(1);
      }
      verifyNever(
        () => repository.searchGroups(
          page: 4,
          search: any(named: 'search'),
          filters: any(named: 'filters'),
          city: any(named: 'city'),
        ),
      );
    });

    testWidgets('an empty next page ends the list despite the total', (
      tester,
    ) async {
      stubSearch(pageOf(fullPage(1), total: 100));
      stubSearch(pageOf([], total: 100), page: 2);

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.text('Você chegou ao fim da lista.'),
        find.byType(ListView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      verifyNever(
        () => repository.searchGroups(
          page: 3,
          search: any(named: 'search'),
          filters: any(named: 'filters'),
          city: any(named: 'city'),
        ),
      );
    });

    testWidgets('retries a failed next page', (tester) async {
      stubSearch(pageOf(fullPage(1), total: 21));
      stubSearch(const Failure(GroupDiscoveryNetworkFailure()), page: 2);

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.text('Não foi possível carregar mais grupos.'),
        find.byType(ListView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      stubSearch(pageOf([searchGroup(21)], total: 21), page: 2);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Você chegou ao fim da lista.'),
        find.byType(ListView),
        const Offset(0, -600),
      );
      expect(cardOf(21), findsOneWidget);
    });

    testWidgets('shows the error and retries', (tester) async {
      stubSearch(const Failure(GroupDiscoveryServerFailure()));

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar os grupos.'), findsOneWidget);

      stubSearch(pageOf([searchGroup(1)]));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.byType(GroupSearchCard), findsOneWidget);
    });

    testWidgets('does not offer retry to an inactive account', (tester) async {
      stubSearch(const Failure(GroupDiscoveryInactiveAccountFailure()));

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Você não tem permissão para fazer isso.'),
        findsOneWidget,
      );
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('offers logout when the session expired', (tester) async {
      stubSearch(const Failure(GroupDiscoverySessionExpiredFailure()));

      await pumpView(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));

      verify(() => sessionCubit.logOut()).called(1);
    });
  });

  group('city filter', () {
    Finder cityDropdown() => find.byType(CityFilterDropdown);

    testWidgets('opens on every city, with groups from other cities and '
        'their join button', (tester) async {
      stubSearch(
        pageOf([searchGroup(1), searchGroup(2, cityState: 'São Paulo, SP')]),
      );

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(inCard(2, find.text('São Paulo, SP')), findsOneWidget);
      expect(inCard(2, find.text('Solicitar entrada')), findsOneWidget);
      expect(
        tester.getSemantics(find.byTooltip('Filtros')),
        isNot(isSemantics(value: 'Filtros aplicados')),
      );

      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: cityDropdown(),
          matching: find.text('Todas as cidades'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('without the city list the search goes without cityId and '
        'the modal has no city filter', (tester) async {
      stubCitiesFailure(citiesRepository);
      stubSearch(pageOf([searchGroup(1)]), city: null);

      await pumpView(tester);
      await tester.pumpAndSettle();

      expect(cardOf(1), findsOneWidget);
      verify(
        () => repository.searchGroups(
          page: 1,
          search: '',
          filters: GroupSearchFilters.empty,
        ),
      ).called(1);

      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      expect(cityDropdown(), findsNothing);
    });
  });
}
