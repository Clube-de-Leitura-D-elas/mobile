import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_response.dart';
import 'package:mobile/core/supabase/supabase_service_impl.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockFunctionsClient mockFunctionsClient;
  late SupabaseServiceImpl supabaseService;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockFunctionsClient = MockFunctionsClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);

    supabaseService = SupabaseServiceImpl(mockSupabaseClient);
  });

  group('SupabaseServiceImpl', () {
    test('currentUser delegates to client.auth.currentUser', () {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);
      expect(supabaseService.currentUser, isNull);
    });

    test('authStateChanges delegates to client.auth.onAuthStateChange', () {
      when(() => mockGoTrueClient.onAuthStateChange)
          .thenAnswer((_) => const Stream.empty());
      expect(supabaseService.authStateChanges, emitsDone);
    });

    test('signOut calls client.auth.signOut() successfully', () async {
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

      final result = await supabaseService.signOut();

      expect(result, isA<Success<void, SupabaseFailure>>());
      verify(() => mockGoTrueClient.signOut()).called(1);
    });

    test('signOut catches exception and returns Failure', () async {
      when(() => mockGoTrueClient.signOut()).thenThrow(Exception('Signout error'));

      final result = await supabaseService.signOut();

      expect(result, isA<Failure<void, SupabaseFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure, isA<UnknownSupabaseFailure>());
      }
    });

    test('signInWithPassword returns Success when user is returned', () async {
      const mockUser = User(
        id: 'user-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );
      final authResponse = AuthResponse(user: mockUser);

      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => authResponse);

      final result = await supabaseService.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<User, SupabaseFailure>>());
      if (result case Success(:final data)) {
        expect(data.id, 'user-1');
      }
    });

    test('signInWithPassword returns Failure when user is null', () async {
      final authResponse = AuthResponse(session: null, user: null);

      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => authResponse);

      final result = await supabaseService.signInWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
    });

    test('signInWithPassword handles AuthException', () async {
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'wrong',
        ),
      ).thenThrow(const AuthException('Invalid login credentials'));

      final result = await supabaseService.signInWithPassword(
        email: 'test@example.com',
        password: 'wrong',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure.message, equals('Invalid login credentials'));
      }
    });

    test('signInWithPassword handles generic Exception', () async {
      when(
        () => mockGoTrueClient.signInWithPassword(
          email: 'test@example.com',
          password: 'wrong',
        ),
      ).thenThrow(Exception('Network error'));

      final result = await supabaseService.signInWithPassword(
        email: 'test@example.com',
        password: 'wrong',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
    });

    test('signInWithIdToken returns Success when user is returned', () async {
      const mockUser = User(
        id: 'user-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );
      final authResponse = AuthResponse(user: mockUser);

      when(
        () => mockGoTrueClient.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'token123',
          accessToken: 'access123',
        ),
      ).thenAnswer((_) async => authResponse);

      final result = await supabaseService.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: 'token123',
        accessToken: 'access123',
      );

      expect(result, isA<Success<User, SupabaseFailure>>());
    });

    test('signInWithIdToken returns Failure when user is null', () async {
      final authResponse = AuthResponse(session: null, user: null);

      when(
        () => mockGoTrueClient.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'token123',
          accessToken: null,
        ),
      ).thenAnswer((_) async => authResponse);

      final result = await supabaseService.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: 'token123',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
    });

    test('signInWithIdToken handles AuthException', () async {
      when(
        () => mockGoTrueClient.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'token123',
          accessToken: null,
        ),
      ).thenThrow(const AuthException('Invalid ID Token'));

      final result = await supabaseService.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: 'token123',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure.message, equals('Invalid ID Token'));
      }
    });

    test('signInWithIdToken handles generic Exception', () async {
      when(
        () => mockGoTrueClient.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: 'token123',
          accessToken: null,
        ),
      ).thenThrow(Exception('Unknown token error'));

      final result = await supabaseService.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: 'token123',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
    });

    test('invokeFunction returns Success with decoded data', () async {
      when(
        () => mockFunctionsClient.invoke(
          'get-profile',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const FunctionResponse(
          status: 200,
          data: {'name': 'Test'},
        ),
      );

      final result = await supabaseService.invokeFunction<String>(
        functionName: 'get-profile',
        decoder: (json) => json['name'] as String,
      );

      expect(result, isA<Success<SupabaseResponse<String>, SupabaseFailure>>());
      if (result case Success(:final data)) {
        expect(data.data, 'Test');
        expect(data.statusCode, 200);
      }
    });

    test('invokeFunction handles status 400+ without error key in data', () async {
      when(
        () => mockFunctionsClient.invoke(
          'test-func',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const FunctionResponse(
          status: 404,
          data: 'Not found',
        ),
      );

      final result = await supabaseService.invokeFunction(
        functionName: 'test-func',
      );

      expect(result, isA<Failure<SupabaseResponse<dynamic>, SupabaseFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure.message, equals('Erro ao executar a função test-func'));
      }
    });

    test('invokeFunction handles FunctionException without error key in details', () async {
      when(
        () => mockFunctionsClient.invoke(
          'test-func',
          body: any(named: 'body'),
        ),
      ).thenThrow(
        const FunctionException(
          status: 500,
          details: 'Plain string details',
        ),
      );

      final result = await supabaseService.invokeFunction(
        functionName: 'test-func',
      );

      expect(result, isA<Failure<SupabaseResponse<dynamic>, SupabaseFailure>>());
    });

    test('signUpWithPassword returns Success when user is returned', () async {
      const mockUser = User(
        id: 'user-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );
      final authResponse = AuthResponse(user: mockUser);

      when(
        () => mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => authResponse);

      final result = await supabaseService.signUpWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<User, SupabaseFailure>>());
    });

    test('signUpWithPassword returns Failure when user is null', () async {
      final authResponse = AuthResponse(session: null, user: null);

      when(
        () => mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => authResponse);

      final result = await supabaseService.signUpWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
    });

    test('signUpWithPassword handles AuthException', () async {
      when(
        () => mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenThrow(const AuthException('User already registered'));

      final result = await supabaseService.signUpWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
    });

    test('signUpWithPassword handles generic Exception', () async {
      when(
        () => mockGoTrueClient.signUp(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenThrow(Exception('Signup network error'));

      final result = await supabaseService.signUpWithPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Failure<User, SupabaseFailure>>());
    });

    test('invokeFunction parses error message from data map when status >= 400', () async {
      when(
        () => mockFunctionsClient.invoke(
          'test-func',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const FunctionResponse(
          status: 400,
          data: {'error': 'Bad Request Error'},
        ),
      );

      final result = await supabaseService.invokeFunction(
        functionName: 'test-func',
      );

      expect(result, isA<Failure<SupabaseResponse<dynamic>, SupabaseFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure.message, equals('Bad Request Error'));
      }
    });

    test('invokeFunction casts data as T when decoder is null', () async {
      when(
        () => mockFunctionsClient.invoke(
          'test-func',
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const FunctionResponse(
          status: 200,
          data: {'key': 'value'},
        ),
      );

      final result = await supabaseService.invokeFunction<Map<String, dynamic>>(
        functionName: 'test-func',
      );

      expect(result, isA<Success<SupabaseResponse<Map<String, dynamic>>, SupabaseFailure>>());
    });

    test('invokeFunction parses error message from FunctionException details map', () async {
      when(
        () => mockFunctionsClient.invoke(
          'test-func',
          body: any(named: 'body'),
        ),
      ).thenThrow(
        const FunctionException(
          status: 500,
          details: {'error': 'Internal Exception Error'},
        ),
      );

      final result = await supabaseService.invokeFunction(
        functionName: 'test-func',
      );

      expect(result, isA<Failure<SupabaseResponse<dynamic>, SupabaseFailure>>());
      if (result case Failure(:final failure)) {
        expect(failure.message, equals('Internal Exception Error'));
      }
    });

    test('invokeFunction handles generic Exception', () async {
      when(
        () => mockFunctionsClient.invoke(
          'test-func',
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('Connection failure'));

      final result = await supabaseService.invokeFunction(
        functionName: 'test-func',
      );

      expect(result, isA<Failure<SupabaseResponse<dynamic>, SupabaseFailure>>());
    });
  });

  group('SupabaseResponse and SupabaseFailure models', () {
    test('SupabaseResponse props and getter', () {
      const resp = SupabaseResponse<String>(data: 'hello', statusCode: 200);
      expect(resp.data, 'hello');
      expect(resp.statusCode, 200);
      expect(resp.isSuccess, isTrue);
      expect(resp.props, equals(const ['hello', 200, null]));
    });

    test('SupabaseFailure subclasses props', () {
      const funcFail = FunctionSupabaseFailure(
        message: 'msg',
        code: '500',
        details: {'key': 'val'},
      );
      expect(funcFail.props, equals(const ['msg', '500', {'key': 'val'}]));

      const authFail = AuthSupabaseFailure(message: 'auth msg', code: '401');
      expect(authFail.props, equals(const ['auth msg', '401', null]));

      const unkFail = UnknownSupabaseFailure(message: 'unk msg');
      expect(unkFail.props, equals(const ['unk msg', null, null]));

      const notFoundFail = NotFoundSupabaseFailure();
      expect(notFoundFail.props, equals(const ['Registro não encontrado', null, null]));
    });
  });
}
