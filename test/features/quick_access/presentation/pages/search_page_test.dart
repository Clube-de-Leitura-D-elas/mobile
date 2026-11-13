import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_page.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_search_cubit.dart';
import 'package:mobile/features/books/presentation/pages/book_search_page.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_page_entity.dart';
import 'package:mobile/features/group_discovery/domain/repository/group_discovery_repository.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/pages/group_search_view.dart';
import 'package:mobile/features/quick_access/presentation/pages/search_page.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

class MockGroupDiscoveryRepository extends Mock
    implements GroupDiscoveryRepository {}

void main() {
  late MockBookRepository bookRepository;
  late MockGroupDiscoveryRepository groupRepository;

  setUpAll(() {
    registerFallbackValue(GroupSearchFilters.empty);
  });

  setUp(() {
    bookRepository = MockBookRepository();
    groupRepository = MockGroupDiscoveryRepository();
    when(
      () => bookRepository.searchBooks(
        query: any(named: 'query'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => const Success(
        BookPage(items: [], page: 1, pageSize: 20, hasMore: false),
      ),
    );
    when(
      () => groupRepository.searchGroups(
        page: any(named: 'page'),
        search: any(named: 'search'),
        filters: any(named: 'filters'),
      ),
    ).thenAnswer(
      (_) async =>
          const Success(GroupSearchPageEntity(items: [], total: 0, genres: [])),
    );
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  BookSearchCubit(bookRepository: bookRepository)..load(),
            ),
            BlocProvider(
              create: (_) =>
                  GroupSearchCubit(repository: groupRepository)..load(),
            ),
          ],
          child: const SearchPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the books tab, with one navigation bar', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.byType(BookSearchPage), findsOneWidget);
    expect(find.byType(GroupSearchView), findsNothing);
    expect(find.byType(BottomNavigationBarWidget), findsOneWidget);
    expect(
      tester
          .widget<BottomNavigationBarWidget>(
            find.byType(BottomNavigationBarWidget),
          )
          .currentIndex,
      QuickAccessItem.search.index,
    );
    expect(
      tester.getSemantics(find.text('Livros')),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Grupos')),
      isSemantics(isSelected: false),
    );
    // A lista de grupos só carrega quando a aba abre.
    verifyNever(
      () => groupRepository.searchGroups(
        page: any(named: 'page'),
        search: any(named: 'search'),
        filters: any(named: 'filters'),
      ),
    );
  });

  testWidgets('switches to the groups tab and keeps what was typed', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupSearchView), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Grupos')),
      isSemantics(isSelected: true),
    );
    expect(find.text('Ainda não há grupos na sua cidade.'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(GroupSearchView),
        matching: find.byType(EditableText),
      ),
      'clube',
    );
    await tester.pump(AppSearchField.defaultDebounce);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Livros'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grupos'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GroupSearchView),
        matching: find.text('clube'),
      ),
      findsOneWidget,
    );
    verify(
      () => groupRepository.searchGroups(
        page: 1,
        search: 'clube',
        filters: GroupSearchFilters.empty,
      ),
    ).called(1);
  });
}
