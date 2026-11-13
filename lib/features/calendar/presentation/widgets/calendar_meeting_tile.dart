import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/features/calendar/domain/sao_paulo_time.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_info_row.dart';

class CalendarMeetingTile extends StatelessWidget {
  final CalendarMeetingEntity meeting;

  /// Na lista do mês o título leva a data; na do dia selecionado, não.
  final bool showDate;

  final VoidCallback onTap;

  const CalendarMeetingTile({
    super.key,
    required this.meeting,
    required this.showDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final l10n = context.l10n;
    final hostName = meeting.hostName;
    final group = meeting.group;

    final title = showDate
        ? l10n.calendarMeetingTitleWithDate(meeting.localDate, group.number)
        : l10n.calendarMeetingTitle(group.number);
    final time = l10n.calendarMeetingTime(toSaoPaulo(meeting.date));
    final participants = l10n.calendarParticipantsCount(group.participantCount);
    final place = meeting.placeLabel;
    final host = hostName == null ? null : l10n.calendarMeetingHost(hostName);
    final draft = meeting.isDraft ? l10n.calendarMeetingDraftTag : null;

    return Semantics(
      button: true,
      label: [title, ?draft, time, participants, ?place, ?host].join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: AppCard(
        // A borda do AppCard alterna a cada toque e ficaria marcada ao voltar
        // da tela do grupo.
        showBorder: false,
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.typography.bodyDefaultEmphasis.copyWith(
                      color: colors.textDefault,
                    ),
                  ),
                  if (draft != null) ...[
                    SizedBox(height: spacing.s4),
                    AppTag(label: draft, variant: TagVariant.neutral),
                  ],
                  SizedBox(height: spacing.s4),
                  AppGroupInfoRow(icon: AppIcons.clock, label: time),
                  SizedBox(height: spacing.s4),
                  AppGroupInfoRow(icon: AppIcons.group, label: participants),
                  if (place != null) ...[
                    SizedBox(height: spacing.s4),
                    AppGroupInfoRow(icon: AppIcons.location, label: place),
                  ],
                  if (host != null) ...[
                    SizedBox(height: spacing.s4),
                    AppGroupInfoRow(icon: AppIcons.host, label: host),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.s8),
            Icon(Icons.chevron_right, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
