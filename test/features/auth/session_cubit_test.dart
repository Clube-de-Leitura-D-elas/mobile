import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  const testUserEntity = UserEntity(
    name: 'John Doe',
    mail: 'john@example.com',
    birthday: '01/01/2000',
    phoneNumber: '123',
    instagramUser: '@john',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    cityZone: (id: '', name: '', acronym: ''),
  );

  const testProfile = UserProfileEntity(
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    address: 'Address',
    phoneNumber: '123',
    birthday: '01/01/2000',
    instagram: '@john',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    userId: 'user-123',
    isActive: true,
  );

  final mockSupabaseUser = User(
    id: 'user-123',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-01-01',
  );

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

  group('SessionCubit', () {
    test('initial state is GuestSession', () {
      expect(sessionCubit.state, equals(const GuestSession()));
    });

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, SessionError, GuestSession] when userSignInUseCase fails',
      build: () {
        when(() => mockUserSignInUseCase())
            .thenAnswer((_) async => const Failure(UserFailure(message: 'Sign in failed')));
        return sessionCubit;
      },
      act: (cubit) => cubit.authenticate(),
      expect: () => [
        const LoadingSession(),
        const SessionError(message: 'Sign in failed'),
        const GuestSession(),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, GuestSession] when authenticate succeeds but currentUser is null',
      build: () {
        when(() => mockUserSignInUseCase())
            .thenAnswer((_) async => const Success(testUserEntity));
        when(() => mockSupabaseService.currentUser).thenReturn(null);
        return sessionCubit;
      },
      act: (cubit) => cubit.authenticate(),
      expect: () => [
        const LoadingSession(),
        const GuestSession(),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, AuthenticatedSession] when authenticate succeeds and profile exists',
      build: () {
        when(() => mockUserSignInUseCase())
            .thenAnswer((_) async => const Success(testUserEntity));
        when(() => mockSupabaseService.currentUser).thenReturn(mockSupabaseUser);
        when(() => mockGetUserProfileUseCase('user-123'))
            .thenAnswer((_) async => const Success(testProfile));
        return sessionCubit;
      },
      act: (cubit) => cubit.authenticate(),
      expect: () => [
        const LoadingSession(),
        const AuthenticatedSession(user: testUserEntity, profile: testProfile),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, SessionError, GuestSession] when userSignInWithEmailUseCase fails',
      build: () {
        when(
          () => mockUserSignInWithEmailUseCase(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer(
          (_) async => const Failure(UserFailure(message: 'Invalid credentials')),
        );
        return sessionCubit;
      },
      act: (cubit) => cubit.authenticateWithEmail(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const LoadingSession(),
        const SessionError(message: 'Invalid credentials'),
        const GuestSession(),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, GuestSession] when authenticateWithEmail succeeds but currentUser is null',
      build: () {
        when(
          () => mockUserSignInWithEmailUseCase(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => const Success(testUserEntity));
        when(() => mockSupabaseService.currentUser).thenReturn(null);
        return sessionCubit;
      },
      act: (cubit) => cubit.authenticateWithEmail(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const LoadingSession(),
        const GuestSession(),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, NeedsClaimSession] when getUserProfile fails',
      build: () {
        when(() => mockGetUserProfileUseCase('user-123'))
            .thenAnswer((_) async => const Failure(UserFailure(message: 'Error')));
        return sessionCubit;
      },
      act: (cubit) => cubit.checkUserProfile('user-123'),
      expect: () => [
        const LoadingSession(),
        const NeedsClaimSession(userId: 'user-123'),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, NeedsClaimSession] when getUserProfile returns null',
      build: () {
        when(() => mockGetUserProfileUseCase('user-123'))
            .thenAnswer((_) async => const Success(null));
        return sessionCubit;
      },
      act: (cubit) => cubit.checkUserProfile('user-123'),
      expect: () => [
        const LoadingSession(),
        const NeedsClaimSession(userId: 'user-123'),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, AuthenticatedSession] when getUserProfile returns profile data',
      build: () {
        when(() => mockGetUserProfileUseCase('user-123'))
            .thenAnswer((_) async => const Success(testProfile));
        return sessionCubit;
      },
      act: (cubit) => cubit.checkUserProfile('user-123'),
      expect: () => [
        const LoadingSession(),
        const AuthenticatedSession(
          user: testUserEntity,
          profile: testProfile,
        ),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, GuestSession] and calls supabaseService.signOut() when logOut is called',
      build: () {
        when(() => mockSupabaseService.signOut())
            .thenAnswer((_) async => const Success(null));
        return sessionCubit;
      },
      act: (cubit) => cubit.logOut(),
      expect: () => [
        const LoadingSession(),
        const GuestSession(),
      ],
      verify: (_) {
        verify(() => mockSupabaseService.signOut()).called(1);
      },
    );

    test('reset calls logOut', () async {
      when(() => mockSupabaseService.signOut())
          .thenAnswer((_) async => const Success(null));

      sessionCubit.reset();

      verify(() => mockSupabaseService.signOut()).called(1);
    });

    test('listens to authStateChanges signedOut event and emits GuestSession', () async {
      final controller = StreamController<AuthState>();
      when(() => mockSupabaseService.authStateChanges)
          .thenAnswer((_) => controller.stream);

      final newCubit = SessionCubit(
        userSignInUseCase: mockUserSignInUseCase,
        userSignInWithEmailUseCase: mockUserSignInWithEmailUseCase,
        getUserProfileUseCase: mockGetUserProfileUseCase,
        supabaseService: mockSupabaseService,
      );

      controller.add(const AuthState(AuthChangeEvent.signedOut, null));
      await pumpEventQueue();

      expect(newCubit.state, equals(const GuestSession()));
      await newCubit.close();
      await controller.close();
    });
  });
}
