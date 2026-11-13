import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_cubit.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mobile/features/calendar/presentation/pages/calendar_page.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/quick_access/presentation/pages/quick_access_placeholder_screen.dart';
import 'package:mobile/features/quick_access/presentation/pages/search_page.dart';

abstract class QuickAccessRoutes {
  static const String home = '/home';
  static const String search = '/search';
  static const String add = '/add';
  static const String calendar = '/calendar';
  static const String profile = '/profile';

  static String pathFor(QuickAccessItem item) => switch (item) {
    QuickAccessItem.home => home,
    QuickAccessItem.search => search,
    QuickAccessItem.plus => add,
    QuickAccessItem.calendar => calendar,
    QuickAccessItem.profile => profile,
  };

  static bool isTabPath(String location) =>
      QuickAccessItem.values.any((item) => pathFor(item) == location);

  /// Obs. abas ainda sem tela própria: só a nav bar, sem conteúdo.
  static List<RouteBase> get routes => [
    for (final item in QuickAccessItem.values)
      if (item != QuickAccessItem.home)
        GoRoute(
          path: pathFor(item),
          pageBuilder: (context, state) {
            final Widget pageChild = switch (item) {
              QuickAccessItem.profile => BlocProvider(
                create: (_) => serviceLocator<ProfileSummaryCubit>()..load(),
                child: const ProfilePage(),
              ),
              QuickAccessItem.search => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => serviceLocator<BookSearchCubit>()..load(),
                  ),
                  // Preguiçoso: só carrega quando a aba Grupos abre.
                  BlocProvider(
                    create: (_) => serviceLocator<GroupSearchCubit>()..load(),
                  ),
                ],
                child: const SearchPage(),
              ),
              QuickAccessItem.calendar => BlocProvider(
                create: (_) => serviceLocator<CalendarCubit>()..load(),
                child: const CalendarPage(),
              ),
              _ => QuickAccessPlaceholderScreen(item: item),
            };

            return AppPageTransitions.createFadePage(
              state: state,
              child: pageChild,
            );
          },
        ),
  ];
}

extension QuickAccessNavigation on BuildContext {
  void goToQuickAccessTab(int index, {required int currentIndex}) {
    if (index == currentIndex) return;
    final item = QuickAccessItem.values[index];
    GoRouter.of(this).go(QuickAccessRoutes.pathFor(item));
  }
}
