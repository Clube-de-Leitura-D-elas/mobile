import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:mobile/features/groups/domain/entities/group_entity.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/pages/home_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSupabaseService extends Mock implements SupabaseService {}

class MockGroupRepository extends Mock implements GroupRepository {}

class TestSessionCubit extends SessionCubit {
  TestSessionCubit({
    required super.authRepository,
    required super.supabaseService,
  });

  void setStateForTest(SessionState state) => emit(state);
}

void main() {
  const user = UserEntity(
    name: 'Ana',
    mail: 'ana@example.com',
    birthday: '01/01/2000',
    phoneNumber: '123',
    instagramUser: '@ana',
    educationDegree: 'Graduação',
    jobPosition: 'Leitora',
    cityZone: (id: '', name: '', acronym: ''),
  );
  const profile = UserProfileEntity(
    id: 'profile-1',
    name: 'Ana',
    email: 'ana@example.com',
    address: 'Rua A',
    phoneNumber: '123',
    birthday: '01/01/2000',
    instagram: '@ana',
    educationDegree: 'Graduação',
    jobPosition: 'Leitora',
    userId: 'auth-1',
    isActive: true,
  );

  testWidgets('redirects from Home to Login after temporary exit', (
    tester,
  ) async {
    final authRepository = MockAuthRepository();
    final supabaseService = MockSupabaseService();
    final groupRepository = MockGroupRepository();
    when(() => supabaseService.currentUser).thenReturn(null);
    when(
      () => supabaseService.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => supabaseService.signOut(),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => groupRepository.getMyGroups(),
    ).thenAnswer((_) async => const Success(<GroupEntity>[]));

    await serviceLocator.reset();
    serviceLocator.registerFactory<HomeCubit>(
      () => HomeCubit(groupRepository: groupRepository),
    );
    final sessionCubit = TestSessionCubit(
      authRepository: authRepository,
      supabaseService: supabaseService,
    );
    addTearDown(() async {
      await sessionCubit.close();
      await serviceLocator.reset();
    });
    sessionCubit.setStateForTest(
      const AuthenticatedSession(user: user, profile: profile),
    );

    final router = AppRoutes.createRouter(sessionCubit);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<SessionCubit>.value(
        value: sessionCubit,
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    verify(() => supabaseService.signOut()).called(1);
  });
}
