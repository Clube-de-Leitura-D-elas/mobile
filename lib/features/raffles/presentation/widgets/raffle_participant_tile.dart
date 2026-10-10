import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';

class RaffleParticipantTile extends StatelessWidget {
  final RaffleParticipant participant;
  final ValueChanged<bool?> onChanged;

  const RaffleParticipantTile({
    super.key,
    required this.participant,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final isDisabled = participant.isExcludedByRule;

    return InkWell(
      onTap: isDisabled ? null : () => onChanged(!participant.isSelected),
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ParticipantAvatar(photoUrl: participant.avatarUrl),
            ),
            const Gap16(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name,
                    style: typography.bodyDefault.copyWith(
                      color: isDisabled ? colors.textMuted : colors.textDefault,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isDisabled && participant.exclusionReason != null) ...[
                    const Gap(4),
                    Text(
                      participant.exclusionReason!,
                      style: typography.bodySmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IgnorePointer(
              child: AppCheckbox(
                value: participant.isSelected,
                onChanged: isDisabled ? null : onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
