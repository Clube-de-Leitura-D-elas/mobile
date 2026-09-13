import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_state.dart';

class ClaimTokenCubit extends Cubit<ClaimTokenState> {
  final AuthRepository authRepository;

  ClaimTokenCubit({
    required this.authRepository,
  }) : super(const ClaimTokenInitial());

  Future<void> submitToken({
    required String claimToken,
    required String userId,
  }) async {
    final cleanToken = claimToken.trim();
    debugPrint('[ClaimTokenCubit] Submitting claimToken "$cleanToken" for userId: $userId');

    if (cleanToken.isEmpty) {
      debugPrint('[ClaimTokenCubit] Empty token submitted');
      emit(const ClaimTokenFailure('Por favor, informe o token de acesso.'));
      return;
    }

    emit(const ClaimTokenLoading());

    final claimResult = await authRepository.claimProfile(cleanToken);

    if (claimResult case Failure(:final failure)) {
      debugPrint('[ClaimTokenCubit] claimProfile failed: ${failure.message}');
      emit(ClaimTokenFailure(failure.message));
      return;
    }

    debugPrint('[ClaimTokenCubit] claimProfile succeeded! Re-fetching profile for userId: $userId');
    final profileResult = await authRepository.getUserProfile(userId);

    if (profileResult case Failure(:final failure)) {
      debugPrint('[ClaimTokenCubit] Profile re-fetch failed: ${failure.message}');
      emit(const ClaimTokenSuccess(profile: null));
      return;
    }

    final profile = profileResult.unwrap();
    debugPrint('[ClaimTokenCubit] Profile re-fetch result: $profile');
    emit(ClaimTokenSuccess(profile: profile));
  }
}
