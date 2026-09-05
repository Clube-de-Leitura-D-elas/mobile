import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/usecases/claim_profile_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_state.dart';

class ClaimTokenCubit extends Cubit<ClaimTokenState> {
  final ClaimProfileUseCase claimProfileUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;

  ClaimTokenCubit({
    required this.claimProfileUseCase,
    required this.getUserProfileUseCase,
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

    final claimResult = await claimProfileUseCase(cleanToken);

    if (claimResult case Failure(:final failure)) {
      debugPrint('[ClaimTokenCubit] claimProfile failed: ${failure.message}');
      emit(ClaimTokenFailure(failure.message));
      return;
    }

    debugPrint('[ClaimTokenCubit] claimProfile succeeded! Re-fetching profile for userId: $userId');
    final profileResult = await getUserProfileUseCase(userId);

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
