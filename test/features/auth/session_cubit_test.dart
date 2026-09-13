import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/session_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockAuthRepository mockAuthRepository;
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

  const mockSupabaseUser = User(
    id: 'user-123',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2026-01-01',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSupabaseService = MockSupabaseService();

    when(() => mockSupabaseService.currentUser).thenReturn(null);
    when(() => mockSupabaseService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    sessionCubit = SessionCubit(
      authRepository: mockAuthRepository,
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
      'emits [LoadingSession, SessionError, GuestSession] when authRepository.signIn fails',
      build: () {
        when(() => mockAuthRepository.signIn())
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
        when(() => mockAuthRepository.signIn())
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
        when(() => mockAuthRepository.signIn())
            .thenAnswer((_) async => const Success(testUserEntity));
        when(() => mockSupabaseService.currentUser).thenReturn(mockSupabaseUser);
        when(() => mockAuthRepository.getUserProfile('user-123'))
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
      'emits [LoadingSession, SessionError, GuestSession] when authRepository.signInWithEmailAndPassword fails',
      build: () {
        when(
          () => mockAuthRepository.signInWithEmailAndPassword(
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
          () => mockAuthRepository.signInWithEmailAndPassword(
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
        when(() => mockAuthRepository.getUserProfile('user-123'))
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
        when(() => mockAuthRepository.getUserProfile('user-123'))
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
        when(() => mockAuthRepository.getUserProfile('user-123'))
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

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, AuthenticatedSession] when authenticateWithEmail succeeds and currentUser is present',
      build: () {
        when(
          () => mockAuthRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => const Success(testUserEntity));
        when(() => mockSupabaseService.currentUser).thenReturn(mockSupabaseUser);
        when(() => mockAuthRepository.getUserProfile('user-123'))
            .thenAnswer((_) async => const Success(testProfile));
        return sessionCubit;
      },
      act: (cubit) => cubit.authenticateWithEmail(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const LoadingSession(),
        const AuthenticatedSession(user: testUserEntity, profile: testProfile),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, SessionError, GuestSession] when signUpWithEmail fails',
      build: () {
        when(
          () => mockAuthRepository.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer(
          (_) async => const Failure(UserFailure(message: 'Sign up failed')),
        );
        return sessionCubit;
      },
      act: (cubit) => cubit.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const LoadingSession(),
        const SessionError(message: 'Sign up failed'),
        const GuestSession(),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, GuestSession] when signUpWithEmail succeeds but currentUser is null',
      build: () {
        when(
          () => mockAuthRepository.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => const Success(testUserEntity));
        when(() => mockSupabaseService.currentUser).thenReturn(null);
        return sessionCubit;
      },
      act: (cubit) => cubit.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const LoadingSession(),
        const GuestSession(),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [LoadingSession, AuthenticatedSession] when signUpWithEmail succeeds with currentUser',
      build: () {
        when(
          () => mockAuthRepository.signUpWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => const Success(testUserEntity));
        when(() => mockSupabaseService.currentUser).thenReturn(mockSupabaseUser);
        when(() => mockAuthRepository.getUserProfile('user-123'))
            .thenAnswer((_) async => const Success(testProfile));
        return sessionCubit;
      },
      act: (cubit) => cubit.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
      ),
      expect: () => [
        const LoadingSession(),
        const AuthenticatedSession(user: testUserEntity, profile: testProfile),
      ],
    );

    test('initial currentUser check triggers checkUserProfile when currentUser is present', () async {
      when(() => mockSupabaseService.currentUser).thenReturn(mockSupabaseUser);
      when(() => mockAuthRepository.getUserProfile('user-123'))
          .thenAnswer((_) async => const Success(testProfile));

      final activeCubit = SessionCubit(
        authRepository: mockAuthRepository,
        supabaseService: mockSupabaseService,
      );

      await pumpEventQueue();

      verify(() => mockAuthRepository.getUserProfile('user-123')).called(1);
      await activeCubit.close();
    });

    test('listens to authStateChanges signedIn event and triggers checkUserProfile', () async {
      final controller = StreamController<AuthState>();
      when(() => mockSupabaseService.authStateChanges)
          .thenAnswer((_) => controller.stream);
      when(() => mockAuthRepository.getUserProfile('user-123'))
          .thenAnswer((_) async => const Success(testProfile));

      final newCubit = SessionCubit(
        authRepository: mockAuthRepository,
        supabaseService: mockSupabaseService,
      );

      final mockSession = Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: mockSupabaseUser,
      );

      controller.add(AuthState(AuthChangeEvent.signedIn, mockSession));
      await pumpEventQueue();

      verify(() => mockAuthRepository.getUserProfile('user-123')).called(1);
      await newCubit.close();
      await controller.close();
    });

    test('listens to authStateChanges signedOut event and emits GuestSession', () async {
      final controller = StreamController<AuthState>();
      when(() => mockSupabaseService.authStateChanges)
          .thenAnswer((_) => controller.stream);

      final newCubit = SessionCubit(
        authRepository: mockAuthRepository,
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
