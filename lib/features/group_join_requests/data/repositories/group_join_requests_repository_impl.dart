import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_join_requests/data/models/group_join_request_model.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';
import 'package:mobile/features/group_join_requests/domain/repository/group_join_requests_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupJoinRequestsRepositoryImpl implements GroupJoinRequestsRepository {
  GroupJoinRequestsRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<List<GroupJoinRequestEntity>, GroupJoinRequestsFailure>>
  getRequests(String groupId) async {
    final result = await supabaseService
        .invokeFunction<List<GroupJoinRequestModel>>(
          functionName: 'get-group-join-requests',
          method: HttpMethod.get,
          queryParameters: {'group_id': groupId},
          decoder: (data) =>
              GroupJoinRequestModel.listFromJson(data as Map<String, dynamic>),
        );

    switch (result) {
      case Failure(:final failure):
        return Failure(_failureFrom(failure));
      case Success(:final data):
        final models = data.data;
        if (models == null) {
          return const Failure(GroupJoinRequestsServerFailure());
        }
        return Success([for (final model in models) model.toDomain()]);
    }
  }

  @override
  Future<Result<void, GroupJoinRequestsFailure>> review({
    required String requestId,
    required JoinRequestDecision decision,
  }) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'review-group-join-request',
      body: {'group_user_id': requestId, 'action': decision.name},
    );

    return switch (result) {
      Failure(:final failure) => Failure(_failureFrom(failure)),
      Success() => const Success(null),
    };
  }

  /// O backend usa o mesmo status para casos diferentes; o texto em `error`
  /// (que chega no `message`) diz qual.
  GroupJoinRequestsFailure _failureFrom(SupabaseFailure failure) {
    final message = failure.message;
    // 403 é a resposta esperada para quem não coordena: o detalhe do grupo
    // pergunta a toda leitora que abre a tela.
    if (failure.kind != SupabaseFailureKind.forbidden) {
      debugPrint(
        '[GroupJoinRequestsFailure] ${failure.message} (${failure.code})',
      );
    }
    return switch (failure.kind) {
      SupabaseFailureKind.network => const GroupJoinRequestsNetworkFailure(),
      SupabaseFailureKind.unauthorized =>
        const GroupJoinRequestsSessionExpiredFailure(),
      SupabaseFailureKind.forbidden =>
        const GroupJoinRequestsNotCoordinatorFailure(),
      SupabaseFailureKind.validation => const GroupJoinRequestsInvalidFailure(),
      SupabaseFailureKind.notFound when message.contains('request not found') =>
        const JoinRequestNotFoundFailure(),
      SupabaseFailureKind.conflict when message.contains('already reviewed') =>
        const JoinRequestAlreadyReviewedFailure(),
      SupabaseFailureKind.conflict when message.contains('no longer valid') =>
        const JoinRequestNoLongerValidFailure(),
      _ => const GroupJoinRequestsServerFailure(),
    };
  }
}
