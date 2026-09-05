import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/domain/usecases/claim_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_state.dart';
import 'package:mocktail/mocktail.dart';

class MockClaimProfileUseCase extends Mock implements ClaimProfileUseCase {}
class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}

void main() {
  late MockClaimProfileUseCase mockClaimProfileUseCase;
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;
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
    mockClaimProfileUseCase = MockClaimProfileUseCase();
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    claimTokenCubit = ClaimTokenCubit(
      claimProfileUseCase: mockClaimProfileUseCase,
      getUserProfileUseCase: mockGetUserProfileUseCase,
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
        when(() => mockClaimProfileUseCase('INVALID_TOKEN'))
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
        when(() => mockClaimProfileUseCase('VALID_TOKEN'))
            .thenAnswer((_) async => const Success(null));
        when(() => mockGetUserProfileUseCase('user-1'))
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
