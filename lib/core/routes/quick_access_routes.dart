import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routes/app_page_transitions.dart';
import 'package:mobile/design_system/design_system.dart';

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
          pageBuilder: (context, state) => AppPageTransitions.createFadePage(
            state: state,
            child: QuickAccessPlaceholderScreen(item: item),
          ),
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

class QuickAccessPlaceholderScreen extends StatelessWidget {
  final QuickAccessItem item;

  const QuickAccessPlaceholderScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      body: const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: item.index,
        onItemSelected: (index) =>
            context.goToQuickAccessTab(index, currentIndex: item.index),
      ),
    );
  }
}
