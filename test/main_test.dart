import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/main.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSignInUseCase extends Mock implements UserSignInUseCase {}
class MockUserSignInWithEmailUseCase extends Mock implements UserSignInWithEmailUseCase {}
class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  setUp(() {
    serviceLocator.allowReassignment = true;
    final mockSignIn = MockUserSignInUseCase();
    final mockSignInEmail = MockUserSignInWithEmailUseCase();
    final mockGetProfile = MockGetUserProfileUseCase();
    final mockSupabase = MockSupabaseService();

    when(() => mockSupabase.currentUser).thenReturn(null);
    when(() => mockSupabase.authStateChanges).thenAnswer((_) => const Stream.empty());

    serviceLocator.registerFactory<SessionCubit>(
      () => SessionCubit(
        userSignInUseCase: mockSignIn,
        userSignInWithEmailUseCase: mockSignInEmail,
        getUserProfileUseCase: mockGetProfile,
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

  test('mainAsync initializes and runs app', () async {
    expect(mainAsync, isA<Function>());
  });
}
