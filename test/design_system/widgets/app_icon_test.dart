import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/icons/app_icons.dart';
import 'package:mobile/design_system/widgets/app_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppIcon', () {
    testWidgets('applies color, size and background', (tester) async {
      const color = Color(0xFFE6256D);
      const background = Color(0xFFF8EEF2);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppIcon(
              icon: AppIcons.book,
              color: color,
              size: 32,
              backgroundColor: background,
            ),
          ),
        ),
      );

      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.icon, AppIcons.book);
      expect(icon.color, color);
      expect(icon.size, 32);

      final iconFinder = find.byType(AppIcon);
      final box = tester.widget<SizedBox>(
        find.descendant(
          of: iconFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox && widget.width == 32 && widget.height == 32,
          ),
        ),
      );
      expect(box.width, 32);
      expect(box.height, 32);

      final filtered = tester.widget<ColorFiltered>(
        find.descendant(of: iconFinder, matching: find.byType(ColorFiltered)),
      );
      expect(
        filtered.colorFilter,
        const ColorFilter.mode(color, BlendMode.srcIn),
      );

      final container = tester.widget<Container>(
        find.descendant(of: iconFinder, matching: find.byType(Container)),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, background);
      expect(container.clipBehavior, Clip.none);
    });

    testWidgets('uses another icon and optional layout', (tester) async {
      const radius = BorderRadius.all(Radius.circular(8));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppIcon(
              icon: AppIcons.home,
              color: Color(0xFF2A2429),
              size: 24,
              padding: EdgeInsets.all(4),
              borderRadius: radius,
            ),
          ),
        ),
      );

      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.icon, AppIcons.home);
      expect(icon.size, 24);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppIcon),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, const EdgeInsets.all(4));
      expect(container.clipBehavior, Clip.antiAlias);
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, radius);
      expect(decoration.color, isNull);
    });
  });
}
