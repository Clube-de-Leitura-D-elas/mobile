import 'package:equatable/equatable.dart';

class GroupParticipantEntity extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;
  final bool isCoordinator;
  final bool isHost;

  const GroupParticipantEntity({
    required this.id,
    required this.name,
    this.photoUrl,
    this.isCoordinator = false,
    this.isHost = false,
  });

  @override
  List<Object?> get props => [id, name, photoUrl, isCoordinator, isHost];
}
