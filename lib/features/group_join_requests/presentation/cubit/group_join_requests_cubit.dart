import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/core/tools/uuid.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';
import 'package:mobile/features/group_join_requests/domain/repository/group_join_requests_repository.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_state.dart';

/// Pedidos de entrada do grupo. Também diz ao detalhe do grupo se a leitora é
/// coordenadora: só ela recebe a lista (as outras recebem 403).
class GroupJoinRequestsCubit extends Cubit<GroupJoinRequestsState> {
  final GroupJoinRequestsRepository repository;
  String _groupId = '';

  // Só a resposta da leitura mais recente vale: um retry logo após a criação
  // do cubit dispara duas, e a mais antiga pode chegar por último.
  int _latestRead = 0;

  GroupJoinRequestsCubit({required this.repository})
    : super(const GroupJoinRequestsState());

  Future<void> load(String groupId) async {
    _groupId = groupId;
    // Link sem `group_id` ou com id inválido: o backend recusaria igual.
    if (!isUuid(groupId)) {
      emit(
        const GroupJoinRequestsState(
          status: GroupJoinRequestsStatus.error,
          failure: GroupJoinRequestsInvalidFailure(),
        ),
      );
      return;
    }
    emit(const GroupJoinRequestsState());

    final read = ++_latestRead;
    final result = await repository.getRequests(groupId);
    if (isClosed || read != _latestRead) return;

    switch (result) {
      case Success(:final data):
        emit(
          GroupJoinRequestsState(
            status: GroupJoinRequestsStatus.loaded,
            requests: data,
          ),
        );
      case Failure(failure: GroupJoinRequestsNotCoordinatorFailure()):
        emit(
          const GroupJoinRequestsState(
            status: GroupJoinRequestsStatus.notCoordinator,
          ),
        );
      case Failure(:final failure):
        emit(
          GroupJoinRequestsState(
            status: GroupJoinRequestsStatus.error,
            failure: failure,
          ),
        );
    }
  }

  Future<void> retry() => load(_groupId);

  /// Atualiza a lista sem passar por carregamento; se falhar, fica o que já
  /// está na tela (menos quando a leitora deixou de ser coordenadora).
  Future<void> refresh() async {
    if (!isUuid(_groupId)) return;
    final read = ++_latestRead;
    final result = await repository.getRequests(_groupId);
    if (isClosed || read != _latestRead) return;

    switch (result) {
      case Success(:final data):
        emit(
          GroupJoinRequestsState(
            status: GroupJoinRequestsStatus.loaded,
            requests: data,
            reviewOutcome: state.reviewOutcome,
            reviewFailure: state.reviewFailure,
          ),
        );
      case Failure(failure: GroupJoinRequestsNotCoordinatorFailure()):
        emit(
          GroupJoinRequestsState(
            status: GroupJoinRequestsStatus.notCoordinator,
            reviewOutcome: state.reviewOutcome,
            reviewFailure: state.reviewFailure,
          ),
        );
      case Failure():
        emit(state.copyWith(clearReviewingId: true));
    }
  }

  Future<void> approve(String requestId) =>
      _review(requestId, JoinRequestDecision.approve);

  Future<void> reject(String requestId) =>
      _review(requestId, JoinRequestDecision.reject);

  Future<void> _review(String requestId, JoinRequestDecision decision) async {
    if (isClosed) return;
    if (state.status != GroupJoinRequestsStatus.loaded || state.isReviewing) {
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
          decision == JoinRequestDecision.approve
              ? JoinRequestReviewOutcome.approved
              : JoinRequestReviewOutcome.rejected,
        );
      case Failure(failure: JoinRequestAlreadyReviewedFailure()):
        _removeRequest(requestId, JoinRequestReviewOutcome.alreadyReviewed);
      case Failure(failure: JoinRequestNotFoundFailure()):
        // O pedido sumiu ou a leitora deixou de coordenar o grupo; a lista
        // nova diz qual.
        _removeRequest(
          requestId,
          JoinRequestReviewOutcome.notFound,
          keepReviewing: true,
        );
        await refresh();
      case Failure(failure: JoinRequestNoLongerValidFailure()):
        emit(
          state.copyWith(reviewOutcome: JoinRequestReviewOutcome.noLongerValid),
        );
        await refresh();
      case Failure(:final failure):
        emit(
          state.copyWith(
            clearReviewingId: true,
            reviewOutcome: JoinRequestReviewOutcome.failed,
            reviewFailure: failure,
          ),
        );
    }
  }

  void _removeRequest(
    String requestId,
    JoinRequestReviewOutcome outcome, {
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
