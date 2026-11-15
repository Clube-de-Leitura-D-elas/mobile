abstract final class MeetingGuestRequestsRoutePaths {
  /// Pedidos de participação do encontro, para a anfitriã ou a coordenação
  /// decidir.
  static const guestRequests = '/meeting-guest-requests';

  static String guestRequestsFor(String meetingId) => Uri(
    path: guestRequests,
    queryParameters: {'meeting_id': meetingId},
  ).toString();
}
