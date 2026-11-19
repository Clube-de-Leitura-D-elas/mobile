import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_failure.dart';
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

  void emitError() => emit(const RaffleExecutionError(RaffleServerFailure()));

  void push(RaffleExecutionState state) => emit(state);

  void emitSuccess(RaffleResult result) => emit(RaffleExecutionSuccess(result));

  @override
  Future<void> load(
    String? meetingId, {
    String? groupId,
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

  const tParticipantsSecond = RaffleParticipant(
    id: 'p2',
    name: 'Mariana de Souza',
    hasAttended: true,
    bookTitle: 'Dom Casmurro',
  );

  const tSecondResult = RaffleResult(
    meetingId: tMeetingId,
    winnerId: 'p2',
    winnerName: 'Mariana de Souza',
    bookTitle: 'Dom Casmurro',
  );

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
    'deve renderizar a tela pronta com o botao Sortear livro e disparar draw ao tocar',
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
      expect(find.text('Sortear livro'), findsOneWidget);

      final sortearButton = find.text('Sortear livro');
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
    expect(find.text('Sortear livro'), findsNothing);
    expect(cubit.drawCalled, isFalse);
  });

  testWidgets('deve tratar erro e sucesso emitidos pelo Cubit', (tester) async {
    final cubit = MockRaffleExecutionCubit(const RaffleExecutionInitial());
    await tester.pumpWidget(buildWidget(cubit));
    cubit.emitError();
    await tester.pump();
    expect(
      find.text('Não foi possível concluir o sorteio. Tente novamente.'),
      findsOneWidget,
    );
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

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets(
    'gira a roleta durante o sorteio e so mostra o resultado depois de parar',
    (tester) async {
      const ready = RaffleExecutionReady(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        eligibleParticipants: tParticipants,
      );
      final cubit = MockRaffleExecutionCubit(ready);
      await tester.pumpWidget(buildWidget(cubit));

      cubit.push(ready.copyWith(isDrawing: true));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Embaralhando as indicações…'), findsOneWidget);
      expect(find.text('Realizar Sorteio'), findsOneWidget);

      cubit.push(
        const RaffleExecutionResultLoaded(
          meetingId: tMeetingId,
          meetingTitle: tMeetingTitle,
          result: tResult,
          eligibleParticipants: [],
        ),
      );
      await tester.pump();
      expect(find.text('Livro sorteado'), findsNothing);

      await pumpUntilFound(tester, find.text('Temos um livro!'));
      expect(find.text('indicado por Ana Beatriz'), findsOneWidget);

      await pumpUntilFound(tester, find.text('Livro sorteado'));
      await tester.pumpAndSettle();
      expect(find.text('Resultado do Sorteio'), findsOneWidget);
      expect(find.text('Temos um livro!'), findsNothing);
    },
  );

  testWidgets('gira a roleta no sortear novamente ate o novo resultado', (
    tester,
  ) async {
    final cubit = MockRaffleExecutionCubit(
      const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tResult,
        eligibleParticipants: [tParticipantsSecond],
      ),
    );
    await tester.pumpWidget(buildWidget(cubit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sortear novamente'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(cubit.drawCalled, isTrue);
    expect(find.text('Embaralhando as indicações…'), findsOneWidget);
    expect(find.text('Livro sorteado'), findsNothing);

    cubit.push(
      const RaffleExecutionResultLoaded(
        meetingId: tMeetingId,
        meetingTitle: tMeetingTitle,
        result: tSecondResult,
      ),
    );
    await pumpUntilFound(tester, find.text('Livro sorteado'));
    await tester.pumpAndSettle();
    expect(find.text('Resultado do Sorteio'), findsOneWidget);
    expect(find.text('Mariana de Souza'), findsOneWidget);
  });

  testWidgets('para a roleta e mostra o erro quando o sorteio falha', (
    tester,
  ) async {
    const ready = RaffleExecutionReady(
      meetingId: tMeetingId,
      meetingTitle: tMeetingTitle,
      eligibleParticipants: tParticipants,
    );
    final cubit = MockRaffleExecutionCubit(ready);
    await tester.pumpWidget(buildWidget(cubit));

    cubit.push(ready.copyWith(isDrawing: true));
    await tester.pump(const Duration(milliseconds: 300));
    cubit.emitError();
    await tester.pumpAndSettle();

    expect(find.text('Embaralhando as indicações…'), findsNothing);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
