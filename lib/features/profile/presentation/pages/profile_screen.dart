import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/books/presentation/routes/book_route_paths.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_failure.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_state.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_groups_carousel.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_header.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_reviewed_books.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfileEntity? profile;

  /// Livros lidos, grupos e avaliações, que vêm de outra chamada.
  final ProfileSummaryState summary;
  final VoidCallback? onRetry;

  /// Chamado ao voltar de um grupo ou livro aberto pelo perfil, que pode ter
  /// mudado os contadores. Fechar um diálogo não conta.
  final VoidCallback? onReturn;

  const ProfileScreen({
    super.key,
    this.profile,
    this.summary = const ProfileSummaryLoading(),
    this.onRetry,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final name = profile?.name ?? '';
    final summary = this.summary;
    final loaded = summary is ProfileSummaryLoaded ? summary.summary : null;

    return ListView(
      padding: EdgeInsets.all(spacing.s16),
      children: [
        const _ProfileTitleRow(),
        SizedBox(height: spacing.s16),
        ProfileHeader(
          name: name.isEmpty ? l10n.defaultUserName : name,
          booksReadCount: loaded?.booksReadCount,
          groupsCount: loaded?.groups.length,
          photoUrl: profile?.photoUrl,
          onPhotoChanged: context.read<SessionCubit>().updateProfilePhoto,
        ),
        SizedBox(height: spacing.s24),
        switch (summary) {
          ProfileSummaryLoading() => const _SummaryLoading(),
          ProfileSummaryError(:final failure) => _SummaryError(
            failure: failure,
            onRetry: onRetry,
          ),
          ProfileSummaryLoaded(:final summary) => _SummarySections(
            summary: summary,
            onReturn: onReturn,
          ),
        },
      ],
    );
  }
}

class _SummarySections extends StatelessWidget {
  const _SummarySections({required this.summary, this.onReturn});

  final ProfileSummaryEntity summary;
  final VoidCallback? onReturn;

  Future<void> _openGroup(BuildContext context, String groupId) async {
    await context.push<Object?>(
      Uri(
        path: GroupRoutes.groupDetails,
        queryParameters: {'group_id': groupId},
      ).toString(),
    );
    onReturn?.call();
  }

  Future<void> _openBook(BuildContext context, String bookId) async {
    await context.push<Object?>(BookRoutePaths.detailsFor(bookId));
    onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(l10n.profileMyGroupsTitle),
        SizedBox(height: spacing.s16),
        if (summary.groups.isEmpty)
          _EmptyText(l10n.profileNoGroups)
        else
          ProfileGroupsCarousel(
            groups: summary.groups,
            onGroupTap: (groupId) => _openGroup(context, groupId),
          ),
        SizedBox(height: spacing.s24),
        Divider(color: context.colors.borderDefault, height: 1),
        SizedBox(height: spacing.s24),
        _SectionTitle(l10n.profileReviewedBooksTitle),
        SizedBox(height: spacing.s16),
        if (summary.reviewedBooks.isEmpty)
          _EmptyText(l10n.profileNoReviewedBooks)
        else ...[
          ProfileReviewedBooks(
            books: summary.reviewedBooks,
            onBookTap: (bookId) => _openBook(context, bookId),
          ),
          SizedBox(height: spacing.s16),
          Divider(color: context.colors.borderDefault, height: 1),
          // TODO(CLU-294): abrir a lista completa de livros avaliados
          // (get-my-reviewed-books).
          AppButton.ghost(
            label: l10n.profileSeeAllBooks,
            size: AppButtonSize.lg,
            onPressed: null,
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: context.typography.headingH3.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.typography.bodyDefault.copyWith(
        color: context.colors.textMuted,
      ),
    );
  }
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.spacing.s24),
      child: Center(
        child: Semantics(
          label: context.l10n.profileSummaryLoading,
          child: CircularProgressIndicator(color: context.colors.actionPrimary),
        ),
      ),
    );
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.failure, required this.onRetry});

  final ProfileSummaryFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionExpired = failure is ProfileSummarySessionExpiredFailure;
    final message = switch (failure) {
      ProfileSummaryNetworkFailure() => l10n.errorNoConnection,
      ProfileSummarySessionExpiredFailure() => l10n.errorSessionExpired,
      ProfileSummaryLoadFailure() => l10n.profileSummaryLoadError,
    };

    // Sessão expirada não se resolve tentando de novo: a saída é sair da conta.
    return AppErrorState(
      message: message,
      onRetry: sessionExpired ? null : onRetry,
      secondaryLabel: sessionExpired ? l10n.logoutTooltip : null,
      onSecondary: sessionExpired
          ? () => context.read<SessionCubit>().logOut()
          : null,
    );
  }
}

class _ProfileTitleRow extends StatelessWidget {
  const _ProfileTitleRow();

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return const LogoutConfirmDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.profileTitle,
              style: typography.headingH2.copyWith(color: colors.textDefault),
            ),
          ),
        ),
        Semantics(
          label: l10n.profileLogoutButtonLabel,
          button: true,
          child: InkWell(
            onTap: () => _showLogoutConfirmation(context),
            borderRadius: BorderRadius.circular(spacing.s8),
            // 12 + 24 + 12: alvo de toque de 48.
            child: Padding(
              padding: EdgeInsets.all(spacing.s12),
              child: AppIcon(
                icon: AppIcons.leave,
                size: spacing.s24,
                color: colors.textDefault,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
