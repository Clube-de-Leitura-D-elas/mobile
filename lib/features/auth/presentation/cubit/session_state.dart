import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class GuestSession extends SessionState {
  const GuestSession();
}

class LoadingSession extends SessionState {
  const LoadingSession();
}

class NeedsClaimSession extends SessionState {
  final String userId;
  final UserEntity? user;

  const NeedsClaimSession({required this.userId, this.user});

  @override
  List<Object?> get props => [userId, user];
}

class AuthenticatedSession extends SessionState {
  final UserEntity user;
  final UserProfileEntity? profile;

  const AuthenticatedSession({required this.user, this.profile});

  @override
  List<Object?> get props => [user, profile];
}

class SessionError extends SessionState {
  final String message;

  const SessionError({required this.message});

  @override
  List<Object?> get props => [message];
}
