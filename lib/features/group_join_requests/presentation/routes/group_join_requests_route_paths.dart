abstract final class GroupJoinRequestsRoutePaths {
  /// Pedidos de entrada do grupo, para a coordenadora decidir.
  static const joinRequests = '/group-join-requests';

  static String joinRequestsFor(String groupId) => Uri(
    path: joinRequests,
    queryParameters: {'group_id': groupId},
  ).toString();
}
