import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_execution_state.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_execution_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MockRaffleExecutionCubit extends Cubit<RaffleExecutionState>
    implements RaffleExecutionCubit {
  MockRaffleExecutionCubit(super.initialState);

  bool drawCalled = false;
  bool confirmResultCalled = false;

  @override
  Future<void> draw() async {
    drawCalled = true;
  }

  @override
  Future<void> confirmResult() async {
    confirmResultCalled = true;
  }

  @override
  Future<void> load(String meetingId, {String? meetingTitle}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const tMeetingId = 'm1';
  const tMeetingTitle = 'Julho';

  const tParticipants = [
    RaffleParticipant(
      id: 'p1',
      name: 'Ana Beatriz',
      hasAttended: true,
      bookTitle: 'O Pequeno Príncipe',
      bookAuthor: 'Antoine de Saint-Exupéry',
    ),
    RaffleParticipant(
      id: 'p2',
      name: 'Mariana de Souza',
      hasAttended: true,
      bookTitle: 'Dom Casmurro',
    ),
  ];

  const tResult = RaffleResult(
    meetingId: tMeetingId,
    winnerId: 'p1',
    winnerName: 'Ana Beatriz',
    bookTitle: 'O Pequeno Príncipe',
    bookAuthor: 'Antoine de Saint-Exupéry',
  );

  Widget buildWidget(RaffleExecutionCubit cubit) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BlocProvider<RaffleExecutionCubit>.value(
        value: cubit,
        child: const RaffleExecutionScreen(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
        ),
      ),
    );
  }

  testWidgets('deve renderizar a tela pronta com o botao SORTEAR e disparar draw ao tocar', (
    tester,
  ) async {
    final cubit = MockRaffleExecutionCubit(
      const RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: tParticipants,
      ),
    );

    await tester.pumpWidget(buildWidget(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Realizar Sorteio'), findsOneWidget);
    expect(find.text('Sorteio do Livro - Julho'), findsOneWidget);
    expect(find.text('2 participantes'), findsOneWidget);
    expect(find.text('SORTEAR'), findsOneWidget);

    final sortearButton = find.text('SORTEAR');
    await tester.tap(sortearButton);
    await tester.pumpAndSettle();

    expect(cubit.drawCalled, isTrue);
  });

  testWidgets('deve renderizar a tela de resultado com livro e anfitria quando ResultLoaded', (
    tester,
  ) async {
    final cubit = MockRaffleExecutionCubit(
      const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tResult,
        eligibleParticipants: tParticipants,
        isPersisted: false,
      ),
    );

    await tester.pumpWidget(buildWidget(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Resultado do Sorteio'), findsOneWidget);
    expect(find.text('Livro sorteado'), findsOneWidget);
    expect(find.text('O Pequeno Príncipe'), findsOneWidget);
    expect(find.text('Antoine de Saint-Exupéry'), findsOneWidget);
    expect(find.text('Anfitriã'), findsOneWidget);
    expect(find.text('Ana Beatriz'), findsOneWidget);

    expect(find.text('Concluir'), findsOneWidget);
    expect(find.text('Sortear novamente'), findsOneWidget);

    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();

    expect(cubit.confirmResultCalled, isTrue);
  });

  testWidgets('deve renderizar a tela de aviso quando nao houver participantes elegiveis', (
    tester,
  ) async {
    final cubit = MockRaffleExecutionCubit(
      const RaffleExecutionNoEligible(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
      ),
    );

    await tester.pumpWidget(buildWidget(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Não há participantes elegíveis para o sorteio.'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);
  });
}
