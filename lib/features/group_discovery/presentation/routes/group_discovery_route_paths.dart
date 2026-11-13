abstract final class GroupDiscoveryRoutePaths {
  /// Detalhes do grupo para quem não é membro, com o pedido de entrada.
  static const publicGroup = '/group-public';

  static String publicGroupFor(String groupId) =>
      Uri(path: publicGroup, queryParameters: {'group_id': groupId}).toString();
}
