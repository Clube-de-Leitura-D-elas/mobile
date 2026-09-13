import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/register_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

void main() {
  late MockSessionCubit mockSessionCubit;

  setUp(() {
    mockSessionCubit = MockSessionCubit();
    when(() => mockSessionCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSessionCubit.state).thenReturn(const GuestSession());
  });

  Widget buildSubject({VoidCallback? onLoginPressed}) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      home: BlocProvider<SessionCubit>.value(
        value: mockSessionCubit,
        child: RegisterScreen(onLoginPressed: onLoginPressed),
      ),
    );
  }

  group('RegisterScreen Widget', () {
    testWidgets('renders all UI elements correctly', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Criar Conta'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
      expect(find.text('Pelo menos 8 caracteres'), findsOneWidget);
      expect(find.text('Pelo menos 1 letra maiúscula'), findsOneWidget);
      expect(find.text('Pelo menos 1 letra minúscula'), findsOneWidget);
      expect(find.text('Pelo menos 1 número'), findsOneWidget);
      expect(find.text('Senhas conferem'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Já tenho uma conta'), findsOneWidget);
    });

    testWidgets(
      'shows validation errors when fields are empty or email is invalid',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Enter valid password to enable button submit attempt
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(1), 'Pass1234');
        await tester.enterText(textFields.at(2), 'Pass1234');
        await tester.pumpAndSettle();

        final registerButton = find.byType(AppButton);
        await tester.ensureVisible(registerButton);
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        expect(find.text('Por favor, informe seu e-mail'), findsOneWidget);

        await tester.enterText(textFields.at(0), 'invalid-email');
        await tester.tap(registerButton);
        await tester.pumpAndSettle();

        expect(find.text('Informe um e-mail válido'), findsOneWidget);
      },
    );

    testWidgets('submits email and password when form is valid', (
      tester,
    ) async {
      when(
        () => mockSessionCubit.signUpWithEmail(
          email: 'test@example.com',
          password: 'Password1',
        ),
      ).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'Password1');
      await tester.enterText(textFields.at(2), 'Password1');
      await tester.pumpAndSettle();

      final registerButton = find.byType(AppButton);
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pump();

      verify(
        () => mockSessionCubit.signUpWithEmail(
          email: 'test@example.com',
          password: 'Password1',
        ),
      ).called(1);
    });

    testWidgets('triggers onLoginPressed callback when link is tapped', (
      tester,
    ) async {
      bool loginPressed = false;
      await tester.pumpWidget(
        buildSubject(
          onLoginPressed: () {
            loginPressed = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      final loginLink = find.text('Já tenho uma conta');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(loginLink);
      await tester.pump();

      expect(loginPressed, isTrue);
    });

    testWidgets('submits email and password on password field onSubmitted', (tester) async {
      when(() => mockSessionCubit.signUpWithEmail(
            email: 'test@example.com',
            password: 'Password1',
          )).thenAnswer((_) async => const Success(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'test@example.com');
      await tester.enterText(textFields.at(1), 'Password1');
      await tester.enterText(textFields.at(2), 'Password1');
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verify(() => mockSessionCubit.signUpWithEmail(
            email: 'test@example.com',
            password: 'Password1',
          )).called(1);
    });

    testWidgets('displays error SnackBar on SessionError state', (tester) async {
      whenListen(
        mockSessionCubit,
        Stream.fromIterable([
          const SessionError(message: 'email not confirmed'),
        ]),
        initialState: const GuestSession(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Por favor, confirme seu e-mail antes de logar.'), findsOneWidget);
    });

    testWidgets('displays generic error SnackBar on SessionError state', (
      tester,
    ) async {
      whenListen(
        mockSessionCubit,
        Stream.fromIterable([
          const SessionError(message: 'Erro ao cadastrar usuário'),
        ]),
        initialState: const GuestSession(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
    });
  });
}
