import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/presentation/book_failure_message.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mobile/features/books/presentation/widgets/book_details_content.dart';
import 'package:mobile/features/books/presentation/widgets/book_recommendation_blocked_dialog.dart';
import 'package:mobile/features/books/presentation/routes/book_recommendation_target.dart';

export 'package:mobile/features/books/presentation/routes/book_recommendation_target.dart'
    show ReadingStatusChanged;

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({
    super.key,
    this.onReadingStatusChanged,
    this.recommendationTarget,
  });

  final ReadingStatusChanged? onReadingStatusChanged;
  final BookRecommendationTarget? recommendationTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        // Ao carregar, mesmo sem status: a lista da busca pode estar velha.
        BlocListener<BookDetailsCubit, BookDetailsState>(
          listenWhen: (previous, current) =>
              previous.details == null && current.details != null,
          listener: (context, state) => onReadingStatusChanged?.call(
            state.details?.myStatus,
            isWrite: false,
          ),
        ),
        BlocListener<BookDetailsCubit, BookDetailsState>(
          listenWhen: (previous, current) =>
              previous.details != null &&
              current.details != null &&
              previous.details?.myStatus != current.details?.myStatus,
          listener: (context, state) => onReadingStatusChanged?.call(
            state.details?.myStatus,
            isWrite: true,
          ),
        ),
      ],
      child: BlocConsumer<BookDetailsCubit, BookDetailsState>(
        listenWhen: (previous, current) =>
            current.notice != null && previous.notice != current.notice,
        listener: _handleNotice,
        builder: (context, state) {
          final cubit = context.read<BookDetailsCubit>();
          final isLoaded = state.status == BookDetailsStatus.loaded;

          return Scaffold(
            backgroundColor: context.colors.bgDefault,
            // O header do livro já tem o botão de voltar sobre a capa.
            appBar: isLoaded
                ? null
                : ScreenHeader.back(title: l10n.bookDetailScreenTitle),
            body: switch (state.status) {
              BookDetailsStatus.loading => Center(
                child: Semantics(
                  label: l10n.bookDetailLoading,
                  child: CircularProgressIndicator(
                    color: context.colors.actionPrimary,
                  ),
                ),
              ),
              BookDetailsStatus.error => _LoadError(
                failure: state.failure,
                onRetry: cubit.retry,
              ),
              BookDetailsStatus.notFound => AppErrorState(
                message: l10n.bookDetailNotFound,
              ),
              BookDetailsStatus.loaded => BookDetailsContent(
                state: state,
                recommendationTarget: recommendationTarget,
              ),
            },
            bottomNavigationBar: BottomNavigationBarWidget(
              currentIndex: QuickAccessItem.search.index,
              onItemSelected: (index) => _onTabSelected(context, index),
            ),
          );
        },
      ),
    );
  }

  void _handleNotice(BuildContext context, BookDetailsState state) {
    final l10n = context.l10n;
    switch (state.notice) {
      case BookDetailsNotice.readingStatusFailed:
        context.showErrorToast(l10n.bookReadingStatusError);
      case BookDetailsNotice.recommendationSucceeded:
        final groupName = state.recommendedGroupName;
        if (groupName != null && groupName.isNotEmpty) {
          context.showSuccessToast(l10n.bookRecommendationSuccess(groupName));
        }
      case BookDetailsNotice.recommendationReplaced:
        final groupName = state.recommendedGroupName;
        if (groupName != null && groupName.isNotEmpty) {
          context.showSuccessToast(l10n.bookRecommendationReplaced(groupName));
        }
      case BookDetailsNotice.recommendationHostBlocked:
        unawaited(BookRecommendationBlockedDialog.show(context));
      case BookDetailsNotice.recommendationAlreadyExists:
        context.showInfoToast(l10n.bookRecommendationAlreadyExists);
      case BookDetailsNotice.recommendationFailed:
        context.showErrorToast(l10n.bookRecommendationError);
      case BookDetailsNotice.reviewSaved:
        context.showSuccessToast(l10n.bookReviewSuccess);
      case BookDetailsNotice.reviewFailed:
        context.showErrorToast(l10n.bookReviewError);
      case null:
        break;
    }
  }

  // A aba Busca aparece selecionada, mas esta tela está empilhada sobre ela.
  // O goToQuickAccessTab ignora o toque na aba atual; aqui ele volta para a
  // busca, que o GoRouter reaproveita com o estado (consulta e lista).
  void _onTabSelected(BuildContext context, int index) {
    context.go(QuickAccessRoutes.pathFor(QuickAccessItem.values[index]));
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.failure, required this.onRetry});

  final BookFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessionExpired = failure is BookSessionExpiredFailure;

    return AppErrorState(
      message: bookDetailsFailureMessage(l10n, failure),
      onRetry: onRetry,
      secondaryLabel: sessionExpired ? l10n.logoutTooltip : null,
      onSecondary: sessionExpired
          ? () => context.read<SessionCubit>().logOut()
          : null,
    );
  }
}
