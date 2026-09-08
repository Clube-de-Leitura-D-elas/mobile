import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/claim_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGoogleSignInPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleSignInPlatform {
  @override
  Future<void> init(InitParameters params) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:8080');
    GoogleSignInPlatform.instance = MockGoogleSignInPlatform();
    await serviceLocator.reset();
  });

  tearDown(() async {
    await serviceLocator.reset();
  });

  test('DependenciesContainer registers all singletons and factories', () {
    DependenciesContainer();

    expect(serviceLocator.isRegistered<Environment>(), isTrue);
    expect(serviceLocator.isRegistered<SupabaseService>(), isTrue);
    expect(serviceLocator.isRegistered<AuthRepository>(), isTrue);
    expect(serviceLocator.isRegistered<UserSignInUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<UserSignInWithEmailUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<GetUserProfileUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<ClaimProfileUseCase>(), isTrue);
    expect(serviceLocator.isRegistered<SessionCubit>(), isTrue);
  });
}
