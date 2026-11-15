import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/pages/book_search_page.dart';
import 'package:mobile/features/group_discovery/presentation/pages/group_search_view.dart';
import 'package:mobile/features/quick_access/presentation/widgets/keep_alive_tab.dart';

/// Aba Buscar da navegação: livros e grupos em abas no topo.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.bgDefault,
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                labelColor: colors.textBrand,
                unselectedLabelColor: colors.textMuted,
                indicatorColor: colors.actionPrimary,
                dividerColor: colors.borderDefault,
                labelStyle: typography.bodyDefaultEmphasis,
                unselectedLabelStyle: typography.bodyDefault,
                tabs: [
                  Tab(text: l10n.searchTabBooks),
                  Tab(text: l10n.searchTabGroups),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    KeepAliveTab(child: BookSearchPage()),
                    KeepAliveTab(child: GroupSearchView()),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          currentIndex: QuickAccessItem.search.index,
          onItemSelected: (index) => context.goToQuickAccessTab(
            index,
            currentIndex: QuickAccessItem.search.index,
          ),
        ),
      ),
    );
  }
}
