import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mobile/features/books/presentation/widgets/book_details_content.dart';
import 'package:mobile/features/books/presentation/widgets/book_details_message.dart';

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<BookDetailsCubit, BookDetailsState>(
      listenWhen: (previous, current) =>
          current.notice != null && previous.notice != current.notice,
      listener: (context, state) => switch (state.notice) {
        BookDetailsNotice.readingStatusFailed => context.showErrorToast(
          l10n.bookDetailReadingStatusError,
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
            BookDetailsStatus.error => BookDetailsMessage(
              message: l10n.bookDetailLoadError,
              onRetry: cubit.retry,
            ),
            BookDetailsStatus.notFound => BookDetailsMessage(
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
    );
  }
}
