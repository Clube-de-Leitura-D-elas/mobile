import 'package:equatable/equatable.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';

enum MeetingGuestRequestsStatus { loading, loaded, notReviewer, error }

/// Resultado da última decisão, para um aviso único na tela.
enum GuestRequestReviewOutcome {
  approved,
  rejected,
  alreadyReviewed,
  notFound,
  noLongerValid,
  failed,
}

class MeetingGuestRequestsState extends Equatable {
  final MeetingGuestRequestsStatus status;
  final List<MeetingGuestRequestEntity> requests;

  /// Por que a lista não carregou, quando [status] é `error`.
  final MeetingGuestRequestsFailure? failure;

  /// Pedido com a decisão em andamento; enquanto houver um, outra decisão é
  /// ignorada.
  final String? reviewingId;
  final GuestRequestDecision? reviewingDecision;

  /// A tela mostra o aviso e limpa com `clearReviewFeedback`.
  final GuestRequestReviewOutcome? reviewOutcome;

  /// Por que a decisão falhou, quando [reviewOutcome] é `failed`.
  final MeetingGuestRequestsFailure? reviewFailure;

  const MeetingGuestRequestsState({
    this.status = MeetingGuestRequestsStatus.loading,
    this.requests = const [],
    this.failure,
    this.reviewingId,
    this.reviewingDecision,
    this.reviewOutcome,
    this.reviewFailure,
  });

  bool get isReviewing => reviewingId != null;

  MeetingGuestRequestsState copyWith({
    List<MeetingGuestRequestEntity>? requests,
    String? reviewingId,
    GuestRequestDecision? reviewingDecision,
    bool clearReviewingId = false,
    GuestRequestReviewOutcome? reviewOutcome,
    MeetingGuestRequestsFailure? reviewFailure,
    bool clearReviewFeedback = false,
  }) {
    return MeetingGuestRequestsState(
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
