import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';

abstract class GroupJoinRequestsRepository {
  /// Pedidos pendentes do grupo, do mais antigo para o mais novo;
  /// [GroupJoinRequestsNotCoordinatorFailure] para quem não coordena o grupo.
  Future<Result<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure>>
  getRequests(String groupId);

  Future<Result<void, GroupJoinRequestsFailure>> review({
    required String requestId,
    required JoinRequestDecision decision,
  });
}
