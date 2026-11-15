import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/core/tools/uuid.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';
import 'package:mobile/features/meeting_guest_requests/domain/repository/meeting_guest_requests_repository.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_state.dart';

/// Pedidos de participação do encontro. Também diz ao detalhe do encontro se a
/// leitora decide os pedidos: só a anfitriã e a coordenação recebem a lista (as
/// outras recebem 403).
class MeetingGuestRequestsCubit extends Cubit<MeetingGuestRequestsState> {
  final MeetingGuestRequestsRepository repository;
  String _meetingId = '';

  // Só a resposta da leitura mais recente vale: um retry logo após a criação
  // do cubit dispara duas, e a mais antiga pode chegar por último.
  int _latestRead = 0;

  MeetingGuestRequestsCubit({required this.repository})
    : super(const MeetingGuestRequestsState());

  Future<void> load(String meetingId) async {
    _meetingId = meetingId;
    // Link sem `meeting_id` ou com id inválido: o backend recusaria igual.
    if (!isUuid(meetingId)) {
      emit(
        const MeetingGuestRequestsState(
          status: MeetingGuestRequestsStatus.error,
          failure: MeetingGuestRequestsInvalidFailure(),
        ),
      );
      return;
    }
    emit(const MeetingGuestRequestsState());

    final read = ++_latestRead;
    final result = await repository.getRequests(meetingId);
    if (isClosed || read != _latestRead) return;

    switch (result) {
      case Success(:final data):
        emit(
          MeetingGuestRequestsState(
            status: MeetingGuestRequestsStatus.loaded,
            requests: data,
          ),
        );
      case Failure(failure: MeetingGuestRequestsNotReviewerFailure()):
        emit(
          const MeetingGuestRequestsState(
            status: MeetingGuestRequestsStatus.notReviewer,
          ),
        );
      case Failure(:final failure):
        emit(
          MeetingGuestRequestsState(
            status: MeetingGuestRequestsStatus.error,
            failure: failure,
          ),
        );
    }
  }

  Future<void> retry() => load(_meetingId);

  /// Atualiza a lista sem passar por carregamento; se falhar, fica o que já
  /// está na tela (menos quando a leitora deixou de poder decidir).
  Future<void> refresh() async {
    if (!isUuid(_meetingId)) return;
    final read = ++_latestRead;
    final result = await repository.getRequests(_meetingId);
    if (isClosed || read != _latestRead) return;

    switch (result) {
      case Success(:final data):
        emit(
          MeetingGuestRequestsState(
            status: MeetingGuestRequestsStatus.loaded,
            requests: data,
            reviewOutcome: state.reviewOutcome,
            reviewFailure: state.reviewFailure,
          ),
        );
      case Failure(failure: MeetingGuestRequestsNotReviewerFailure()):
        emit(
          MeetingGuestRequestsState(
            status: MeetingGuestRequestsStatus.notReviewer,
            reviewOutcome: state.reviewOutcome,
            reviewFailure: state.reviewFailure,
          ),
        );
      case Failure():
        emit(state.copyWith(clearReviewingId: true));
    }
  }

  Future<void> approve(String requestId) =>
      _review(requestId, GuestRequestDecision.approve);

  Future<void> reject(String requestId) =>
      _review(requestId, GuestRequestDecision.reject);

  Future<void> _review(String requestId, GuestRequestDecision decision) async {
    if (isClosed) return;
    if (state.status != MeetingGuestRequestsStatus.loaded ||
        state.isReviewing) {
      return;
    }
    if (!state.requests.any((request) => request.id == requestId)) return;

    emit(
      state.copyWith(
        reviewingId: requestId,
        reviewingDecision: decision,
        clearReviewFeedback: true,
      ),
    );

    final result = await repository.review(
      requestId: requestId,
      decision: decision,
    );
    if (isClosed) return;

    switch (result) {
      case Success():
        _removeRequest(
          requestId,
          decision == GuestRequestDecision.approve
              ? GuestRequestReviewOutcome.approved
              : GuestRequestReviewOutcome.rejected,
        );
      case Failure(failure: GuestRequestAlreadyReviewedFailure()):
        _removeRequest(requestId, GuestRequestReviewOutcome.alreadyReviewed);
      case Failure(failure: GuestRequestNotFoundFailure()):
        // O pedido sumiu ou a leitora deixou de decidir o encontro; a lista
        // nova diz qual.
        _removeRequest(
          requestId,
          GuestRequestReviewOutcome.notFound,
          keepReviewing: true,
        );
        await refresh();
      case Failure(failure: GuestRequestNoLongerValidFailure()):
        emit(
          state.copyWith(
            reviewOutcome: GuestRequestReviewOutcome.noLongerValid,
          ),
        );
        await refresh();
      case Failure(:final failure):
        emit(
          state.copyWith(
            clearReviewingId: true,
            reviewOutcome: GuestRequestReviewOutcome.failed,
            reviewFailure: failure,
          ),
        );
    }
  }

  void _removeRequest(
    String requestId,
    GuestRequestReviewOutcome outcome, {
    bool keepReviewing = false,
  }) {
    emit(
      state.copyWith(
        requests: [
          for (final request in state.requests)
            if (request.id != requestId) request,
        ],
        clearReviewingId: !keepReviewing,
        reviewOutcome: outcome,
      ),
    );
  }

  void clearReviewFeedback() {
    emit(state.copyWith(clearReviewFeedback: true));
  }
}
