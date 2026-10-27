import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';

class RaffleParticipantModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool hasAttended;
  final bool isExcludedByRule;
  final String? exclusionReason;

  const RaffleParticipantModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.hasAttended,
    this.isExcludedByRule = false,
    this.exclusionReason,
  });

  factory RaffleParticipantModel.fromJson(Map<String, dynamic> json) {
    return RaffleParticipantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      hasAttended: json['has_attended'] as bool? ?? false,
      isExcludedByRule: json['is_excluded_by_rule'] as bool? ?? false,
      exclusionReason: json['exclusion_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'has_attended': hasAttended,
      'is_excluded_by_rule': isExcludedByRule,
      'exclusion_reason': exclusionReason,
    };
  }

  RaffleParticipant toDomain() {
    return RaffleParticipant(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      hasAttended: hasAttended,
      isExcludedByRule: isExcludedByRule,
      exclusionReason: exclusionReason,
      isSelected:
          !isExcludedByRule, // Se for excluída por regra de livro sorteado, vem desmarcada por padrão
    );
  }
}
