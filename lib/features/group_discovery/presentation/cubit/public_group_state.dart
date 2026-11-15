import 'package:equatable/equatable.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';

enum PublicGroupStatus { loading, loaded, unavailable, error }

class PublicGroupState extends Equatable {
  final PublicGroupStatus status;
  final DiscoveryGroupEntity? group;

  /// Por que o grupo não carregou, quando [status] é `error`.
  final GroupDiscoveryFailure? failure;

  final bool isRequesting;

  /// Retorno do último pedido de entrada, para um aviso único na tela; a
  /// tela limpa com `clearJoinFeedback` depois de mostrar.
  final bool joinRequested;
  final GroupDiscoveryFailure? joinFailure;

  const PublicGroupState({
    this.status = PublicGroupStatus.loading,
    this.group,
    this.failure,
    this.isRequesting = false,
    this.joinRequested = false,
    this.joinFailure,
  });

  bool get hasJoinFeedback => joinRequested || joinFailure != null;

  PublicGroupState copyWith({
    DiscoveryGroupEntity? group,
    bool? isRequesting,
    bool? joinRequested,
    GroupDiscoveryFailure? joinFailure,
    bool clearJoinFailure = false,
  }) {
    return PublicGroupState(
      status: status,
      group: group ?? this.group,
      failure: failure,
      isRequesting: isRequesting ?? this.isRequesting,
      joinRequested: joinRequested ?? this.joinRequested,
      joinFailure: clearJoinFailure ? null : joinFailure ?? this.joinFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    group,
    failure,
    isRequesting,
    joinRequested,
    joinFailure,
  ];
}
