import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';
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
      theme: AppTheme
          .light, // Garante que os tokens (colors, spacing, typography) existam
      home: Scaffold(
        body: BlocProvider<SessionCubit>.value(
          value: mockCubit,
          child: const LogoutConfirmDialog(),
        ),
      ),
    );
  }

  testWidgets('Deve renderizar os textos e botões corretamente', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

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
    await tester.pumpWidget(buildSubject());

    final cancelBtn = find.text('Cancelar');
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    verifyNever(() => mockCubit.logOut());
  });

  testWidgets(
    'Deve fechar o modal ao clicar no ícone de fechar (X) sem chamar logOut',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      final closeIcon = find.byIcon(Icons.close);
      await tester.tap(closeIcon);
      await tester.pumpAndSettle();

      verifyNever(() => mockCubit.logOut());
    },
  );

  testWidgets(
    'Deve chamar logOut no SessionCubit e fechar o modal ao clicar em Sair',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      final sairBtn = find.text('Sair');
      await tester.tap(sairBtn);
      await tester.pumpAndSettle();

      verify(() => mockCubit.logOut()).called(1);
    },
  );
}
