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
  bool retryCalled = false;

  @override
  Future<void> retry() async {
    retryCalled = true;
  }

  @override
  Future<void> draw() async {
    drawCalled = true;
  }

  @override
  Future<void> confirmResult() async {
    confirmResultCalled = true;
  }

  void emitError() => emit(const RaffleExecutionError('Erro de teste'));

  void emitSuccess(RaffleResult result) => emit(RaffleExecutionSuccess(result));

  @override
  Future<void> load(
    String meetingId, {
    String? meetingTitle,
    List<RaffleParticipant>? participants,
  }) async {}

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

  Widget buildWidget(
    RaffleExecutionCubit cubit, {
    Locale locale = const Locale('pt', 'BR'),
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: locale,
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

  testWidgets(
    'deve renderizar a tela pronta com o botao SORTEAR e disparar draw ao tocar',
    (tester) async {
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
    },
  );

  testWidgets(
    'deve renderizar a tela de resultado com livro e anfitria quando ResultLoaded',
    (tester) async {
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
    },
  );

  testWidgets(
    'deve acionar sortear novamente e concluir resultado persistido',
    (tester) async {
      final cubit = MockRaffleExecutionCubit(
        const RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: '',
          result: tResult,
          eligibleParticipants: tParticipants,
          isPersisted: false,
        ),
      );
      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();
      expect(find.text('Resultado do Sorteio'), findsOneWidget);
      await tester.tap(find.text('Sortear novamente'));
      expect(cubit.drawCalled, isTrue);

      final persistedCubit = MockRaffleExecutionCubit(
        const RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          isPersisted: true,
        ),
      );
      await tester.pumpWidget(buildWidget(persistedCubit));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Concluir'));
    },
  );

  testWidgets('deve acionar voltar no estado sem participantes', (
    tester,
  ) async {
    final cubit = MockRaffleExecutionCubit(
      const RaffleExecutionNoEligible(meetingId: tMeetingId, meetingTitle: ''),
    );
    await tester.pumpWidget(buildWidget(cubit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
  });

  testWidgets('deve renderizar loading e resultado persistido', (tester) async {
    final loadingCubit = MockRaffleExecutionCubit(
      const RaffleExecutionLoading(),
    );
    await tester.pumpWidget(buildWidget(loadingCubit));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final persistedCubit = MockRaffleExecutionCubit(
      const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tResult,
        isPersisted: true,
      ),
    );
    await tester.pumpWidget(buildWidget(persistedCubit));
    await tester.pumpAndSettle();
    expect(find.text('Sortear novamente'), findsNothing);
    expect(find.text('Concluir'), findsOneWidget);
  });

  testWidgets('deve renderizar capas e avatar com URLs invalidas', (
    tester,
  ) async {
    const resultWithImages = RaffleResult(
      meetingId: tMeetingId,
      winnerId: 'p1',
      winnerName: 'Ana Beatriz',
      winnerAvatarUrl: 'https://invalid.test/avatar.png',
      bookTitle: 'O Pequeno Príncipe',
      bookCoverUrl: 'https://invalid.test/cover.png',
    );
    final cubit = MockRaffleExecutionCubit(
      const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: resultWithImages,
      ),
    );
    await tester.pumpWidget(buildWidget(cubit));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets(
    'desabilita sortear novamente e avisa quando nao ha mais ninguem',
    (tester) async {
      final cubit = MockRaffleExecutionCubit(
        const RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
        ),
      );
      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Sem mais pessoas para sortear'), findsOneWidget);
      await tester.tap(find.text('Sortear novamente'));
      expect(cubit.drawCalled, isFalse);
    },
  );

  testWidgets('deve exibir estado de desenho e desabilitar botao', (
    tester,
  ) async {
    final cubit = MockRaffleExecutionCubit(
      const RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: tParticipants,
        isDrawing: true,
      ),
    );
    await tester.pumpWidget(buildWidget(cubit));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('SORTEAR'), findsNothing);
    expect(cubit.drawCalled, isFalse);
  });

  testWidgets('deve tratar erro e sucesso emitidos pelo Cubit', (tester) async {
    final cubit = MockRaffleExecutionCubit(const RaffleExecutionInitial());
    await tester.pumpWidget(buildWidget(cubit));
    cubit.emitError();
    await tester.pump();
    expect(find.text('Não foi possível concluir o sorteio'), findsOneWidget);
    expect(find.text('Erro de teste'), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    expect(cubit.retryCalled, isTrue);
  });

  testWidgets(
    'deve renderizar a tela de aviso quando nao houver participantes elegiveis',
    (tester) async {
      final cubit = MockRaffleExecutionCubit(
        const RaffleExecutionNoEligible(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
        ),
      );

      await tester.pumpWidget(buildWidget(cubit));
      await tester.pumpAndSettle();

      expect(
        find.text('Não há participantes elegíveis para o sorteio.'),
        findsOneWidget,
      );
      expect(find.text('Voltar'), findsOneWidget);
    },
  );
}
