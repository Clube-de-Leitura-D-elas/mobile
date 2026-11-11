import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_details_page.dart';
import 'package:mobile/features/books/presentation/routes/book_route_paths.dart';

abstract class BookRoutes {
  static const details = BookRoutePaths.details;

  static List<RouteBase> get routes => [
    GoRoute(
      path: details,
      pageBuilder: (context, state) {
        final bookId = state.pathParameters['bookId'] ?? '';
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) => serviceLocator<BookDetailsCubit>()..load(bookId),
            child: const BookDetailsPage(),
          ),
        );
      },
    ),
  ];
}
