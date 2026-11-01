import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/widgets/book_list_tile.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<void> _pumpTile(WidgetTester tester, BookListTile tile) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
            localizationsDelegates: AppLocalizations.localizationsDelegates,
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
