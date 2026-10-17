import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/profile/presentation/pages/profile_screen.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends Mock implements SessionCubit {}

void main() {
  late MockSessionCubit mockCubit;

  setUp(() {
    mockCubit = MockSessionCubit();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: BlocProvider<SessionCubit>.value(
          value: mockCubit,
          child: const ProfileScreen(),
        ),
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
}
