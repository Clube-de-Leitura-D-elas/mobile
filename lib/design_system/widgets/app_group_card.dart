import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupMeeting {
  final String hostName;
  final String bookTitle;
  final String date;
  final String location;

  const GroupMeeting({
    required this.hostName,
    required this.bookTitle,
    required this.date,
    required this.location,
  });
}

class AppGroupCard extends StatelessWidget {
  final String groupName;
  final String? photoUrl;
  final int participantsCount;
  final String cityState;
  final GroupMeeting? nextMeeting;
  final bool expanded;
  final VoidCallback? onTap;
  final VoidCallback? onConfirmPresence;
  final VoidCallback? onDeclinePresence;

  const AppGroupCard({
    super.key,
    required this.groupName,
    required this.participantsCount,
    required this.cityState,
    this.photoUrl,
    this.nextMeeting,
    this.expanded = true,
    this.onTap,
    this.onConfirmPresence,
    this.onDeclinePresence,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final meeting = nextMeeting;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupAvatar(photoUrl: photoUrl),
              SizedBox(width: spacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      groupName,
                      style: typography.headingH2.copyWith(
                        color: colors.textDefault,
                      ),
                    ),
                    SizedBox(height: spacing.s4),
                    _InfoRow(
                      icon: AppIcons.group,
                      label: '$participantsCount participantes',
                    ),
                    _InfoRow(icon: AppIcons.location, label: cityState),
                  ],
                ),
              ),
            ],
          ),
          if (meeting != null) ...[
            SizedBox(height: spacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Próximo evento',
                  style: typography.bodyLarge.copyWith(color: colors.textMuted),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: colors.textMuted,
                ),
              ],
            ),
            if (expanded) ...[
              SizedBox(height: spacing.s8),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(
                      icon: AppIcons.user,
                      label: meeting.hostName,
                    ),
                  ),
                  Expanded(
                    child: _InfoRow(
                      icon: AppIcons.book,
                      label: meeting.bookTitle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.s4),
              Row(
                children: [
                  Expanded(
                    child: _InfoRow(
                      icon: AppIcons.calendar,
                      label: meeting.date,
                    ),
                  ),
                  Expanded(
                    child: _InfoRow(
                      icon: AppIcons.location,
                      label: meeting.location,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.s16),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Não irei',
                      onPressed: onDeclinePresence ?? () {},
                    ),
                  ),
                  SizedBox(width: spacing.s8),
                  Expanded(
                    child: AppButton.primary(
                      label: 'Confirmar presença',
                      onPressed: onConfirmPresence ?? () {},
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GroupAvatar extends StatelessWidget {
  final String? photoUrl;

  const _GroupAvatar({required this.photoUrl});

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = photoUrl;

    Widget placeholder() => ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(Icons.groups_outlined, color: colors.textMuted),
    );

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? placeholder()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => placeholder(),
                errorWidget: (context, _, _) => placeholder(),
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final AppIconAsset icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  static const double _size = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon: icon, size: _size, color: colors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: typography.bodySmall.copyWith(color: colors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Exemplo de uso:
//
// AppGroupCard(
//   groupName: 'Grupo 27',
//   photoUrl: 'https://.../grupo27.jpg',
//   participantsCount: 18,
//   cityState: 'Porto Alegre, RS',
//   nextMeeting: const GroupMeeting(
//     hostName: 'Roberta',
//     bookTitle: 'Pequeno príncipe',
//     date: '29/08/2026',
//     location: 'Z Café TECNOPUC',
//   ),
//   expanded: false, // mostra só "Próximo encontro" + seta pra baixo
//   onTap: () => Navigator.pushNamed(context, '/grupo/27'),
// ),
