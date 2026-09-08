import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/claim_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/user_sign_in_with_email_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  const testUser = UserEntity(
    name: 'Test User',
    mail: 'test@example.com',
    birthday: '01/01/2000',
    phoneNumber: '123',
    instagramUser: '@test',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    cityZone: (id: '', name: '', acronym: ''),
  );

  const testProfile = UserProfileEntity(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    address: 'Addr',
    phoneNumber: '123',
    birthday: '01/01/2000',
    instagram: '@test',
    educationDegree: 'Degree',
    jobPosition: 'Dev',
    userId: 'user-1',
    isActive: true,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('UserSignInUseCaseImpl', () {
    test('calls repository.signIn()', () async {
      when(() => mockRepository.signIn())
          .thenAnswer((_) async => const Success(testUser));

      final useCase = UserSignInUseCaseImpl(repository: mockRepository);
      final result = await useCase();

      expect(result.unwrap(), equals(testUser));
      verify(() => mockRepository.signIn()).called(1);
    });
  });

  group('UserSignInWithEmailUseCaseImpl', () {
    test('calls repository.signInWithEmailAndPassword()', () async {
      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => const Success(testUser));

      final useCase = UserSignInWithEmailUseCaseImpl(repository: mockRepository);
      final result = await useCase(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.unwrap(), equals(testUser));
      verify(
        () => mockRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });

  group('GetUserProfileUseCaseImpl', () {
    test('calls repository.getUserProfile()', () async {
      when(() => mockRepository.getUserProfile('user-1'))
          .thenAnswer((_) async => const Success(testProfile));

      final useCase = GetUserProfileUseCaseImpl(repository: mockRepository);
      final result = await useCase('user-1');

      expect(result.unwrap(), equals(testProfile));
      verify(() => mockRepository.getUserProfile('user-1')).called(1);
    });
  });

  group('ClaimProfileUseCaseImpl', () {
    test('calls repository.claimProfile()', () async {
      when(() => mockRepository.claimProfile('TOKEN123'))
          .thenAnswer((_) async => const Success(null));

      final useCase = ClaimProfileUseCaseImpl(repository: mockRepository);
      final result = await useCase('TOKEN123');

      expect(result, isA<Success<void, UserFailure>>());
      verify(() => mockRepository.claimProfile('TOKEN123')).called(1);
    });
  });
}
