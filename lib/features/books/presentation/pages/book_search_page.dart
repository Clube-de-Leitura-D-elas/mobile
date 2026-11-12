import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_state.dart';
import 'package:mobile/features/books/presentation/pages/book_search_screen.dart';

class BookSearchPage extends StatelessWidget {
  const BookSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      body: SafeArea(
        child: BlocConsumer<BookSearchCubit, BookSearchState>(
          listenWhen: (previous, current) =>
              !previous.hasStatusError && current.hasStatusError,
          listener: (context, state) {
            AppToast.show(
              context,
              message: context.l10n.bookReadingStatusError,
              type: AppToastType.error,
            );
            context.read<BookSearchCubit>().clearStatusError();
          },
          builder: (context, state) {
            final cubit = context.read<BookSearchCubit>();
            return BookSearchScreen(
              state: state,
              onQueryChanged: cubit.search,
              onRetry: cubit.retry,
              onLoadMore: cubit.loadMore,
              onStatusTap: cubit.toggleStatus,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: QuickAccessItem.search.index,
        onItemSelected: (index) => context.goToQuickAccessTab(
          index,
          currentIndex: QuickAccessItem.search.index,
        ),
      ),
    );
  }
}
