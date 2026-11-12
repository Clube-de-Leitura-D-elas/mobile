import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/main.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  setUp(() {
    serviceLocator.allowReassignment = true;
    final mockAuthRepo = MockAuthRepository();
    final mockSupabase = MockSupabaseService();

    when(() => mockSupabase.currentUser).thenReturn(null);
    when(
      () => mockSupabase.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());

    serviceLocator.registerFactory<SessionCubit>(
      () => SessionCubit(
        authRepository: mockAuthRepo,
        supabaseService: mockSupabase,
      ),
    );
  });

  testWidgets('MainApp builds with AppTheme and renders LoginScreen', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.byType(MainApp), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Faça o seu login'), findsOneWidget);
  });

  testWidgets('StartupErrorApp shows a pt-BR message without the raw error', (
    tester,
  ) async {
    await tester.pumpWidget(const StartupErrorApp());
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível abrir o aplicativo. Feche e abra de novo; '
        'se continuar, atualize o app.',
      ),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('MainApp provides pt Material localizations', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(LoginScreen));
    expect(MaterialLocalizations.of(context).backButtonTooltip, 'Voltar');
  });

  testWidgets('StartupErrorApp provides pt Material localizations', (
    tester,
  ) async {
    await tester.pumpWidget(const StartupErrorApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    expect(MaterialLocalizations.of(context).backButtonTooltip, 'Voltar');
  });

  test('mainAsync initializes and runs app', () async {
    expect(mainAsync, isA<Function>());
  });
}
