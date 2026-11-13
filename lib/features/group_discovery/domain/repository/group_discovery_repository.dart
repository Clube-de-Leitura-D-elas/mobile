import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';

abstract class GroupDiscoveryRepository {
  /// Grupo da cidade da leitora; [GroupUnavailableFailure] quando ele não
  /// existe, está inativo ou é de outra cidade.
  Future<Result<DiscoveryGroupEntity, GroupDiscoveryFailure>> getGroup(
    String groupId,
  );

  Future<Result<void, GroupDiscoveryFailure>> requestJoin(String groupId);
}
