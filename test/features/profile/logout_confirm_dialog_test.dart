import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockSessionCubit mockCubit;

  setUp(() {
    mockCubit = MockSessionCubit();
    when(() => mockCubit.logOut()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: BlocProvider<SessionCubit>.value(
          value: mockCubit,
          child: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BlocProvider<SessionCubit>.value(
                    value: mockCubit,
                    child: const LogoutConfirmDialog(),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('Deve renderizar os textos e botões corretamente', (
    tester,
  ) async {
    await openDialog(tester);

    expect(find.text('Sair da conta'), findsOneWidget);
    expect(
      find.text(
        'Você deseja mesmo sair do aplicativo? Será necessário fazer login novamente para acessar sua conta.',
      ),
      findsOneWidget,
    );
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('Deve fechar o modal ao clicar em Cancelar sem chamar logOut', (
    tester,
  ) async {
    await openDialog(tester);

    final cancelBtn = find.text('Cancelar');
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    verifyNever(() => mockCubit.logOut());
    expect(find.byType(LogoutConfirmDialog), findsNothing);
  });

  testWidgets(
    'Deve fechar o modal ao clicar no ícone de fechar (X) sem chamar logOut',
    (tester) async {
      await openDialog(tester);

      final closeIcon = find.byIcon(Icons.close);
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();

      verifyNever(() => mockCubit.logOut());
      expect(find.byType(LogoutConfirmDialog), findsNothing);
    },
  );

  testWidgets(
    'Deve chamar logOut no SessionCubit e fechar o modal ao clicar em Sair',
    (tester) async {
      await openDialog(tester);

      final sairBtn = find.text('Sair');
      await tester.tap(sairBtn);
      await tester.pumpAndSettle();

      verify(() => mockCubit.logOut()).called(1);
      expect(find.byType(LogoutConfirmDialog), findsNothing);
    },
  );
  testWidgets('Deve exibir Tooltip no ícone de fechar', (tester) async {
    await openDialog(tester);

    final tooltip = find.ancestor(
      of: find.byIcon(Icons.close),
      matching: find.byType(Tooltip),
    );
    expect(tooltip, findsOneWidget);
    expect((tester.widget<Tooltip>(tooltip).message ?? '').isNotEmpty, isTrue);
  });

  testWidgets('Deve renderizar AppButton ghost (Cancelar) e primary (Sair)', (
    tester,
  ) async {
    await openDialog(tester);

    expect(find.widgetWithText(AppButton, 'Cancelar'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Sair'), findsOneWidget);
  });
}
