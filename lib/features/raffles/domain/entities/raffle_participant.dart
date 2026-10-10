import 'package:equatable/equatable.dart';

class RaffleParticipant extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool hasAttended;
  final bool isExcludedByRule;
  final String? exclusionReason;
  final bool isSelected;

  const RaffleParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.hasAttended,
    this.isExcludedByRule = false,
    this.exclusionReason,
    this.isSelected = true,
  });

  RaffleParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? hasAttended,
    bool? isExcludedByRule,
    String? exclusionReason,
    bool? isSelected,
  }) {
    return RaffleParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasAttended: hasAttended ?? this.hasAttended,
      isExcludedByRule: isExcludedByRule ?? this.isExcludedByRule,
      exclusionReason: exclusionReason ?? this.exclusionReason,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    hasAttended,
    isExcludedByRule,
    exclusionReason,
    isSelected,
  ];
}
