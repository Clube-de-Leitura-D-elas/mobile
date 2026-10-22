import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/groups_empty_state.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mobile/features/home/presentation/widgets/home_empty_state.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  Widget buildSubject(HomeEmptyKind kind) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: HomeEmptyState(kind: kind)),
    );
  }

  group('HomeEmptyState', () {
    testWidgets('renders GroupsEmptyState when there are no groups', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(HomeEmptyKind.noGroups));

      expect(find.byType(GroupsEmptyState), findsOneWidget);

      final context = tester.element(find.byType(HomeEmptyState));
      final l10n = AppLocalizations.of(context);

      expect(find.text(l10n.emptyGroupsTitle), findsOneWidget);
      expect(find.text(l10n.emptyGroupsMessage), findsOneWidget);
    });

    testWidgets('renders the no search results message', (tester) async {
      await tester.pumpWidget(buildSubject(HomeEmptyKind.noSearchResults));

      final context = tester.element(find.byType(HomeEmptyState));
      final l10n = AppLocalizations.of(context);

      expect(find.text(l10n.emptyGroupsSearch), findsOneWidget);
      expect(find.byType(GroupsEmptyState), findsNothing);
    });

    testWidgets('renders the no unanswered groups message', (tester) async {
      await tester.pumpWidget(buildSubject(HomeEmptyKind.noUnanswered));

      final context = tester.element(find.byType(HomeEmptyState));
      final l10n = AppLocalizations.of(context);

      expect(find.text(l10n.emptyGroupsUnanswered), findsOneWidget);
      expect(find.byType(GroupsEmptyState), findsNothing);
    });

    testWidgets('renders the no answered groups message', (tester) async {
      await tester.pumpWidget(buildSubject(HomeEmptyKind.noAnswered));

      final context = tester.element(find.byType(HomeEmptyState));
      final l10n = AppLocalizations.of(context);

      expect(find.text(l10n.emptyGroupsAnswered), findsOneWidget);
      expect(find.byType(GroupsEmptyState), findsNothing);
    });
  });
}
