import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_guest_status.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_meeting_entity.dart';
import 'package:mobile/core/tools/sao_paulo_time.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/membership_status_indicator.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_info_row.dart';

class CalendarMeetingTile extends StatelessWidget {
  final CalendarMeetingEntity meeting;

  /// Na lista do mês o título leva a data; na do dia selecionado, não.
  final bool showDate;

  final VoidCallback onTap;

  /// Decide se o encontro ainda aceita pedido de participação.
  final DateTime now;

  final bool isRequesting;
  final VoidCallback onRequestParticipation;

  const CalendarMeetingTile({
    super.key,
    required this.meeting,
    required this.showDate,
    required this.onTap,
    required this.now,
    required this.onRequestParticipation,
    this.isRequesting = false,
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

    final guestStatus = meeting.acceptsGuestRequestAt(now)
        ? meeting.guestStatus
        : CalendarGuestStatus.unknown;

    final info = Row(
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
    );

    // O rótulo se junta ao nó de botão do AppCard; o botão do pedido de
    // participação fica como nó filho, acionável à parte.
    return Semantics(
      label: [title, ?draft, time, participants, ?place, ?host].join(', '),
      child: AppCard(
        // A borda do AppCard alterna a cada toque e ficaria marcada ao voltar
        // da tela do grupo.
        showBorder: false,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: info),
            if (guestStatus != CalendarGuestStatus.unknown) ...[
              SizedBox(height: spacing.s12),
              _GuestParticipation(
                status: guestStatus,
                isRequesting: isRequesting,
                onRequest: onRequestParticipation,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pedido de participação num encontro de outro grupo: situação e ação.
class _GuestParticipation extends StatelessWidget {
  /// `null` é encontro sem pedido.
  final CalendarGuestStatus? status;
  final bool isRequesting;
  final VoidCallback onRequest;

  const _GuestParticipation({
    required this.status,
    required this.isRequesting,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;

    final (String? label, Color color) = switch (status) {
      CalendarGuestStatus.requested => (
        l10n.calendarGuestStatusRequested,
        colors.feedbackWarningDark,
      ),
      CalendarGuestStatus.accepted => (
        l10n.calendarGuestStatusAccepted,
        colors.feedbackSuccessDark,
      ),
      CalendarGuestStatus.rejected => (
        l10n.calendarGuestStatusRejected,
        colors.feedbackErrorDark,
      ),
      null || CalendarGuestStatus.unknown => (null, colors.textMuted),
    };

    final String? actionLabel = switch (status) {
      null => l10n.calendarGuestRequest,
      CalendarGuestStatus.rejected => l10n.calendarGuestRequestAgain,
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          MembershipStatusIndicator(label: label, color: color),
        if (label != null && actionLabel != null) SizedBox(height: spacing.s12),
        if (actionLabel != null)
          // Com o botão ocupado o toque cairia no card e abriria o grupo.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: () {},
            child: AppButton.primary(
              label: actionLabel,
              size: AppButtonSize.lg,
              isLoading: isRequesting,
              onPressed: onRequest,
            ),
          ),
      ],
    );
  }
}
