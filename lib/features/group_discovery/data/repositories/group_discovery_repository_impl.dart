import 'package:flutter/foundation.dart';
import 'package:mobile/core/supabase/supabase_failure.dart';
import 'package:mobile/core/supabase/supabase_service.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/data/models/discovery_group_model.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupDiscoveryRepositoryImpl implements GroupDiscoveryRepository {
  GroupDiscoveryRepositoryImpl({required this.supabaseService});

  final SupabaseService supabaseService;

  @override
  Future<Result<DiscoveryGroupEntity, GroupDiscoveryFailure>> getGroup(
    String groupId,
  ) async {
    final result = await supabaseService
        .invokeFunction<List<DiscoveryGroupModel>>(
          functionName: 'get-city-groups',
          method: HttpMethod.get,
          queryParameters: {'groupId': groupId},
          decoder: (data) =>
              DiscoveryGroupModel.listFromJson(data as Map<String, dynamic>),
        );

    switch (result) {
      // Id que o backend não aceita: não há o que tentar de novo.
      case Failure(:final failure)
          when failure.kind == SupabaseFailureKind.validation:
        return const Failure(GroupUnavailableFailure());
      case Failure(:final failure):
        return Failure(_failureFrom(failure));
      case Success(:final data):
        final models = data.data;
        if (models == null) return const Failure(GroupDiscoveryServerFailure());
        // Grupo inexistente, inativo ou de outra cidade não vem na lista; um
        // backend sem o filtro `groupId` traria outros grupos.
        for (final model in models) {
          if (model.id == groupId) return Success(model.toDomain());
        }
        return const Failure(GroupUnavailableFailure());
    }
  }

  @override
  Future<Result<void, GroupDiscoveryFailure>> requestJoin(
    String groupId,
  ) async {
    final result = await supabaseService.invokeFunction<void>(
      functionName: 'request-group-join',
      body: {'group_id': groupId},
    );

    return switch (result) {
      Failure(:final failure) => Failure(_failureFrom(failure)),
      Success() => const Success(null),
    };
  }

  /// O backend usa o mesmo status para casos diferentes; o texto em `error`
  /// (que chega no `message`) diz qual.
  GroupDiscoveryFailure _failureFrom(SupabaseFailure failure) {
    debugPrint('[GroupDiscoveryFailure] ${failure.message} (${failure.code})');
    final message = failure.message;
    return switch (failure.kind) {
      SupabaseFailureKind.network => const GroupDiscoveryNetworkFailure(),
      SupabaseFailureKind.unauthorized =>
        const GroupDiscoverySessionExpiredFailure(),
      SupabaseFailureKind.forbidden
          when message.contains('group not available') =>
        const GroupUnavailableFailure(),
      SupabaseFailureKind.forbidden =>
        const GroupDiscoveryInactiveAccountFailure(),
      SupabaseFailureKind.notFound when message.contains('group not found') =>
        const GroupUnavailableFailure(),
      SupabaseFailureKind.conflict when message.contains('no coordinator') =>
        const GroupJoinNoCoordinatorFailure(),
      SupabaseFailureKind.conflict => const GroupJoinAlreadyRequestedFailure(),
      _ => const GroupDiscoveryServerFailure(),
    };
  }
}
