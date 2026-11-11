import 'package:equatable/equatable.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_failure.dart';
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

enum SessionOperation { signIn, signUp }

/// Erro passageiro de login ou cadastro: a tela mostra um aviso e a sessão
/// volta para [GuestSession] logo em seguida.
class SessionError extends SessionState {
  final UserFailure failure;
  final SessionOperation operation;

  const SessionError({required this.failure, required this.operation});

  @override
  List<Object?> get props => [failure, operation];
}

/// A usuária está logada, mas o perfil não carregou (sem internet, servidor
/// fora). Não é o mesmo que não ter perfil, que leva para o token de acesso.
class SessionProfileUnavailable extends SessionState {
  final String userId;
  final UserEntity? user;
  final UserFailure failure;

  const SessionProfileUnavailable({
    required this.userId,
    required this.failure,
    this.user,
  });

  @override
  List<Object?> get props => [userId, user, failure];
}
