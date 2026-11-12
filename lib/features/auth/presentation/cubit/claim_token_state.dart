import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';

sealed class ClaimTokenState extends Equatable {
  const ClaimTokenState();

  @override
  List<Object?> get props => [];
}

class ClaimTokenInitial extends ClaimTokenState {
  const ClaimTokenInitial();
}

class ClaimTokenLoading extends ClaimTokenState {
  const ClaimTokenLoading();
}

class ClaimTokenSuccess extends ClaimTokenState {
  final UserProfileEntity? profile;

  const ClaimTokenSuccess({this.profile});

  @override
  List<Object?> get props => [profile];
}

/// O botão foi tocado com o campo vazio.
class ClaimTokenEmpty extends ClaimTokenState {
  const ClaimTokenEmpty();
}

class ClaimTokenFailure extends ClaimTokenState {
  final UserFailure failure;

  const ClaimTokenFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
