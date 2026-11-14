import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/presentation/book_failure_message.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mobile/features/books/presentation/widgets/book_details_content.dart';

/// Avisa quem abriu os detalhes (a busca) sobre o status do livro.
/// [isWrite] é `true` quando a leitora mudou o status aqui e `false` quando os
/// detalhes só carregaram o que o backend tem.
typedef ReadingStatusChanged =
    void Function(BookReadingStatus? status, {required bool isWrite});

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({super.key, this.onReadingStatusChanged});

  final ReadingStatusChanged? onReadingStatusChanged;

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
        listener: (context, state) => switch (state.notice) {
          BookDetailsNotice.readingStatusFailed => context.showErrorToast(
            l10n.bookReadingStatusError,
          ),
          BookDetailsNotice.reviewSaved => context.showSuccessToast(
            l10n.bookReviewSuccess,
          ),
          BookDetailsNotice.reviewFailed => context.showErrorToast(
            l10n.bookReviewError,
          ),
          null => null,
        },
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
              BookDetailsStatus.loaded => BookDetailsContent(state: state),
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
