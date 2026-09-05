import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSignInUseCase extends Mock implements UserSignInUseCase {}
class MockUserSignInWithEmailUseCase extends Mock implements UserSignInWithEmailUseCase {}
class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockUserSignInUseCase mockUserSignInUseCase;
  late MockUserSignInWithEmailUseCase mockUserSignInWithEmailUseCase;
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;
  late MockSupabaseService mockSupabaseService;
  late SessionCubit sessionCubit;

  setUp(() {
    mockUserSignInUseCase = MockUserSignInUseCase();
    mockUserSignInWithEmailUseCase = MockUserSignInWithEmailUseCase();
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    mockSupabaseService = MockSupabaseService();

    when(() => mockSupabaseService.currentUser).thenReturn(null);
    when(() => mockSupabaseService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    sessionCubit = SessionCubit(
      userSignInUseCase: mockUserSignInUseCase,
      userSignInWithEmailUseCase: mockUserSignInWithEmailUseCase,
      getUserProfileUseCase: mockGetUserProfileUseCase,
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
  });
}
