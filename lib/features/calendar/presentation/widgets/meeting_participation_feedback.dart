import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Aviso do resultado de um pedido de participação; [failure] `null` é
/// sucesso.
void showMeetingParticipationFeedback(
  BuildContext context, {
  CalendarFailure? failure,
}) {
  final l10n = context.l10n;
  if (failure == null) {
    AppToast.show(
      context,
      message: l10n.calendarGuestRequestSuccess,
      type: AppToastType.success,
    );
    return;
  }
  AppToast.show(
    context,
    message: meetingParticipationFailureMessage(l10n, failure),
    type:
        failure is CalendarGuestAlreadyRequestedFailure ||
            failure is CalendarGuestAlreadyMemberFailure ||
            failure is CalendarGuestRecentlyRejectedFailure ||
            failure is CalendarMeetingNoReviewerFailure
        ? AppToastType.info
        : AppToastType.error,
  );
}

String meetingParticipationFailureMessage(
  AppLocalizations l10n,
  CalendarFailure failure,
) => switch (failure) {
  CalendarNetworkFailure() => l10n.errorNoConnection,
  CalendarSessionExpiredFailure() => l10n.errorSessionExpired,
  CalendarForbiddenFailure() => l10n.errorForbidden,
  CalendarGuestAlreadyRequestedFailure() => l10n.calendarGuestAlreadyRequested,
  CalendarGuestAlreadyMemberFailure() => l10n.calendarGuestAlreadyMember,
  CalendarGuestRecentlyRejectedFailure() => l10n.calendarGuestRecentlyRejected,
  CalendarMeetingNotOpenFailure() => l10n.calendarGuestMeetingNotOpen,
  CalendarMeetingNoReviewerFailure() => l10n.calendarGuestNoReviewer,
  CalendarMeetingUnavailableFailure() => l10n.calendarGuestMeetingUnavailable,
  CalendarMeetingNotFoundFailure() => l10n.calendarGuestMeetingNotFound,
  CalendarGuestRequestFailure() ||
  CalendarLoadFailure() => l10n.calendarGuestRequestError,
};
