import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_participant_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';

/// One row of the participants list: photo and full name.
///
/// Matches the "Detalhes de Grupo" mockup in Figma: 60px avatar, 16px gap
/// and the name in Body/Default Emphasis. Long names are truncated with an
/// ellipsis on a single line; screen readers still get the full name.
class ParticipantTile extends StatelessWidget {
  final GroupParticipantEntity participant;

  const ParticipantTile({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final text = context.text;

    return Row(
      children: [
        ParticipantAvatar(photoUrl: participant.photoUrl),
        SizedBox(width: spacing.s16),
        Expanded(
          child: Text(
            participant.name,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: text.bodyDefaultEmphasis.copyWith(color: colors.textDefault),
          ),
        ),
      ],
    );
  }
}
