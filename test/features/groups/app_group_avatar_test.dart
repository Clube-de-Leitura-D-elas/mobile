import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppGroupAvatar', () {
    testWidgets('Shows a placeholder icon when there is no photo URL', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppGroupAvatar(photoUrl: null)));

      expect(find.byIcon(Icons.groups_outlined), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets(
      'Renders a CachedNetworkImage with the given URL when photoUrl is provided',
      (tester) async {
        const url = 'https://example.com/photo.jpg';

        await tester.pumpWidget(_wrap(const AppGroupAvatar(photoUrl: url)));

        final image = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );

        expect(image.imageUrl, url);
        expect(image.fit, BoxFit.cover);
      },
    );

    testWidgets(
      'Falls back to the placeholder icon while loading and on error',
      (tester) async {
        const url = 'https://example.com/photo.jpg';

        await tester.pumpWidget(_wrap(const AppGroupAvatar(photoUrl: url)));

        final image = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        final context = tester.element(find.byType(CachedNetworkImage));
        final loadingFallback = image.placeholder!(context, url);
        final errorFallback = image.errorWidget!(
          context,
          url,
          Exception('falha de rede simulada'),
        );

        expect(loadingFallback, isA<ColoredBox>());
        expect(errorFallback, isA<ColoredBox>());
      },
    );

    testWidgets('Uses a 56x56 circular avatar', (tester) async {
      await tester.pumpWidget(_wrap(const AppGroupAvatar(photoUrl: null)));

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox && widget.width == 56 && widget.height == 56,
        ),
      );

      expect(sizedBox.width, 56);
      expect(sizedBox.height, 56);
      expect(find.byType(ClipOval), findsOneWidget);
    });
  });
}
