import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

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
            _GroupCover(image: widget.coverImage, name: widget.name),
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
                  _GroupIdentity(
                    name: widget.name,
                    genres: widget.genres,
                    participantCount: widget.participantCount,
                    city: widget.city,
                    stateCode: widget.stateCode,
                  ),
                  SizedBox(height: spacing.s32),
                  const _GroupActions(),
                  SizedBox(height: spacing.s24),
                  _GroupSection(
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
                  SizedBox(height: spacing.s24),
                  _GroupSection(
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

class _GroupCover extends StatelessWidget {
  const _GroupCover({required this.image, required this.name});

  final ImageProvider<Object>? image;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final spacing = context.spacing;

    return AspectRatio(
      aspectRatio: 1.9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: colors.surfaceSunken,
            child: image == null
                ? Center(
                    child: AppIcon(
                      icon: AppIcons.group,
                      size: spacing.s48,
                      color: colors.textMuted,
                    ),
                  )
                : Image(
                    image: image!,
                    fit: BoxFit.cover,
                    semanticLabel: l10n.groupCoverSemanticLabel(name),
                    errorBuilder: (_, _, _) => Center(
                      child: AppIcon(
                        icon: AppIcons.group,
                        size: spacing.s48,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(spacing.s12),
                child: Material(
                  color: colors.surfaceDefault,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: l10n.back,
                    icon: const Icon(Icons.arrow_back),
                    color: colors.textDefault,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupIdentity extends StatelessWidget {
  const _GroupIdentity({
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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: spacing.s8,
          runSpacing: spacing.s8,
          children: [
            Text(
              name,
              key: const ValueKey('group-name'),
              style: text.headingH2.copyWith(color: colors.textDefault),
            ),
            Wrap(
              key: const ValueKey('group-genres'),
              alignment: WrapAlignment.end,
              spacing: spacing.s8,
              runSpacing: spacing.s8,
              children: [for (final genre in genres) AppTag(label: genre)],
            ),
          ],
        ),
        SizedBox(height: spacing.s8),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: spacing.s24,
            runSpacing: spacing.s8,
            children: [
              _GroupMetadata(
                icon: AppIcons.user,
                label: l10n.groupParticipantsCount(participantCount),
                maxWidth: constraints.maxWidth,
              ),
              _GroupMetadata(
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

class _GroupMetadata extends StatelessWidget {
  const _GroupMetadata({
    required this.icon,
    required this.label,
    required this.maxWidth,
  });

  final AppIconAsset icon;
  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon: icon, size: spacing.s16, color: colors.textMuted),
          SizedBox(width: spacing.s4),
          Flexible(
            child: Text(
              label,
              style: context.text.bodySmall.copyWith(color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupActions extends StatelessWidget {
  const _GroupActions();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttons = [
          AppButton.secondary(
            label: l10n.groupOpenWhatsAppButton,
            size: AppButtonSize.sm,
            onPressed: () {},
          ),
          AppButton.primary(
            label: l10n.groupRecommendBookButton,
            size: AppButtonSize.sm,
            onPressed: () {},
          ),
        ];

        if (constraints.maxWidth < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buttons.first,
              SizedBox(height: spacing.s8),
              buttons.last,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: buttons.first),
            SizedBox(width: spacing.s8),
            Expanded(child: buttons.last),
          ],
        );
      },
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final int? count;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            key: ValueKey('section-$title'),
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.s8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: text.headingH3.copyWith(
                              color: colors.textDefault,
                            ),
                          ),
                        ),
                        if (count != null) ...[
                          SizedBox(width: spacing.s4),
                          Text(
                            '$count',
                            style: text.bodySmall.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.s8),
                  Icon(
                    key: ValueKey('section-chevron-$title'),
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.textDefault,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded && children.isNotEmpty) ...[
          SizedBox(height: spacing.s8),
          ...children,
        ],
      ],
    );
  }
}
