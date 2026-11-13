import 'package:equatable/equatable.dart';

/// Pedido de entrada aguardando a coordenadora.
class GroupJoinRequestEntity extends Equatable {
  /// Id do vínculo em `group_users`; é ele que a decisão usa.
  final String id;
  final String userId;
  final String name;
  final String? photoUrl;

  /// `null` em pedidos antigos, anteriores ao registro da data.
  final DateTime? requestedAt;

  const GroupJoinRequestEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.photoUrl,
    this.requestedAt,
  });

  @override
  List<Object?> get props => [id, userId, name, photoUrl, requestedAt];
}
