import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';

const _url = 'https://example.com/cover.jpg';

Future<void> _pumpCover(WidgetTester tester, Widget cover) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: cover)),
    ),
  );
}

final _bookIcon = find.byWidgetPredicate(
  (widget) => widget is AppIcon && widget.icon == AppIcons.book,
);

void main() {
  group('AppBookCover', () {
    testWidgets('List size is 80x112 by default', (tester) async {
      await _pumpCover(tester, const AppBookCover());

      expect(tester.getSize(find.byType(AppBookCover)), const Size(80, 112));
    });

    testWidgets('Header size is 107x157', (tester) async {
      await _pumpCover(
        tester,
        const AppBookCover(size: AppBookCoverSize.header),
      );

      expect(tester.getSize(find.byType(AppBookCover)), const Size(107, 157));
    });

    testWidgets('Grid size fills the width and keeps the cover ratio', (
      tester,
    ) async {
      await _pumpCover(
        tester,
        const SizedBox(
          width: 114,
          child: AppBookCover(size: AppBookCoverSize.grid),
        ),
      );
      expect(tester.getSize(find.byType(AppBookCover)), const Size(114, 141));

      await _pumpCover(
        tester,
        const SizedBox(
          width: 228,
          child: AppBookCover(size: AppBookCoverSize.grid),
        ),
      );
      expect(tester.getSize(find.byType(AppBookCover)), const Size(228, 282));
    });

    testWidgets('Shows the placeholder when there is no URL', (tester) async {
      await _pumpCover(tester, const AppBookCover());

      expect(_bookIcon, findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('Shows the placeholder when the URL is empty', (tester) async {
      await _pumpCover(tester, const AppBookCover(imageUrl: ''));

      expect(_bookIcon, findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('Renders the image with cover fit when there is a URL', (
      tester,
    ) async {
      await _pumpCover(tester, const AppBookCover(imageUrl: _url));

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );

      expect(image.imageUrl, _url);
      expect(image.fit, BoxFit.cover);
      expect(_bookIcon, findsNothing);
    });

    testWidgets('Falls back to the placeholder when the image fails', (
      tester,
    ) async {
      await _pumpCover(tester, const AppBookCover(imageUrl: _url));

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final context = tester.element(find.byType(CachedNetworkImage));
      final errorWidget = image.errorWidget!(
        context,
        _url,
        Exception('falha de rede simulada'),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: Center(child: errorWidget)),
        ),
      );
      expect(_bookIcon, findsOneWidget);
    });

    testWidgets('Clips the cover with an 8 corner radius', (tester) async {
      await _pumpCover(tester, const AppBookCover(imageUrl: _url));

      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));

      expect(clip.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('Placeholder uses the sunken surface and the muted book icon', (
      tester,
    ) async {
      await _pumpCover(tester, const AppBookCover());

      final box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(AppBookCover),
          matching: find.byType(ColoredBox),
        ),
      );
      final icon = tester.widget<AppIcon>(_bookIcon);

      expect(box.color, AppColorTokens.light.surfaceSunken);
      expect(icon.color, AppColorTokens.light.textMuted);
      expect(icon.size, AppSpacingTokens.standard.s24);
    });

    testWidgets('Is announced as an image when a semantic label is given', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pumpCover(
        tester,
        const AppBookCover(semanticLabel: 'Capa do livro Dom Casmurro'),
      );

      expect(
        tester.getSemantics(find.byType(AppBookCover)),
        matchesSemantics(label: 'Capa do livro Dom Casmurro', isImage: true),
      );
      handle.dispose();
    });

    testWidgets('Is excluded from semantics without a label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpCover(tester, const AppBookCover(imageUrl: _url));

      expect(
        find.descendant(
          of: find.byType(AppBookCover),
          matching: find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.image == true,
          ),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AppBookCover),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
