import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/http/http_dependencies.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/supabase/supabase_service_impl.dart';
import 'package:mobile/features/auth/data/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/claim_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DependenciesContainer {
  DependenciesContainer() {
    serviceLocator.allowReassignment = true;
    final environment = Environment.instance;

    ApiDependencies(baseUrl: environment.baseUrl);

    serviceLocator
      ..registerSingleton<Environment>(environment)
      ..registerSingleton<GoogleSignIn>(GoogleSignIn.instance)
      ..registerLazySingleton<SupabaseService>(
        () => SupabaseServiceImpl(Supabase.instance.client),
      );

    serviceLocator<GoogleSignIn>().initialize(
      clientId: environment.iosClientId,
    );

    serviceLocator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        supabaseService: serviceLocator<SupabaseService>(),
        googleSignInClient: serviceLocator<GoogleSignIn>(),
      ),
    );

    serviceLocator.registerLazySingleton<UserSignInUseCase>(
      () => UserSignInUseCaseImpl(repository: serviceLocator<AuthRepository>()),
    );

    serviceLocator.registerLazySingleton<UserSignInWithEmailUseCase>(
      () => UserSignInWithEmailUseCaseImpl(
        repository: serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetUserProfileUseCase>(
      () => GetUserProfileUseCaseImpl(
        repository: serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ClaimProfileUseCase>(
      () =>
          ClaimProfileUseCaseImpl(repository: serviceLocator<AuthRepository>()),
    );

    serviceLocator.registerFactory<SessionCubit>(
      () => SessionCubit(
        userSignInUseCase: serviceLocator<UserSignInUseCase>(),
        userSignInWithEmailUseCase: serviceLocator<UserSignInWithEmailUseCase>(),
        getUserProfileUseCase: serviceLocator<GetUserProfileUseCase>(),
        supabaseService: serviceLocator<SupabaseService>(),
      ),
    );
  }
}
