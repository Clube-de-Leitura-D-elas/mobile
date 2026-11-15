import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_requests_failure.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_cubit.dart';
import 'package:mobile/features/group_join_requests/presentation/cubit/group_join_requests_state.dart';
import 'package:mobile/features/group_join_requests/presentation/widgets/join_request_tile.dart';
import 'package:mobile/features/group_join_requests/presentation/widgets/review_join_request_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';

class GroupJoinRequestsPage extends StatelessWidget {
  const GroupJoinRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      appBar: ScreenHeader.back(title: context.l10n.groupJoinRequestsTitle),
      body: BlocConsumer<GroupJoinRequestsCubit, GroupJoinRequestsState>(
        listenWhen: (previous, current) =>
            previous.reviewOutcome == null && current.reviewOutcome != null,
        listener: _showReviewFeedback,
        builder: (context, state) => switch (state.status) {
          GroupJoinRequestsStatus.loaded when state.requests.isEmpty =>
            const _JoinRequestsEmpty(),
          GroupJoinRequestsStatus.loaded => _JoinRequestsList(state: state),
          GroupJoinRequestsStatus.notCoordinator => AppErrorState(
            message: context.l10n.groupJoinRequestsNotCoordinator,
          ),
          GroupJoinRequestsStatus.error => _JoinRequestsError(
            failure: state.failure,
          ),
          GroupJoinRequestsStatus.loading => Center(
            child: Semantics(
              label: context.l10n.groupJoinRequestsLoading,
              child: CircularProgressIndicator(
                color: context.colors.actionPrimary,
              ),
            ),
          ),
        },
      ),
    );
  }

  void _showReviewFeedback(BuildContext context, GroupJoinRequestsState state) {
    final l10n = context.l10n;
    final outcome = state.reviewOutcome;
    if (outcome == null) return;

    final (String message, AppToastType type) = switch (outcome) {
      JoinRequestReviewOutcome.approved => (
        l10n.groupJoinRequestsApproved,
        AppToastType.success,
      ),
      JoinRequestReviewOutcome.rejected => (
        l10n.groupJoinRequestsRejected,
        AppToastType.success,
      ),
      JoinRequestReviewOutcome.alreadyReviewed => (
        l10n.groupJoinRequestsAlreadyReviewed,
        AppToastType.info,
      ),
      JoinRequestReviewOutcome.notFound => (
        l10n.groupJoinRequestsNotFound,
        AppToastType.info,
      ),
      JoinRequestReviewOutcome.noLongerValid => (
        l10n.groupJoinRequestsNoLongerValid,
        AppToastType.warning,
      ),
      JoinRequestReviewOutcome.failed => (
        _reviewFailureMessage(l10n, state.reviewFailure),
        AppToastType.error,
      ),
    };
    AppToast.show(context, message: message, type: type);
    context.read<GroupJoinRequestsCubit>().clearReviewFeedback();
  }

  static String _reviewFailureMessage(
    AppLocalizations l10n,
    GroupJoinRequestsFailure? failure,
  ) => switch (failure) {
    GroupJoinRequestsNetworkFailure() => l10n.errorNoConnection,
    GroupJoinRequestsSessionExpiredFailure() => l10n.errorSessionExpired,
    _ => l10n.groupJoinRequestsReviewError,
  };
}

class _JoinRequestsList extends StatelessWidget {
  final GroupJoinRequestsState state;

  const _JoinRequestsList({required this.state});

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
        return JoinRequestTile(
          key: ValueKey(request.id),
          request: request,
          reviewing: isThisReviewing ? state.reviewingDecision : null,
          enabled: !state.isReviewing,
          onApprove: () =>
              _confirm(context, request, JoinRequestDecision.approve),
          onReject: () =>
              _confirm(context, request, JoinRequestDecision.reject),
        );
      },
    );
  }

  Future<void> _confirm(
    BuildContext context,
    GroupJoinRequestEntity request,
    JoinRequestDecision decision,
  ) async {
    final cubit = context.read<GroupJoinRequestsCubit>();
    final confirmed = await ReviewJoinRequestDialog.show(
      context,
      decision: decision,
      name: request.name,
    );
    if (confirmed != true) return;
    switch (decision) {
      case JoinRequestDecision.approve:
        await cubit.approve(request.id);
      case JoinRequestDecision.reject:
        await cubit.reject(request.id);
    }
  }
}

class _JoinRequestsEmpty extends StatelessWidget {
  const _JoinRequestsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.s24),
        // Sem liveRegion: depois da última decisão o AppToast já é anunciado.
        child: Text(
          context.l10n.groupJoinRequestsEmpty,
          textAlign: TextAlign.center,
          style: context.typography.bodyDefault.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _JoinRequestsError extends StatelessWidget {
  final GroupJoinRequestsFailure? failure;

  const _JoinRequestsError({required this.failure});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = this.failure;

    return AppErrorState(
      message: switch (failure) {
        GroupJoinRequestsNetworkFailure() => l10n.errorNoConnection,
        GroupJoinRequestsSessionExpiredFailure() => l10n.errorSessionExpired,
        GroupJoinRequestsInvalidFailure() =>
          l10n.groupJoinRequestsGroupUnavailable,
        _ => l10n.groupJoinRequestsLoadError,
      },
      onRetry: failure is GroupJoinRequestsInvalidFailure
          ? null
          : context.read<GroupJoinRequestsCubit>().retry,
      secondaryLabel: failure is GroupJoinRequestsSessionExpiredFailure
          ? l10n.logoutTooltip
          : null,
      onSecondary: () => context.read<SessionCubit>().logOut(),
    );
  }
}
