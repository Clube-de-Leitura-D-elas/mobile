import 'package:equatable/equatable.dart';

/// Falhas ao carregar o resumo do perfil (livros lidos, grupos e avaliações).
/// Separadas das falhas da foto para cada chamada tratar só os seus casos.
sealed class ProfileSummaryFailure extends Equatable {
  const ProfileSummaryFailure();

  @override
  List<Object?> get props => [];
}

class ProfileSummaryNetworkFailure extends ProfileSummaryFailure {
  const ProfileSummaryNetworkFailure();
}

class ProfileSummarySessionExpiredFailure extends ProfileSummaryFailure {
  const ProfileSummarySessionExpiredFailure();
}

class ProfileSummaryLoadFailure extends ProfileSummaryFailure {
  const ProfileSummaryLoadFailure();
}
