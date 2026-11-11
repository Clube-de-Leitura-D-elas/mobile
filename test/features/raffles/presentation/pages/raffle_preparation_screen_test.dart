import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_screen.dart';
import 'package:mobile/features/raffles/presentation/routes/raffle_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockRaffleRepository extends Mock implements RaffleRepository {}

void main() {
  const meetingId = 'meeting-1';
  const ana = RaffleParticipant(id: 'p1', name: 'Ana', hasAttended: true);
  late MockRaffleRepository repository;
  late RafflePreparationCubit cubit;

  setUp(() {
    repository = MockRaffleRepository();
    when(
      () => repository.getEligibleParticipants(meetingId),
    ).thenAnswer((_) async => const Success([ana]));
    cubit = RafflePreparationCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  void stubConfirm(RaffleFailure failure) {
    when(
      () => repository.confirmRaffle(
        meetingId: any(named: 'meetingId'),
        selectedParticipantIds: any(named: 'selectedParticipantIds'),
      ),
    ).thenAnswer((_) async => Failure(failure));
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(
          path: '/start',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/prep'),
              child: const Text('abrir'),
            ),
          ),
        ),
        GoRoute(
          path: '/prep',
          builder: (_, _) => BlocProvider.value(
            value: cubit,
            child: const RafflePreparationScreen(meetingId: meetingId),
          ),
        ),
        GoRoute(
          path: RaffleRoutes.draw,
          builder: (_, _) => const Scaffold(body: Text('tela do sorteio')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        routerConfig: router,
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await cubit.loadEligibleParticipants(meetingId);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the reason in a toast when confirming fails', (
    tester,
  ) async {
    stubConfirm(const RaffleNetworkFailure());
    await pumpScreen(tester);

    await cubit.confirmRaffle(meetingId);
    await tester.pump();

    expect(
      find.text(
        'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });

  testWidgets('says the list was refreshed after a 422', (tester) async {
    stubConfirm(const RaffleParticipantsChangedFailure());
    await pumpScreen(tester);

    await cubit.confirmRaffle(meetingId);
    await tester.pump();

    expect(
      find.text(
        'A lista de participantes mudou. Atualizamos a lista: confira as '
        'participantes e confirme de novo.',
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });

  testWidgets('opens the draw when the raffle was already recorded', (
    tester,
  ) async {
    stubConfirm(const RaffleAlreadyRecordedFailure());
    await pumpScreen(tester);

    await cubit.confirmRaffle(meetingId);
    await tester.pumpAndSettle();

    expect(find.text('tela do sorteio'), findsOneWidget);
  });
}
