import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/http/http_dependencies.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/supabase/supabase_service_impl.dart';
import 'package:mobile/features/auth/data/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/groups/data/repositories/group_participants_repository_impl.dart';
import 'package:mobile/features/groups/data/repositories/group_repository_impl.dart';
import 'package:mobile/features/groups/domain/repository/group_participants_repository.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_participants_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:mobile/features/onboarding/domain/repository/onboarding_repository.dart';

GroupRepository _createGroupRepository() =>
    GroupRepositoryImpl(supabaseService: serviceLocator<SupabaseService>());

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

    serviceLocator.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        supabaseService: serviceLocator<SupabaseService>(),
      ),
    );

    serviceLocator.registerLazySingleton<GroupRepository>(
      _createGroupRepository,
    );
    serviceLocator.registerFactory<GroupDetailsCubit>(
      () =>
          GroupDetailsCubit(groupRepository: serviceLocator<GroupRepository>()),
    );
    serviceLocator.registerFactory<EventHistoryCubit>(
      () =>
          EventHistoryCubit(groupRepository: serviceLocator<GroupRepository>()),
    );
    serviceLocator.registerFactory<MeetingDetailsCubit>(
      () => MeetingDetailsCubit(
        groupRepository: serviceLocator<GroupRepository>(),
      ),
    );
    serviceLocator.registerLazySingleton<GroupParticipantsRepository>(
      () => GroupParticipantsRepositoryImpl(
        supabaseService: serviceLocator<SupabaseService>(),
      ),
    );
    serviceLocator.registerFactory<GroupParticipantsCubit>(
      () => GroupParticipantsCubit(
        participantsRepository: serviceLocator<GroupParticipantsRepository>(),
      ),
    );

    serviceLocator.registerFactory<SessionCubit>(
      () => SessionCubit(
        authRepository: serviceLocator<AuthRepository>(),
        supabaseService: serviceLocator<SupabaseService>(),
      ),
    );

    serviceLocator.registerFactory<HomeCubit>(() => HomeCubit());
  }
}
