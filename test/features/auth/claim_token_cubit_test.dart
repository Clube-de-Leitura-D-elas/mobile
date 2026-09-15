import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ClaimTokenCubit claimTokenCubit;

  const testProfile = UserProfileEntity(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    address: 'Address 1',
    phoneNumber: '123456789',
    birthday: '01/01/2000',
    instagram: '@test',
    educationDegree: 'Superior',
    jobPosition: 'Dev',
    userId: 'user-1',
    isActive: true,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    claimTokenCubit = ClaimTokenCubit(
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    claimTokenCubit.close();
  });

  group('ClaimTokenCubit', () {
    test('initial state is ClaimTokenInitial', () {
      expect(claimTokenCubit.state, equals(const ClaimTokenInitial()));
    });

    blocTest<ClaimTokenCubit, ClaimTokenState>(
      'emits ClaimTokenFailure when token is empty',
      build: () => claimTokenCubit,
      act: (cubit) => cubit.submitToken(claimToken: '', userId: 'user-1'),
      expect: () => [
        const ClaimTokenFailure('Por favor, informe o token de acesso.'),
      ],
    );

    blocTest<ClaimTokenCubit, ClaimTokenState>(
      'emits [ClaimTokenLoading, ClaimTokenFailure] when claim profile fails',
      build: () {
        when(() => mockAuthRepository.claimProfile('INVALID_TOKEN'))
            .thenAnswer((_) async => const Failure(UserFailure(message: 'Token inválido')));
        return claimTokenCubit;
      },
      act: (cubit) => cubit.submitToken(claimToken: 'INVALID_TOKEN', userId: 'user-1'),
      expect: () => [
        const ClaimTokenLoading(),
        const ClaimTokenFailure('Token inválido'),
      ],
    );

    blocTest<ClaimTokenCubit, ClaimTokenState>(
      'emits [ClaimTokenLoading, ClaimTokenSuccess] when claim profile succeeds',
      build: () {
        when(() => mockAuthRepository.claimProfile('VALID_TOKEN'))
            .thenAnswer((_) async => const Success(null));
        when(() => mockAuthRepository.getUserProfile('user-1'))
            .thenAnswer((_) async => const Success(testProfile));
        return claimTokenCubit;
      },
      act: (cubit) => cubit.submitToken(claimToken: 'VALID_TOKEN', userId: 'user-1'),
      expect: () => [
        const ClaimTokenLoading(),
        const ClaimTokenSuccess(profile: testProfile),
      ],
    );
  });
}
