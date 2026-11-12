import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mobile/features/books/presentation/widgets/book_details_content.dart';

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({super.key, this.onReadingStatusChanged});

  final ValueChanged<BookReadingStatus?>? onReadingStatusChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<BookDetailsCubit, BookDetailsState>(
      // Avisa quem abriu a tela (a busca) para o chip da lista não ficar velho.
      listenWhen: (previous, current) =>
          current.details != null &&
          previous.details?.myStatus != current.details?.myStatus,
      listener: (context, state) =>
          onReadingStatusChanged?.call(state.details?.myStatus),
      child: BlocConsumer<BookDetailsCubit, BookDetailsState>(
        listenWhen: (previous, current) =>
            current.notice != null && previous.notice != current.notice,
        listener: (context, state) => switch (state.notice) {
          BookDetailsNotice.readingStatusFailed => context.showErrorToast(
            l10n.bookReadingStatusError,
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
              BookDetailsStatus.error => AppErrorState(
                message: l10n.bookDetailLoadError,
                onRetry: cubit.retry,
              ),
              BookDetailsStatus.notFound => AppErrorState(
                message: l10n.bookDetailNotFound,
              ),
              BookDetailsStatus.loaded => BookDetailsContent(state: state),
            },
            bottomNavigationBar: BottomNavigationBarWidget(
              currentIndex: QuickAccessItem.search.index,
              onItemSelected: (index) => context.goToQuickAccessTab(
                index,
                currentIndex: QuickAccessItem.search.index,
              ),
            ),
          );
        },
      ),
    );
  }
}
