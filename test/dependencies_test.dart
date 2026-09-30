// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/groups/data/repositories/group_participants_repository_impl.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  test(
    'DependenciesContainer registers all singletons and factories',
    () async {
      await Supabase.initialize(
        url: 'http://localhost:54321',
        publishableKey: 'test-key',
        accessToken: () async => 'test-token',
        debug: false,
      );

      DependenciesContainer();

      expect(serviceLocator.isRegistered<Environment>(), isTrue);
      expect(serviceLocator.isRegistered<SupabaseService>(), isTrue);
      expect(serviceLocator.isRegistered<AuthRepository>(), isTrue);
      expect(serviceLocator.isRegistered<SessionCubit>(), isTrue);
      expect(serviceLocator.isRegistered<GroupRepository>(), isTrue);
      expect(serviceLocator<GroupRepository>(), isA<GroupRepositoryImpl>());
      expect(
        serviceLocator<GroupParticipantsRepository>(),
        isA<GroupParticipantsRepositoryImpl>(),
      );
      expect(serviceLocator.isRegistered<GroupParticipantsCubit>(), isTrue);
    },
  );
}
