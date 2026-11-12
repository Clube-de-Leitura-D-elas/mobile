import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile/features/auth/presentation/cubit/claim_token_state.dart';

class ClaimTokenCubit extends Cubit<ClaimTokenState> {
  final AuthRepository authRepository;

  ClaimTokenCubit({required this.authRepository})
    : super(const ClaimTokenInitial());

  Future<void> submitToken({
    required String claimToken,
    required String userId,
  }) async {
    final cleanToken = claimToken.trim();
    if (kDebugMode) {
      debugPrint('[ClaimTokenCubit] Submitting claimToken for userId: $userId');
    }

    if (cleanToken.isEmpty) {
      if (kDebugMode) {
        debugPrint('[ClaimTokenCubit] Empty token submitted');
      }
      // O emit ignora estado igual ao atual: sem isso, o segundo toque com o
      // campo vazio não mostra o aviso.
      if (state is ClaimTokenEmpty) emit(const ClaimTokenInitial());
      emit(const ClaimTokenEmpty());
      return;
    }

    emit(const ClaimTokenLoading());

    final claimResult = await authRepository.claimProfile(cleanToken);

    if (claimResult case Failure(:final failure)) {
      if (kDebugMode) {
        debugPrint('[ClaimTokenCubit] claimProfile failed: $failure');
      }
      emit(ClaimTokenFailure(failure));
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[ClaimTokenCubit] claimProfile succeeded! Re-fetching profile for userId: $userId',
      );
    }
    final profileResult = await authRepository.getUserProfile(userId);

    if (profileResult case Failure(:final failure)) {
      if (kDebugMode) {
        debugPrint('[ClaimTokenCubit] Profile re-fetch failed: $failure');
      }
      emit(const ClaimTokenSuccess(profile: null));
      return;
    }

    final profile = profileResult.unwrap();
    if (kDebugMode) {
      debugPrint(
        '[ClaimTokenCubit] Profile re-fetch succeeded: ${profile != null}',
      );
    }
    emit(ClaimTokenSuccess(profile: profile));
  }
}
