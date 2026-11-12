import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/rated_book.dart';
import 'package:mobile/features/books/presentation/widgets/rated_book_tile.dart';

void main() {
  const tBook = RatedBook(
    id: 'rated-1',
    bookId: 'book-1',
    title: 'Harry Potter e a Pedra Filosofal',
    author: 'J. K. Rowling',
    coverUrl: 'https://example.com/cover.jpg',
    rating: 4.5,
    comment: 'Livro fantástico, adorei a leitura.',
  );

  Widget buildWidget(RatedBook book, {VoidCallback? onTap}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: RatedBookTile(
          book: book,
          onTap: onTap,
        ),
      ),
    );
  }

  group('RatedBookTile', () {
    testWidgets('renders cover, title, author, star rating and comment', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget(tBook));

      expect(find.byType(AppBookCover), findsOneWidget);
      expect(find.text('Harry Potter e a Pedra Filosofal'), findsOneWidget);
      expect(find.text('J. K. Rowling'), findsOneWidget);
      expect(find.byType(AppStarRating), findsOneWidget);
      expect(find.text('Livro fantástico, adorei a leitura.'), findsOneWidget);

      final ratingWidget =
          tester.widget<AppStarRating>(find.byType(AppStarRating));
      expect(ratingWidget.size, AppStarRatingSize.sm);
      expect(ratingWidget.rating, 4.5);
    });

    testWidgets('hides comment when null or empty', (tester) async {
      const bookWithoutComment = RatedBook(
        id: 'rated-2',
        bookId: 'book-2',
        title: 'Orgulho e Preconceito',
        author: 'Jane Austen',
        rating: 5.0,
      );

      await tester.pumpWidget(buildWidget(bookWithoutComment));

      expect(find.text('Orgulho e Preconceito'), findsOneWidget);
      expect(find.text('Jane Austen'), findsOneWidget);
      expect(find.byType(AppStarRating), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2)); // Only title and author
    });

    testWidgets('tapping tile triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(tBook, onTap: () => tapped = true));

      await tester.tap(find.byType(RatedBookTile));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('has correct semantic label', (tester) async {
      await tester.pumpWidget(buildWidget(tBook, onTap: () {}));

      expect(
        find.bySemanticsLabel(
          'Harry Potter e a Pedra Filosofal, escrito por J. K. Rowling, avaliado com 4,5 de 5 estrelas, comentário: Livro fantástico, adorei a leitura.',
        ),
        findsOneWidget,
      );
    });
  });
}
