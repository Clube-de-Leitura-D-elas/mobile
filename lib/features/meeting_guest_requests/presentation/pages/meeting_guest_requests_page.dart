import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_request_entity.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/meeting_guest_requests_failure.dart';
import 'package:mobile/features/meeting_guest_requests/domain/entities/guest_request_decision.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_state.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/widgets/guest_request_tile.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/widgets/review_guest_request_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MeetingGuestRequestsPage extends StatelessWidget {
  const MeetingGuestRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      appBar: ScreenHeader.back(title: context.l10n.meetingGuestRequestsTitle),
      body: BlocConsumer<MeetingGuestRequestsCubit, MeetingGuestRequestsState>(
        listenWhen: (previous, current) =>
            previous.reviewOutcome == null && current.reviewOutcome != null,
        listener: _showReviewFeedback,
        builder: (context, state) => switch (state.status) {
          MeetingGuestRequestsStatus.loaded when state.requests.isEmpty =>
            const _GuestRequestsEmpty(),
          MeetingGuestRequestsStatus.loaded => _GuestRequestsList(state: state),
          MeetingGuestRequestsStatus.notReviewer => AppErrorState(
            message: context.l10n.meetingGuestRequestsNotReviewer,
          ),
          MeetingGuestRequestsStatus.error => _GuestRequestsError(
            failure: state.failure,
          ),
          MeetingGuestRequestsStatus.loading => Center(
            child: Semantics(
              label: context.l10n.meetingGuestRequestsLoading,
              child: CircularProgressIndicator(
                color: context.colors.actionPrimary,
              ),
            ),
          ),
        },
      ),
    );
  }

  void _showReviewFeedback(
    BuildContext context,
    MeetingGuestRequestsState state,
  ) {
    final l10n = context.l10n;
    final outcome = state.reviewOutcome;
    if (outcome == null) return;

    final (String message, AppToastType type) = switch (outcome) {
      GuestRequestReviewOutcome.approved => (
        l10n.meetingGuestRequestsApproved,
        AppToastType.success,
      ),
      GuestRequestReviewOutcome.rejected => (
        l10n.meetingGuestRequestsRejected,
        AppToastType.success,
      ),
      GuestRequestReviewOutcome.alreadyReviewed => (
        l10n.meetingGuestRequestsAlreadyReviewed,
        AppToastType.info,
      ),
      GuestRequestReviewOutcome.notFound => (
        l10n.meetingGuestRequestsNotFound,
        AppToastType.info,
      ),
      GuestRequestReviewOutcome.noLongerValid => (
        l10n.meetingGuestRequestsNoLongerValid,
        AppToastType.warning,
      ),
      GuestRequestReviewOutcome.failed => (
        _reviewFailureMessage(l10n, state.reviewFailure),
        AppToastType.error,
      ),
    };
    AppToast.show(context, message: message, type: type);
    context.read<MeetingGuestRequestsCubit>().clearReviewFeedback();
  }

  static String _reviewFailureMessage(
    AppLocalizations l10n,
    MeetingGuestRequestsFailure? failure,
  ) => switch (failure) {
    MeetingGuestRequestsNetworkFailure() => l10n.errorNoConnection,
    MeetingGuestRequestsSessionExpiredFailure() => l10n.errorSessionExpired,
    _ => l10n.meetingGuestRequestsReviewError,
  };
}

class _GuestRequestsList extends StatelessWidget {
  final MeetingGuestRequestsState state;

  const _GuestRequestsList({required this.state});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final requests = state.requests;
    // O padding explícito desliga o recuo automático da área segura.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ListView.separated(
      padding: EdgeInsets.all(
        spacing.s24,
      ).copyWith(bottom: spacing.s24 + bottomInset),
      itemCount: requests.length,
      separatorBuilder: (_, _) => SizedBox(height: spacing.s24),
      itemBuilder: (context, index) {
        final request = requests[index];
        final isThisReviewing = state.reviewingId == request.id;
        return GuestRequestTile(
          key: ValueKey(request.id),
          request: request,
          reviewing: isThisReviewing ? state.reviewingDecision : null,
          enabled: !state.isReviewing,
          onApprove: () =>
              _confirm(context, request, GuestRequestDecision.approve),
          onReject: () =>
              _confirm(context, request, GuestRequestDecision.reject),
        );
      },
    );
  }

  Future<void> _confirm(
    BuildContext context,
    MeetingGuestRequestEntity request,
    GuestRequestDecision decision,
  ) async {
    final cubit = context.read<MeetingGuestRequestsCubit>();
    final confirmed = await ReviewGuestRequestDialog.show(
      context,
      decision: decision,
      name: request.name,
    );
    if (confirmed != true) return;
    switch (decision) {
      case GuestRequestDecision.approve:
        await cubit.approve(request.id);
      case GuestRequestDecision.reject:
        await cubit.reject(request.id);
    }
  }
}

class _GuestRequestsEmpty extends StatelessWidget {
  const _GuestRequestsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.s24),
        // Sem liveRegion: depois da última decisão o AppToast já é anunciado.
        child: Text(
          context.l10n.meetingGuestRequestsEmpty,
          textAlign: TextAlign.center,
          style: context.typography.bodyDefault.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _GuestRequestsError extends StatelessWidget {
  final MeetingGuestRequestsFailure? failure;

  const _GuestRequestsError({required this.failure});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = this.failure;

    return AppErrorState(
      message: switch (failure) {
        MeetingGuestRequestsNetworkFailure() => l10n.errorNoConnection,
        MeetingGuestRequestsSessionExpiredFailure() => l10n.errorSessionExpired,
        MeetingGuestRequestsInvalidFailure() =>
          l10n.meetingGuestRequestsMeetingUnavailable,
        _ => l10n.meetingGuestRequestsLoadError,
      },
      onRetry: failure is MeetingGuestRequestsInvalidFailure
          ? null
          : context.read<MeetingGuestRequestsCubit>().retry,
      secondaryLabel: failure is MeetingGuestRequestsSessionExpiredFailure
          ? l10n.logoutTooltip
          : null,
      onSecondary: () => context.read<SessionCubit>().logOut(),
    );
  }
}
