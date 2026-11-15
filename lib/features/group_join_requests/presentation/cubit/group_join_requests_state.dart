import 'package:equatable/equatable.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';

enum GroupJoinRequestsStatus { loading, loaded, notCoordinator, error }

/// Resultado da última decisão, para um aviso único na tela.
enum JoinRequestReviewOutcome {
  approved,
  rejected,
  alreadyReviewed,
  notFound,
  noLongerValid,
  failed,
}

class GroupJoinRequestsState extends Equatable {
  final GroupJoinRequestsStatus status;
  final List<GroupJoinRequestEntity> requests;

  /// Por que a lista não carregou, quando [status] é `error`.
  final GroupJoinRequestsFailure? failure;

  /// Pedido com a decisão em andamento; enquanto houver um, outra decisão é
  /// ignorada.
  final String? reviewingId;
  final JoinRequestDecision? reviewingDecision;

  /// A tela mostra o aviso e limpa com `clearReviewFeedback`.
  final JoinRequestReviewOutcome? reviewOutcome;

  /// Por que a decisão falhou, quando [reviewOutcome] é `failed`.
  final GroupJoinRequestsFailure? reviewFailure;

  const GroupJoinRequestsState({
    this.status = GroupJoinRequestsStatus.loading,
    this.requests = const [],
    this.failure,
    this.reviewingId,
    this.reviewingDecision,
    this.reviewOutcome,
    this.reviewFailure,
  });

  bool get isReviewing => reviewingId != null;

  GroupJoinRequestsState copyWith({
    List<GroupJoinRequestEntity>? requests,
    String? reviewingId,
    JoinRequestDecision? reviewingDecision,
    bool clearReviewingId = false,
    JoinRequestReviewOutcome? reviewOutcome,
    GroupJoinRequestsFailure? reviewFailure,
    bool clearReviewFeedback = false,
  }) {
    return GroupJoinRequestsState(
      status: status,
      requests: requests ?? this.requests,
      failure: failure,
      reviewingId: clearReviewingId ? null : reviewingId ?? this.reviewingId,
      reviewingDecision: clearReviewingId
          ? null
          : reviewingDecision ?? this.reviewingDecision,
      reviewOutcome: clearReviewFeedback
          ? null
          : reviewOutcome ?? this.reviewOutcome,
      reviewFailure: clearReviewFeedback
          ? null
          : reviewFailure ?? this.reviewFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    requests,
    failure,
    reviewingId,
    reviewingDecision,
    reviewOutcome,
    reviewFailure,
  ];
}
