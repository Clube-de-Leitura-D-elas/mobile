import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'group_metadata.dart';

class GroupIdentity extends StatelessWidget {
  const GroupIdentity({
    super.key,
    required this.name,
    required this.genres,
    required this.participantCount,
    required this.city,
    required this.stateCode,
  });

  final String name;
  final List<String> genres;
  final int participantCount;
  final String city;
  final String stateCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final spacing = context.spacing;
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              key: const ValueKey('group-name'),
              style: text.headingH2.copyWith(color: colors.textDefault),
            ),
            SizedBox(width: spacing.s8),
            Expanded(
              child: Wrap(
                key: const ValueKey('group-genres'),
                alignment: WrapAlignment.end,
                spacing: spacing.s8,
                runSpacing: spacing.s8,
                children: [
                  for (final genre in genres) AppTag(label: genre),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.s8),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: spacing.s24,
            runSpacing: spacing.s8,
            children: [
              GroupMetadata(
                icon: AppIcons.user,
                label: l10n.groupParticipantsCount(participantCount),
                maxWidth: constraints.maxWidth,
              ),
              GroupMetadata(
                icon: AppIcons.location,
                label: '$city, $stateCode',
                maxWidth: constraints.maxWidth,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
