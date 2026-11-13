import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

abstract final class GroupDiscoveryRoutePaths {
  /// Detalhes do grupo para quem não é membro, com o pedido de entrada.
  static const publicGroup = '/group-public';

  static String publicGroupFor(String groupId) =>
      Uri(path: publicGroup, queryParameters: {'group_id': groupId}).toString();

  /// Membro abre os detalhes completos; os demais, a tela pública.
  static String detailsFor(DiscoveryGroupEntity group) => group.isMember
      ? Uri(
          path: GroupRoutePaths.groupDetails,
          queryParameters: {'group_id': group.id},
        ).toString()
      : publicGroupFor(group.id);
}
