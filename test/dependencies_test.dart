// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/media/image_picker_photo_picker.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/password_validation_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/onboarding/presentation/cubit/onboarding_review_cubit.dart';
import 'package:mobile/features/groups/data/repositories/group_participants_repository_impl.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/place_search_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/raffles/data/datasources/raffle_remote_data_source.dart';
import 'package:mobile/features/raffles/data/repositories/raffle_repository_impl.dart';
import 'package:mobile/features/raffles/domain/repository/raffle_repository.dart';
import 'package:mobile/features/raffles/presentation/cubit/raffle_preparation_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences.setMockInitialValues({});
    await serviceLocator.reset();
  });

  tearDown(() async {
    await serviceLocator.reset();
  });

  test(
    'DependenciesContainer registers all singletons and factories',
    () async {
      try {
        await Supabase.initialize(
          url: 'http://localhost:54321',
          publishableKey: 'test-key',
          accessToken: () async => 'test-token',
          authOptions: const FlutterAuthClientOptions(
            localStorage: EmptyLocalStorage(),
          ),
          debug: false,
        );
      } catch (_) {}

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
      expect(serviceLocator<PhotoPicker>(), isA<ImagePickerPhotoPicker>());
      expect(serviceLocator<MeetingPhotosCubit>(), isA<MeetingPhotosCubit>());
      expect(serviceLocator<MeetingEditCubit>(), isA<MeetingEditCubit>());
      expect(serviceLocator<PlaceSearchCubit>(), isA<PlaceSearchCubit>());
      expect(serviceLocator<ClaimTokenCubit>(), isA<ClaimTokenCubit>());
      expect(
        serviceLocator<OnboardingReviewCubit>(),
        isA<OnboardingReviewCubit>(),
      );
      expect(
        serviceLocator<PasswordValidationCubit>(),
        isA<PasswordValidationCubit>(),
      );
      expect(
        serviceLocator<RaffleRemoteDataSource>(),
        isA<RaffleRemoteDataSourceImpl>(),
      );
      expect(
        serviceLocator<RaffleRepository>(),
        isA<RaffleRepositoryImpl>(),
      );
      expect(
        serviceLocator<RafflePreparationCubit>(),
        isA<RafflePreparationCubit>(),
      );
    },
  );
}
