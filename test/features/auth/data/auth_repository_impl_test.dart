import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/data/auth_repository_impl.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseService extends Mock implements SupabaseService {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthorizationClient extends Mock
    implements GoogleSignInAuthorizationClient {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}
class MockGoogleSignInClientAuthorization extends Mock
    implements GoogleSignInClientAuthorization {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleAccount;
  late MockGoogleSignInAuthorizationClient mockAuthClient;
  late MockGoogleSignInAuthentication mockAuthentication;
  late MockGoogleSignInClientAuthorization mockAuthorization;
  late AuthRepositoryImpl repository;

  final testSupabaseUser = User(
    id: 'user-123',
    appMetadata: const {},
    userMetadata: const {'full_name': 'Test User'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: 'test@example.com',
  );

  const testProfile = UserProfileEntity(
    id: '1',
    name: 'Test Profile',
    email: 'test@example.com',
    address: 'Addr',
    phoneNumber: '123',
    birthday: '01/01/2000',
    instagram: '@test',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    userId: 'user-123',
    isActive: true,
  );

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleAccount = MockGoogleSignInAccount();
    mockAuthClient = MockGoogleSignInAuthorizationClient();
    mockAuthentication = MockGoogleSignInAuthentication();
    mockAuthorization = MockGoogleSignInClientAuthorization();

    repository = AuthRepositoryImpl(
      supabaseService: mockSupabaseService,
      googleSignInClient: mockGoogleSignIn,
    );
  });

  group('AuthRepositoryImpl', () {
    test('signIn returns Success when Google sign in and Supabase sign in succeed', () async {
      when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authorizationClient).thenReturn(mockAuthClient);
      when(() => mockGoogleAccount.authentication).thenReturn(mockAuthentication);
      when(() => mockAuthClient.authorizationForScopes(any())).thenAnswer((_) async => mockAuthorization);
      when(() => mockAuthorization.accessToken).thenReturn('access_token_123');
      when(() => mockAuthentication.idToken).thenReturn('id_token_123');

      when(
        () => mockSupabaseService.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'id_token_123',
          accessToken: 'access_token_123',
        ),
      ).thenAnswer((_) async => Success(testSupabaseUser));

      final result = await repository.signIn();

      expect(result, isA<Success<UserEntity, UserFailure>>());
      expect(result.unwrap().mail, 'test@example.com');
    });

    test('signIn returns MissingGoogleIdTokenFailure when idToken is null', () async {
      when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authorizationClient).thenReturn(mockAuthClient);
      when(() => mockGoogleAccount.authentication).thenReturn(mockAuthentication);
      when(() => mockAuthClient.authorizationForScopes(any())).thenAnswer((_) async => mockAuthorization);
      when(() => mockAuthentication.idToken).thenReturn(null);

      final result = await repository.signIn();

      expect(result, isA<Failure<UserEntity, UserFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure, isA<MissingGoogleIdTokenFailure>());
      }
    });

    test('signIn returns UserFailure when Supabase signInWithIdToken fails', () async {
      when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authorizationClient).thenReturn(mockAuthClient);
      when(() => mockGoogleAccount.authentication).thenReturn(mockAuthentication);
      when(() => mockAuthClient.authorizationForScopes(any())).thenAnswer((_) async => mockAuthorization);
      when(() => mockAuthorization.accessToken).thenReturn('access_token_123');
      when(() => mockAuthentication.idToken).thenReturn('id_token_123');

      when(
        () => mockSupabaseService.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'id_token_123',
          accessToken: 'access_token_123',
        ),
      ).thenAnswer((_) async => const Failure(AuthSupabaseFailure(message: 'OAuth Error')));

      final result = await repository.signIn();

      expect(result, isA<Failure<UserEntity, UserFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure.message, 'OAuth Error');
      }
    });

    test('signInWithEmailAndPassword returns Success on valid credentials', () async {
      when(
        () => mockSupabaseService.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => Success(testSupabaseUser));

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity, UserFailure>>());
      expect(result.unwrap().mail, equals('test@example.com'));
    });

    test('signInWithEmailAndPassword returns Failure when supabase fails', () async {
      when(
        () => mockSupabaseService.signInWithPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ).thenAnswer(
        (_) async => const Failure(AuthSupabaseFailure(message: 'Invalid credentials')),
      );

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect(result, isA<Failure<UserEntity, UserFailure>>());
    });

    test('signIn falls back to authorizeScopes when authorizationForScopes is null', () async {
      when(() => mockGoogleSignIn.authenticate()).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authorizationClient).thenReturn(mockAuthClient);
      when(() => mockGoogleAccount.authentication).thenReturn(mockAuthentication);
      when(() => mockAuthClient.authorizationForScopes(any())).thenAnswer((_) async => null);
      when(() => mockAuthClient.authorizeScopes(any())).thenAnswer((_) async => mockAuthorization);
      when(() => mockAuthorization.accessToken).thenReturn('access_token_123');
      when(() => mockAuthentication.idToken).thenReturn('id_token_123');

      when(
        () => mockSupabaseService.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'id_token_123',
          accessToken: 'access_token_123',
        ),
      ).thenAnswer((_) async => Success(testSupabaseUser));

      final result = await repository.signIn();

      expect(result, isA<Success<UserEntity, UserFailure>>());
    });

    test('signUpWithEmailAndPassword returns Success on valid credentials', () async {
      when(
        () => mockSupabaseService.signUpWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => Success(testSupabaseUser));

      final result = await repository.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity, UserFailure>>());
      expect(result.unwrap().mail, equals('test@example.com'));
    });

    test('signUpWithEmailAndPassword returns Failure when supabase fails', () async {
      when(
        () => mockSupabaseService.signUpWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer(
        (_) async => const Failure(AuthSupabaseFailure(message: 'Sign up error')),
      );

      final result = await repository.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Failure<UserEntity, UserFailure>>());
    });

    test('logOut signs out from Supabase and GoogleSignIn', () async {
      when(() => mockSupabaseService.signOut())
          .thenAnswer((_) async => const Success(null));
      when(() => mockGoogleSignIn.signOut())
          .thenAnswer((_) async => mockGoogleAccount);

      final result = await repository.logOut();

      expect(result, isA<Success<void, UserFailure>>());
      verify(() => mockSupabaseService.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });

    test('getUserProfile calls get-user-profile edge function and returns profile', () async {
      when(
        () => mockSupabaseService.invokeFunction<UserProfileEntity?>(
          functionName: 'get-user-profile',
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Success(
          SupabaseResponse<UserProfileEntity?>(data: testProfile, statusCode: 200),
        ),
      );

      final result = await repository.getUserProfile('user-123');

      expect(result, isA<Success<UserProfileEntity?, UserFailure>>());
      expect(result.unwrap(), equals(testProfile));
    });

    test('getUserProfile returns Failure when function invoke fails', () async {
      when(
        () => mockSupabaseService.invokeFunction<UserProfileEntity?>(
          functionName: 'get-user-profile',
          decoder: any(named: 'decoder'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(message: 'Server error'),
        ),
      );

      final result = await repository.getUserProfile('user-123');

      expect(result, isA<Failure<UserProfileEntity?, UserFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure.message, 'Server error');
      }
    });

    test('claimProfile calls claim-user-profile edge function', () async {
      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'claim-user-profile',
          body: const {'claim_token': 'TOKEN123'},
        ),
      ).thenAnswer(
        (_) async => const Success(
          SupabaseResponse<dynamic>(data: null, statusCode: 200),
        ),
      );

      final result = await repository.claimProfile('TOKEN123');

      expect(result, isA<Success<void, UserFailure>>());
    });

    test('claimProfile returns Failure when function invoke fails', () async {
      when(
        () => mockSupabaseService.invokeFunction<dynamic>(
          functionName: 'claim-user-profile',
          body: const {'claim_token': 'TOKEN123'},
        ),
      ).thenAnswer(
        (_) async => const Failure(
          FunctionSupabaseFailure(message: 'Invalid claim token'),
        ),
      );

      final result = await repository.claimProfile('TOKEN123');

      expect(result, isA<Failure<void, UserFailure>>());
    });
  });
}
