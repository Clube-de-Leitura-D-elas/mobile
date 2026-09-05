import 'package:equatable/equatable.dart';
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

class ClaimTokenFailure extends ClaimTokenState {
  final String message;

  const ClaimTokenFailure(this.message);

  @override
  List<Object?> get props => [message];
}
