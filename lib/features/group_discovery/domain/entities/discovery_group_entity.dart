import 'package:equatable/equatable.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';

class DiscoveryGroupEntity extends Equatable {
  final String id;
  final int number;
  final String description;

  /// `null` quando o backend não tem a cidade do grupo.
  final String? cityState;
  final String? photoUrl;
  final List<String> genres;
  final int participantCount;
  final GroupMembershipStatus membershipStatus;

  const DiscoveryGroupEntity({
    required this.id,
    required this.number,
    required this.description,
    required this.genres,
    required this.participantCount,
    required this.membershipStatus,
    this.cityState,
    this.photoUrl,
  });

  bool get isMember => membershipStatus == GroupMembershipStatus.member;

  /// Sem relação com o grupo ou com o pedido recusado, pode pedir entrada.
  bool get canRequestJoin =>
      membershipStatus == GroupMembershipStatus.none ||
      membershipStatus == GroupMembershipStatus.rejected;

  DiscoveryGroupEntity copyWith({GroupMembershipStatus? membershipStatus}) {
    return DiscoveryGroupEntity(
      id: id,
      number: number,
      description: description,
      cityState: cityState,
      photoUrl: photoUrl,
      genres: genres,
      participantCount: participantCount,
      membershipStatus: membershipStatus ?? this.membershipStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    number,
    description,
    cityState,
    photoUrl,
    genres,
    participantCount,
    membershipStatus,
  ];
}
