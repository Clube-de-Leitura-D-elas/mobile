import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';

/// One row of the participants list: photo and full name.
///
/// Matches the row used in "Lista de presença" in Figma (80px row, 60px
/// avatar, 16px gap, Heading/H3 name). Long names are truncated with an
/// ellipsis on a single line; screen readers still get the full name.
class ParticipantTile extends StatelessWidget {
  final GroupParticipantEntity participant;

  const ParticipantTile({super.key, required this.participant});

  static const double minHeight = 80;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final text = context.text;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: Row(
        children: [
          ParticipantAvatar(photoUrl: participant.photoUrl),
          SizedBox(width: spacing.s16),
          Expanded(
            child: Text(
              participant.name,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: text.headingH3.copyWith(color: colors.textDefault),
            ),
          ),
        ],
      ),
    );
  }
}
