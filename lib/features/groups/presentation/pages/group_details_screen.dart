import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/group_actions.dart';
import 'package:mobile/features/groups/presentation/widgets/group_cover.dart';
import 'package:mobile/features/groups/presentation/widgets/group_identity.dart';
import 'package:mobile/features/groups/presentation/widgets/group_section.dart';

/// Presentation-only shell for the group details feature.
///
/// The route can supply group data and the three section bodies when their
/// respective features are ready. Fetching and navigation into this page stay
/// outside this widget.
class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({
    super.key,
    required this.name,
    required this.genres,
    required this.participantCount,
    required this.city,
    required this.stateCode,
    this.coverImage,
    this.nextEventCount,
    this.nextEventContent,
    this.bookContent,
    this.participantsContent,
    this.onEventHistoryPressed,
  });

  final String name;
  final List<String> genres;
  final int participantCount;
  final String city;
  final String stateCode;
  final ImageProvider<Object>? coverImage;
  final int? nextEventCount;
  final Widget? nextEventContent;
  final Widget? bookContent;
  final Widget? participantsContent;
  final VoidCallback? onEventHistoryPressed;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  bool _nextEventExpanded = true;
  bool _participantsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GroupCover(image: widget.coverImage, name: widget.name),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s24,
                spacing.s16,
                spacing.s24,
                spacing.s24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GroupIdentity(
                    name: widget.name,
                    genres: widget.genres,
                    participantCount: widget.participantCount,
                    city: widget.city,
                    stateCode: widget.stateCode,
                  ),
                  SizedBox(height: spacing.s32),
                  const GroupActions(),
                  if (widget.onEventHistoryPressed != null) ...[
                    SizedBox(height: spacing.s8),
                    AppButton.ghost(
                      label: l10n.groupEventHistoryTitle,
                      size: AppButtonSize.sm,
                      icon: const Icon(Icons.history),
                      onPressed: widget.onEventHistoryPressed,
                    ),
                  ],
                  SizedBox(height: spacing.s24),
                  GroupSection(
                    title: l10n.groupNextEventTitle,
                    count: widget.nextEventCount,
                    expanded: _nextEventExpanded,
                    onToggle: () => setState(
                      () => _nextEventExpanded = !_nextEventExpanded,
                    ),
                    children: [
                      if (widget.nextEventContent != null)
                        widget.nextEventContent!,
                      if (widget.bookContent != null) widget.bookContent!,
                    ],
                  ),
                  GroupSection(
                    title: l10n.groupParticipantsTitle,
                    count: widget.participantCount,
                    expanded: _participantsExpanded,
                    onToggle: () => setState(
                      () => _participantsExpanded = !_participantsExpanded,
                    ),
                    children: [
                      if (widget.participantsContent != null)
                        widget.participantsContent!,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
