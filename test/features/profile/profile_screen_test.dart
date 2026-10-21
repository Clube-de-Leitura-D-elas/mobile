import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  late MockSessionCubit mockCubit;

  setUp(() {
    mockCubit = MockSessionCubit();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.logOut()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return BlocProvider<SessionCubit>.value(
      value: mockCubit,
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: const Scaffold(body: ProfileScreen()),
      ),
    );
  }

  testWidgets('Deve exibir o ícone de leave na ProfileScreen', (tester) async {
    await tester.pumpWidget(buildSubject());

    final iconFinder = find.byWidgetPredicate(
      (widget) => widget is AppIcon && widget.icon == AppIcons.leave,
    );
    expect(iconFinder, findsOneWidget);
  });

  testWidgets('Deve abrir o LogoutConfirmDialog ao clicar no ícone de saída', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final iconButton = find.byType(InkWell);
    await tester.tap(iconButton);
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
  });
  testWidgets('Deve expor Semantics de botão com label', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.button == true &&
            (w.properties.label ?? '').isNotEmpty,
      ),
      findsOneWidget,
    );
  });

  testWidgets('Deve fechar o dialog ao clicar em Cancelar sem chamar logOut', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutConfirmDialog), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsNothing);
    verifyNever(() => mockCubit.logOut());
  });

  testWidgets('Deve fechar o dialog ao clicar no X sem chamar logOut', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsNothing);
    verifyNever(() => mockCubit.logOut());
  });

  testWidgets('Deve fechar o dialog ao tocar fora (barrierDismissible)', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(1, 1));
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmDialog), findsNothing);
    verifyNever(() => mockCubit.logOut());
  });

  testWidgets('Deve chamar logOut e fechar o dialog ao confirmar em Sair', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.logOut()).called(1);
    expect(find.byType(LogoutConfirmDialog), findsNothing);
  });
}
