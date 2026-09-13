import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSupabaseService mockSupabaseService;
  late SessionCubit sessionCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSupabaseService = MockSupabaseService();

    when(() => mockSupabaseService.currentUser).thenReturn(null);
    when(() => mockSupabaseService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    sessionCubit = SessionCubit(
      authRepository: mockAuthRepository,
      supabaseService: mockSupabaseService,
    );
  });

  tearDown(() {
    sessionCubit.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      home: BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: child,
      ),
    );
  }

  group('LoginScreen Widget', () {
    testWidgets('renders all UI elements from Figma spec', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      expect(find.text('Faça o seu login'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Entrar com Google'), findsOneWidget);
      expect(find.text('Primeiro acesso? Crie sua conta aqui'), findsOneWidget);
    });

    testWidgets('shows validation errors when Continuar is pressed with empty fields', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.tap(find.text('Continuar'));
      await tester.pump();

      expect(find.text('Por favor, informe seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, informe sua senha'), findsOneWidget);
    });

    testWidgets('shows invalid email error when email format is invalid', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'invalid-email');
      await tester.tap(find.text('Continuar'));
      await tester.pump();

      expect(find.text('Informe um e-mail válido'), findsOneWidget);
    });

    testWidgets('submits email and password when fields are valid', (tester) async {
      when(() => mockAuthRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => const Failure(UserFailure(message: 'Error')));

      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.tap(find.text('Continuar'));
      await tester.pump();

      verify(() => mockAuthRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('triggers Google Sign-In when Entrar com Google is pressed', (tester) async {
      when(() => mockAuthRepository.signIn())
          .thenAnswer((_) async => const Failure(UserFailure(message: 'Error')));

      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      await tester.tap(find.text('Entrar com Google'));
      await tester.pump();

      verify(() => mockAuthRepository.signIn()).called(1);
    });

    testWidgets('triggers onForgotPasswordPressed and onCreateAccountPressed callbacks', (tester) async {
      bool forgotPressed = false;
      bool createPressed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          LoginScreen(
            onForgotPasswordPressed: () => forgotPressed = true,
            onCreateAccountPressed: () => createPressed = true,
          ),
        ),
      );

      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pump();
      expect(forgotPressed, isTrue);

      await tester.tap(find.text('Primeiro acesso? Crie sua conta aqui'));
      await tester.pump();
      expect(createPressed, isTrue);
    });

    testWidgets('displays email confirmation SnackBar on SessionError', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      sessionCubit.emit(const SessionError(message: 'email not confirmed'));
      await tester.pump();

      expect(find.text('Por favor, confirme seu e-mail antes de logar.'), findsOneWidget);
    });

    testWidgets('displays generic error SnackBar on SessionError', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      sessionCubit.emit(const SessionError(message: 'Credenciais inválidas'));
      await tester.pump();

      expect(find.text('Credenciais inválidas'), findsOneWidget);
    });
  });
}
