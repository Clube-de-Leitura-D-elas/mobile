import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/widgets/book_review_comment.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> _pumpComment(WidgetTester tester, String text) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: 320, child: BookReviewComment(text)),
        ),
      ),
    ),
  );
}

Text _commentText(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text));

void main() {
  final longComment = List.filled(
    30,
    'Esse livro mexeu muito comigo, recomendo demais.',
  ).join(' ');

  testWidgets('shows a short comment whole, without "Ver mais"', (
    tester,
  ) async {
    await _pumpComment(tester, 'Gostei muito.');

    expect(_commentText(tester, 'Gostei muito.').maxLines, isNull);
    expect(find.text('Ver mais'), findsNothing);
  });

  testWidgets('clamps a long comment and toggles it with Ver mais/menos', (
    tester,
  ) async {
    await _pumpComment(tester, longComment);

    expect(
      _commentText(tester, longComment).maxLines,
      BookReviewComment.collapsedMaxLines,
    );
    final collapsedHeight = tester.getSize(find.text(longComment)).height;

    await tester.tap(find.text('Ver mais'));
    await tester.pump();

    expect(_commentText(tester, longComment).maxLines, isNull);
    expect(
      tester.getSize(find.text(longComment)).height,
      greaterThan(collapsedHeight),
    );
    expect(find.text('Ver menos'), findsOneWidget);

    await tester.ensureVisible(find.text('Ver menos'));
    await tester.tap(find.text('Ver menos'));
    await tester.pump();

    expect(
      _commentText(tester, longComment).maxLines,
      BookReviewComment.collapsedMaxLines,
    );
  });

  testWidgets('counts line breaks typed by the reader', (tester) async {
    const manyLines = 'a\nb\nc\nd\ne\nf';
    await _pumpComment(tester, manyLines);

    expect(find.text('Ver mais'), findsOneWidget);
  });

  testWidgets('the toggle has a 48dp tap target and is announced as button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _pumpComment(tester, longComment);

    expect(
      tester
          .getSize(
            find.ancestor(
              of: find.text('Ver mais'),
              matching: find.byType(InkWell),
            ),
          )
          .height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSemantics(find.text('Ver mais')),
      isSemantics(
        label: 'Ver mais',
        isButton: true,
        hasExpandedState: true,
        isExpanded: false,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
