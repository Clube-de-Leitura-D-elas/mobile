import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_membership_status.dart';

class DiscoveryGroupModel {
  final String id;
  final int number;
  final String description;
  final String? cityState;
  final String? photoUrl;
  final List<String> genres;
  final int participantCount;
  final GroupMembershipStatus membershipStatus;

  const DiscoveryGroupModel({
    required this.id,
    required this.number,
    required this.description,
    required this.genres,
    required this.participantCount,
    required this.membershipStatus,
    this.cityState,
    this.photoUrl,
  });

  factory DiscoveryGroupModel.fromJson(Map<String, dynamic> json) {
    final cityState = json['city_state'] as String?;
    final genres = json['genres'] as List<dynamic>? ?? const [];
    return DiscoveryGroupModel(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      description: json['description'] as String? ?? '',
      // Sem cidade cadastrada o backend manda "".
      cityState: cityState == null || cityState.trim().isEmpty
          ? null
          : cityState,
      photoUrl: json['photo_url'] as String?,
      genres: [
        for (final genre in genres)
          (genre as Map<String, dynamic>)['name'] as String,
      ],
      participantCount: (json['participant_count'] as num).toInt(),
      membershipStatus: _parseMembership(json['membership_status']),
    );
  }

  /// Itens da resposta da `get-city-groups`: `{ "items": [...], ... }`.
  static List<DiscoveryGroupModel> listFromJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? const [];
    return [
      for (final item in items)
        DiscoveryGroupModel.fromJson(item as Map<String, dynamic>),
    ];
  }

  static GroupMembershipStatus _parseMembership(dynamic value) {
    return switch (value) {
      'MEMBER' => GroupMembershipStatus.member,
      'REQUESTED' => GroupMembershipStatus.requested,
      'REJECTED' => GroupMembershipStatus.rejected,
      'PENDING' => GroupMembershipStatus.pending,
      _ => GroupMembershipStatus.none,
    };
  }

  DiscoveryGroupEntity toDomain() {
    return DiscoveryGroupEntity(
      id: id,
      number: number,
      description: description,
      cityState: cityState,
      photoUrl: photoUrl,
      genres: genres,
      participantCount: participantCount,
      membershipStatus: membershipStatus,
    );
  }
}
