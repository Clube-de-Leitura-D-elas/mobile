import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/widgets/book_list_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> _pumpTile(WidgetTester tester, BookListTile tile) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: tile),
    ),
  );
}

void main() {
  testWidgets('shows the cover, title, author, genre and read chip', (
    tester,
  ) async {
    await _pumpTile(
      tester,
      const BookListTile(
        title: 'Harry Potter e a Pedra Filosofal',
        author: 'J. K. Rowling',
        genre: 'Fantasia',
        imageUrl: 'https://example.com/capa.jpg',
        status: ReadingStatusChipState.read,
      ),
    );

    expect(find.byType(AppBookCover), findsOneWidget);
    expect(
      tester.widget<AppBookCover>(find.byType(AppBookCover)).imageUrl,
      'https://example.com/capa.jpg',
    );
    expect(
      find.bySemanticsLabel(
        'Harry Potter e a Pedra Filosofal, J. K. Rowling, Fantasia',
      ),
      findsOneWidget,
    );
    expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);
    expect(find.text('J. K. Rowling'), findsOneWidget);
    expect(find.text('Fantasia'), findsOneWidget);
    expect(find.text('Já lido'), findsOneWidget);
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Harry Potter e a Pedra Filosofal'),
                  matching: find.byType(InkWell),
                )
                .first,
          )
          .height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: find.text('J. K. Rowling'),
                  matching: find.byType(InkWell),
                )
                .first,
          )
          .height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.widget<AppReadingStatusChip>(find.byType(AppReadingStatusChip)),
      isA<AppReadingStatusChip>().having(
        (chip) => chip.state,
        'state',
        ReadingStatusChipState.read,
      ),
    );
  });

  testWidgets('shows "Marcar como lido" as its own chip state', (tester) async {
    await _pumpTile(
      tester,
      const BookListTile(
        title: 'Harry Potter e o Prisioneiro de Azkaban',
        author: 'J. K. Rowling',
        genre: 'Fantasia',
        status: ReadingStatusChipState.markAsRead,
      ),
    );

    expect(find.text('Marcar como lido'), findsOneWidget);
    expect(find.text('Já lido'), findsNothing);
    expect(find.text('Quero ler'), findsNothing);
    expect(
      tester.widget<AppReadingStatusChip>(find.byType(AppReadingStatusChip)),
      isA<AppReadingStatusChip>().having(
        (chip) => chip.state,
        'state',
        ReadingStatusChipState.markAsRead,
      ),
    );
  });

  testWidgets('hides the chip when the book has no reading status', (
    tester,
  ) async {
    await _pumpTile(
      tester,
      const BookListTile(
        title: 'Harry Potter e a Pedra Filosofal',
        author: 'J. K. Rowling',
        genre: 'Fantasia',
      ),
    );

    expect(find.byType(AppReadingStatusChip), findsNothing);
  });

  testWidgets('drops empty author and genre from the row and the label', (
    tester,
  ) async {
    await _pumpTile(
      tester,
      const BookListTile(title: 'Duna', author: '', genre: ''),
    );

    expect(find.text('Duna'), findsOneWidget);
    expect(find.bySemanticsLabel('Duna'), findsOneWidget);
    expect(find.text(''), findsNothing);
  });

  testWidgets('keeps the genre when the author is empty', (tester) async {
    await _pumpTile(
      tester,
      const BookListTile(title: 'Duna', author: '', genre: 'Ficção'),
    );

    expect(find.text('Ficção'), findsOneWidget);
    expect(find.bySemanticsLabel('Duna, Ficção'), findsOneWidget);
  });

  testWidgets('a loading chip receives the flag and ignores taps', (
    tester,
  ) async {
    var chipTaps = 0;

    await _pumpTile(
      tester,
      BookListTile(
        title: 'Duna',
        author: 'Frank Herbert',
        genre: 'Ficção',
        status: ReadingStatusChipState.wantToRead,
        isStatusLoading: true,
        onStatusTap: () => chipTaps++,
      ),
    );

    expect(
      tester.widget<AppReadingStatusChip>(find.byType(AppReadingStatusChip)),
      isA<AppReadingStatusChip>().having(
        (chip) => chip.isLoading,
        'isLoading',
        isTrue,
      ),
    );

    await tester.tap(find.text('Quero ler'));
    await tester.pump();
    expect(chipTaps, 0);
  });

  testWidgets('row tap and chip tap stay separate', (tester) async {
    var rowTaps = 0;
    var chipTaps = 0;

    await _pumpTile(
      tester,
      BookListTile(
        title: 'Harry Potter e a Câmara Secreta',
        author: 'J. K. Rowling',
        genre: 'Fantasia',
        status: ReadingStatusChipState.wantToRead,
        onTap: () => rowTaps++,
        onStatusTap: () => chipTaps++,
      ),
    );

    await tester.tap(find.text('Harry Potter e a Câmara Secreta'));
    await tester.pump();
    expect(rowTaps, 1);
    expect(chipTaps, 0);

    await tester.tap(find.text('Quero ler'));
    await tester.pump();
    expect(rowTaps, 1);
    expect(chipTaps, 1);
  });

  testWidgets('the row semantics tap opens the row and not the chip', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var rowTaps = 0;
    var chipTaps = 0;
    await _pumpTile(
      tester,
      BookListTile(
        title: 'Duna',
        author: 'Frank Herbert',
        genre: 'Ficção',
        status: ReadingStatusChipState.markAsRead,
        onTap: () => rowTaps++,
        onStatusTap: () => chipTaps++,
      ),
    );

    final row = tester.getSemantics(
      find.bySemanticsLabel('Duna, Frank Herbert, Ficção'),
    );
    final chip = tester.getSemantics(find.bySemanticsLabel('Marcar como lido'));
    expect(row.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(chip.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

    row.owner!.performAction(row.id, SemanticsAction.tap);
    await tester.pump();
    expect(rowTaps, 1);
    expect(chipTaps, 0);

    chip.owner!.performAction(chip.id, SemanticsAction.tap);
    await tester.pump();
    expect(rowTaps, 1);
    expect(chipTaps, 1);
    handle.dispose();
  });

  testWidgets('the author block is not an unlabeled semantic button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpTile(
      tester,
      BookListTile(
        title: 'Duna',
        author: 'Frank Herbert',
        genre: 'Ficção',
        status: ReadingStatusChipState.markAsRead,
        onTap: () {},
        onStatusTap: () {},
      ),
    );

    final roots = <SemanticsNode>[];
    void collectRoots(PipelineOwner owner) {
      final root = owner.semanticsOwner?.rootSemanticsNode;
      if (root != null) {
        roots.add(root);
      }
      owner.visitChildren(collectRoots);
    }

    collectRoots(tester.binding.rootPipelineOwner);
    expect(roots, isNotEmpty);
    for (final node in roots.expand(collectAllSemanticsNodesFrom)) {
      _expectLabeledTap(node);
    }

    expect(
      find.bySemanticsLabel('Duna, Frank Herbert, Ficção'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Marcar como lido'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a row without a tap does not announce a disabled control', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpTile(
      tester,
      const BookListTile(
        title: 'Duna',
        author: 'Frank Herbert',
        genre: 'Ficção',
      ),
    );

    final node = tester.getSemantics(
      find.bySemanticsLabel('Duna, Frank Herbert, Ficção'),
    );
    expect(node.getSemanticsData().flagsCollection.isEnabled, Tristate.none);
    handle.dispose();
  });

  testWidgets(
    'mark as read chip wraps below the author on a narrow large-text row',
    (tester) async {
      const tile = BookListTile(
        title: 'Harry Potter e o Prisioneiro de Azkaban',
        author: 'J. K. Rowling',
        genre: 'Fantasia',
        status: ReadingStatusChipState.markAsRead,
      );

      Future<void> pumpAt(double width) {
        return tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('pt'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              );
            },
            home: Scaffold(
              body: SizedBox(width: width, child: tile),
            ),
          ),
        );
      }

      await pumpAt(900);
      expect(
        tester.getTopLeft(find.text('Marcar como lido')).dy,
        lessThan(tester.getBottomLeft(find.text('J. K. Rowling')).dy),
      );
      final chipWidth = tester.getSize(find.byType(AppReadingStatusChip)).width;
      final inset =
          tester.getTopLeft(find.text('J. K. Rowling')).dx -
          tester.getTopLeft(find.byType(BookListTile)).dx;
      // Folga menor que o alvo de 48 do autor: o chip cabe sozinho e desce.
      await pumpAt(inset + chipWidth + 32);

      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.text('Marcar como lido')).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(find.text('Fantasia')).dy),
      );
    },
  );

  testWidgets('relayouts when the chip, the author and the gap change', (
    tester,
  ) async {
    const withChip = BookListTile(
      title: 'Duna',
      author: 'Frank Herbert',
      genre: 'Ficção',
      status: ReadingStatusChipState.markAsRead,
    );

    Future<void> pump({
      required double width,
      required double gap,
      required BookListTile tile,
    }) {
      final theme = AppTheme.light;
      return tester.pumpWidget(
        MaterialApp(
          themeAnimationDuration: Duration.zero,
          theme: theme.copyWith(
            extensions: [
              for (final extension in theme.extensions.values)
                if (extension is AppSpacingTokens)
                  extension.copyWith(s8: gap)
                else
                  extension,
            ],
          ),
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(width: width, child: tile),
          ),
        ),
      );
    }

    await pump(
      width: 900,
      gap: 8,
      tile: const BookListTile(title: 'Duna', author: '', genre: ''),
    );
    await pump(width: 900, gap: 8, tile: withChip);

    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(AppReadingStatusChip)).dy,
      lessThan(tester.getBottomLeft(find.text('Frank Herbert')).dy),
    );

    final chipWidth = tester.getSize(find.byType(AppReadingStatusChip)).width;
    final inset =
        tester.getTopLeft(find.text('Frank Herbert')).dx -
        tester.getTopLeft(find.byType(BookListTile)).dx;
    final narrow = inset + chipWidth + 32;
    await pump(width: narrow, gap: 8, tile: withChip);

    final meta = find
        .ancestor(of: find.text('Ficção'), matching: find.byType(Column))
        .first;
    expect(
      tester.getTopLeft(find.byType(AppReadingStatusChip)).dy -
          tester.getBottomLeft(meta).dy,
      8,
    );

    await pump(width: narrow, gap: 20, tile: withChip);
    expect(
      tester.getTopLeft(find.byType(AppReadingStatusChip)).dy -
          tester.getBottomLeft(meta).dy,
      20,
    );

    await pump(width: narrow, gap: 20, tile: withChip);
    expect(
      tester.getTopLeft(find.byType(AppReadingStatusChip)).dy -
          tester.getBottomLeft(meta).dy,
      20,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('aligns the text with the top of the cover', (tester) async {
    await _pumpTile(
      tester,
      const BookListTile(
        title: 'Duna',
        author: 'Frank Herbert',
        genre: 'Ficção',
        status: ReadingStatusChipState.read,
      ),
    );

    final textColumn = find
        .ancestor(of: find.text('Duna'), matching: find.byType(Column))
        .first;
    expect(
      tester.getTopLeft(textColumn).dy,
      tester.getTopLeft(find.byType(AppBookCover)).dy,
    );
  });

  testWidgets('the gap between the cover and the title opens the row', (
    tester,
  ) async {
    var rowTaps = 0;
    var chipTaps = 0;
    await _pumpTile(
      tester,
      BookListTile(
        title: 'Duna',
        author: 'Frank Herbert',
        genre: 'Ficção',
        status: ReadingStatusChipState.markAsRead,
        onTap: () => rowTaps++,
        onStatusTap: () => chipTaps++,
      ),
    );

    final cover = tester.getRect(find.byType(AppBookCover));
    final title = tester.getTopLeft(find.text('Duna'));
    await tester.tapAt(Offset((cover.right + title.dx) / 2, cover.center.dy));
    await tester.pump();

    expect(rowTaps, 1);
    expect(chipTaps, 0);
  });

  testWidgets('lays out when the width is not bounded', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Row(
            children: [
              BookListTile(
                title: 'Duna',
                author: 'Frank Herbert',
                genre: 'Ficção',
                status: ReadingStatusChipState.markAsRead,
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Duna'), findsOneWidget);
    expect(find.text('Marcar como lido'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Row(
            children: [
              BookListTile(
                title: 'Duna',
                author: 'Frank Herbert',
                genre: 'Ficção',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(AppReadingStatusChip), findsNothing);
  });

  testWidgets('dry layout matches the side by side and wrapped rows', (
    tester,
  ) async {
    const tile = BookListTile(
      title: 'Duna',
      author: 'Frank Herbert',
      genre: 'Ficção',
      status: ReadingStatusChipState.markAsRead,
    );

    Future<void> pumpIntrinsic(double width) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: const IntrinsicHeight(child: tile),
            ),
          ),
        ),
      );
    }

    await pumpIntrinsic(700);
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Marcar como lido')).dy,
      lessThan(tester.getBottomLeft(find.text('Frank Herbert')).dy),
    );
    expect(
      tester.getBottomLeft(find.byType(BookListTile)).dy,
      greaterThanOrEqualTo(
        tester.getBottomLeft(find.byType(AppReadingStatusChip)).dy,
      ),
    );

    final chipWidth = tester.getSize(find.byType(AppReadingStatusChip)).width;
    final inset =
        tester.getTopLeft(find.text('Frank Herbert')).dx -
        tester.getTopLeft(find.byType(BookListTile)).dx;
    await pumpIntrinsic(inset + chipWidth + 32);
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Marcar como lido')).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(find.text('Ficção')).dy),
    );
    expect(
      tester.getBottomLeft(find.byType(BookListTile)).dy,
      greaterThanOrEqualTo(
        tester.getBottomLeft(find.byType(AppReadingStatusChip)).dy,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SizedBox(
            width: 400,
            child: IntrinsicHeight(
              child: BookListTile(
                title: 'Duna',
                author: 'Frank Herbert',
                genre: 'Ficção',
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(find.byType(AppReadingStatusChip), findsNothing);
  });
}

bool _expectLabeledTap(SemanticsNode node) {
  final data = node.getSemanticsData();
  final isTappable =
      data.hasAction(SemanticsAction.tap) || data.flagsCollection.isButton;
  if (isTappable) {
    expect(data.label.trim(), isNotEmpty);
  }
  node.visitChildren(_expectLabeledTap);
  return true;
}
