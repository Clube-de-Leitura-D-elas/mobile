import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/features/books/domain/entities/book_reading_status.dart';
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
        // Quem abre a tela pode mandar, no extra, um callback do status.
        final extra = state.extra;
        final onReadingStatusChanged = extra is ValueChanged<BookReadingStatus?>
            ? extra
            : null;
        return AppPageTransitions.createPushPage(
          state: state,
          child: BlocProvider(
            create: (_) => serviceLocator<BookDetailsCubit>()..load(bookId),
            child: BookDetailsPage(
              onReadingStatusChanged: onReadingStatusChanged,
            ),
          ),
        );
      },
    ),
  ];
}
