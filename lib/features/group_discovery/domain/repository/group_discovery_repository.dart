import 'package:mobile/core/tools/result.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';

abstract class GroupDiscoveryRepository {
  static const int pageSize = 20;

  /// Grupos ativos da cidade da leitora, por número. [page] começa em 1.
  Future<Result<GroupSearchPageEntity, GroupDiscoveryFailure>> searchGroups({
    required int page,
    String search = '',
    GroupSearchFilters filters = GroupSearchFilters.empty,
  });

  /// Grupo da cidade da leitora; [GroupUnavailableFailure] quando ele não
  /// existe, está inativo ou é de outra cidade.
  Future<Result<DiscoveryGroupEntity, GroupDiscoveryFailure>> getGroup(
    String groupId,
  );

  Future<Result<void, GroupDiscoveryFailure>> requestJoin(String groupId);
}
