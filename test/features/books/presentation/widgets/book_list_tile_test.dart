import 'package:flutter/material.dart';
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
        status: ReadingStatusChipState.read,
      ),
    );

    expect(find.byType(AppBookCover), findsOneWidget);
    expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);
    expect(find.text('J. K. Rowling'), findsOneWidget);
    expect(find.text('Fantasia'), findsOneWidget);
    expect(find.text('Já lido'), findsOneWidget);
    expect(
      tester.widget<AppReadingStatusChip>(find.byType(AppReadingStatusChip)),
      isA<AppReadingStatusChip>().having(
        (chip) => chip.state,
        'state',
        ReadingStatusChipState.read,
      ),
    );
  });

  testWidgets('shows "Marcar como lido" as its own chip state', (
    tester,
  ) async {
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
}
