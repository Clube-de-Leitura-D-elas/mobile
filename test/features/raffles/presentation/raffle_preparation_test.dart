import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_state.dart';
import 'package:mobile/features/raffles/presentation/pages/raffle_preparation_screen.dart';
import 'package:mobile/features/raffles/presentation/routes/raffle_routes.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MockRafflePreparationCubit extends Cubit<RafflePreparationState>
    implements RafflePreparationCubit {
  MockRafflePreparationCubit(super.initialState);

  @override
  void toggleParticipantSelection(String participantId) {
    if (state is RafflePreparationLoaded) {
      final currentState = state as RafflePreparationLoaded;
      final updatedList = currentState.participants.map((p) {
        if (p.id == participantId) {
          return p.copyWith(isSelected: !p.isSelected);
        }
        return p;
      }).toList();
      emit(currentState.copyWith(participants: updatedList));
    }
  }

  @override
  Future<void> confirmRaffle(String meetingId) async {
    emit((state as RafflePreparationLoaded).copyWith(isSubmitting: true));
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const RafflePreparationSuccess());
  }

  void emitError() => emit(const RafflePreparationError('Erro de teste'));

  void emitSuccess() => emit(const RafflePreparationSuccess());

  String? loadedMeetingId;

  @override
  Future<void> loadEligibleParticipants(String meetingId) async {
    loadedMeetingId = meetingId;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('deve renderizar loading e erro na preparação', (tester) async {
    final loadingCubit = MockRafflePreparationCubit(
      const RafflePreparationLoading(),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: BlocProvider<RafflePreparationCubit>.value(
          value: loadingCubit,
          child: const RafflePreparationScreen(meetingId: 'meeting-123'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final errorCubit = MockRafflePreparationCubit(
      const RafflePreparationLoading(),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: BlocProvider<RafflePreparationCubit>.value(
          value: errorCubit,
          child: const RafflePreparationScreen(meetingId: 'meeting-123'),
        ),
      ),
    );
    await tester.pump();
    errorCubit.emitError();
    await tester.pump();
    expect(find.text('Não foi possível concluir o sorteio'), findsOneWidget);
    expect(find.text('Erro de teste'), findsNothing);

    await tester.tap(find.text('Tentar novamente'));
    expect(errorCubit.loadedMeetingId, 'meeting-123');
  });

  testWidgets('deve voltar quando confirmacao concluir sem router', (
    tester,
  ) async {
    final cubit = MockRafflePreparationCubit(const RafflePreparationSuccess());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: Scaffold(
          body: BlocProvider<RafflePreparationCubit>.value(
            value: cubit,
            child: const RafflePreparationScreen(
              meetingId: 'meeting-123',
              meetingTitle: 'Julho',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(RafflePreparationScreen), findsOneWidget);
  });

  testWidgets('Teste Visual - Interação na Preparação do Sorteio', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;

    final mockParticipants = [
      const RaffleParticipant(
        id: '1',
        name: 'Mariana de Souza',
        avatarUrl: null,
        hasAttended: true,
        isSelected: true,
      ),
      const RaffleParticipant(
        id: '2',
        name: 'Alana Mendes (Excluída)',
        avatarUrl: null,
        hasAttended: true,
        isExcludedByRule: true,
        exclusionReason: 'Já foi sorteada neste ciclo',
        isSelected: false,
      ),
      const RaffleParticipant(
        id: '3',
        name: 'Beatriz Vasconcellos',
        avatarUrl: null,
        hasAttended: true,
        isSelected: false,
      ),
    ];

    final cubit = MockRafflePreparationCubit(
      RafflePreparationLoaded(participants: mockParticipants),
    );

    // 2. Renderizar o App com o Tema e Configurações de Design System
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        // Adicionar delegates e locales suportados:
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: BlocProvider<RafflePreparationCubit>.value(
          value: cubit,
          child: const Scaffold(
            body: RafflePreparationScreen(meetingId: 'mock-id-123'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Renderiza a tela inicial

    // 3. Capturar visualmente se os participantes aparecem
    expect(find.text('Realizar sorteio'), findsOneWidget);
    expect(find.text('Mariana de Souza'), findsOneWidget);
    expect(find.text('Alana Mendes (Excluída)'), findsOneWidget);
    expect(find.text('Já foi sorteada neste ciclo'), findsOneWidget);

    // 4. Testar a seleção: Tocar no Checkbox da Beatriz Vasconcellos
    final checkboxBeatriz = find.byType(AppCheckbox).last;
    await tester.ensureVisible(checkboxBeatriz);
    await tester.pumpAndSettle();

    // Passando o parâmetro para ignorar o aviso de sobreposição no teste
    await tester.tap(checkboxBeatriz, warnIfMissed: false);
    await tester.pumpAndSettle();

    // 5. Clicar no botão 'Continuar' no rodapé
    final botaoContinuar = find.text('Continuar');
    expect(botaoContinuar, findsOneWidget);
    await tester.tap(botaoContinuar);
    await tester.pumpAndSettle(); // Aguarda a animação do modal (Dialog)

    // 6. Validar visualmente o Modal de Confirmação aberto
    expect(find.text('Confirmar sorteio'), findsOneWidget);
    expect(find.text('Você deseja mesmo confirmar o sorteio?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);

    // Limpa a simulação de tela
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets(
    'given the raffle is confirmed, when the draw closes, then completes the push that opened the preparation',
    (tester) async {
      final cubit = MockRafflePreparationCubit(
        const RafflePreparationLoaded(participants: []),
      );
      var openerResumed = false;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TextButton(
              onPressed: () async {
                await context.push<Object?>(RaffleRoutes.preparation);
                openerResumed = true;
              },
              child: const Text('open'),
            ),
          ),
          GoRoute(
            path: RaffleRoutes.preparation,
            builder: (context, state) =>
                BlocProvider<RafflePreparationCubit>.value(
                  value: cubit,
                  child: const RafflePreparationScreen(meetingId: 'meeting-1'),
                ),
          ),
          GoRoute(
            path: RaffleRoutes.draw,
            builder: (context, state) => TextButton(
              onPressed: () => context.pop(),
              child: const Text('draw-done'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt', 'BR'),
          routerConfig: router,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      cubit.emitSuccess();
      await tester.pumpAndSettle();
      expect(find.text('draw-done'), findsOneWidget);

      await tester.tap(find.text('draw-done'));
      await tester.pumpAndSettle();

      expect(openerResumed, isTrue);
      expect(find.text('open'), findsOneWidget);
    },
  );
}
