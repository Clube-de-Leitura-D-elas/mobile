import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/design_system/widgets/app_bottom_navigation_bar.dart';

class _RecordingAssetBundle extends CachingAssetBundle {
  final List<String> loadedKeys = [];

  @override
  Future<ByteData> load(String key) {
    loadedKeys.add(key);
    return Completer<ByteData>().future;
  }
}

void main() {
  group('BottomNavigationBarWidget', () {
    const labels = ['Início', 'Busca', 'Adicionar', 'Calendário', 'Perfil'];

    Future<_RecordingAssetBundle> pumpWithBundle(
      WidgetTester tester, {
      required int currentIndex,
      ValueChanged<int>? onItemSelected,
    }) async {
      final bundle = _RecordingAssetBundle();

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: bundle,
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: BottomNavigationBarWidget(
                currentIndex: currentIndex,
                onItemSelected: onItemSelected ?? (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      return bundle;
    }

    testWidgets('Renders the 5 fixed items', (tester) async {
      final bundle = await pumpWithBundle(tester, currentIndex: 0);

      expect(bundle.loadedKeys, hasLength(5));
      for (final label in labels) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
    });

    testWidgets('Marks only the current index as selected', (tester) async {
      await pumpWithBundle(tester, currentIndex: 2);

      for (var i = 0; i < labels.length; i++) {
        final semantics = tester.getSemantics(find.bySemanticsLabel(labels[i]));
        final isSelected =
            semantics.flagsCollection.isSelected == Tristate.isTrue;
        expect(isSelected, i == 2);
      }
    });

    testWidgets('Requests the active .si asset for the selected item', (
      tester,
    ) async {
      final bundle = await pumpWithBundle(tester, currentIndex: 3);

      expect(bundle.loadedKeys, contains('assets/si/type=calendar_active.si'));
      expect(
        bundle.loadedKeys,
        isNot(contains('assets/si/type=calendar_inactive.si')),
      );
    });

    testWidgets('Requests the inactive .si asset for unselected items', (
      tester,
    ) async {
      final bundle = await pumpWithBundle(tester, currentIndex: 3);

      expect(bundle.loadedKeys, contains('assets/si/type=home_inactive.si'));
      expect(bundle.loadedKeys, contains('assets/si/type=search_inactive.si'));
      expect(bundle.loadedKeys, contains('assets/si/type=profile_inactive.si'));
      expect(
        bundle.loadedKeys,
        isNot(contains('assets/si/type=home_active.si')),
      );
    });

    testWidgets('Tapping an item notifies onItemSelected with its index', (
      tester,
    ) async {
      int? tapped;

      await pumpWithBundle(
        tester,
        currentIndex: 0,
        onItemSelected: (index) => tapped = index,
      );

      await tester.tap(find.bySemanticsLabel('Perfil'));
      await tester.pump();

      expect(tapped, 4);
    });

    testWidgets('Uses a top border in borderDefault color from the theme', (
      tester,
    ) async {
      await pumpWithBundle(tester, currentIndex: 0);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BottomNavigationBarWidget),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.top.color, AppColorTokens.light.borderDefault);
      expect(border.top.width, 1);
    });

    testWidgets('Background color comes from surfaceDefault token', (
      tester,
    ) async {
      await pumpWithBundle(tester, currentIndex: 0);

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(BottomNavigationBarWidget),
          matching: find.byType(Material),
        ),
      );

      expect(material.color, AppColorTokens.light.surfaceDefault);
    });

    testWidgets('Throws when currentIndex is out of range', (tester) async {
      expect(
        () =>
            BottomNavigationBarWidget(currentIndex: 5, onItemSelected: (_) {}),
        throwsAssertionError,
      );
    });
  });
}
