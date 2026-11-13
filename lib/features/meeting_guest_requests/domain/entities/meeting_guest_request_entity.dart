import 'package:equatable/equatable.dart';

/// Pedido de participação num encontro, aguardando a anfitriã ou a
/// coordenação.
class MeetingGuestRequestEntity extends Equatable {
  /// Id do pedido em `meeting_guest_requests`; é ele que a decisão usa.
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;
  final DateTime? requestedAt;

  const MeetingGuestRequestEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.requestedAt,
  });

  @override
  List<Object?> get props => [id, userId, name, photoUrl, requestedAt];
}
