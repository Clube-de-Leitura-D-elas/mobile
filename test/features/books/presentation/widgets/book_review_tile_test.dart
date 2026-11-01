import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/presentation/widgets/book_review_tile.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';

Future<void> _pumpTile(WidgetTester tester, BookReviewTile tile) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: tile),
    ),
  );
}

void main() {
  testWidgets('shows the name, the comment and the small star rating', (
    tester,
  ) async {
    await _pumpTile(
      tester,
      const BookReviewTile(
        name: 'Roberta Fiore',
        rating: 4.5,
        comment: 'Um livro muito envolvente.',
      ),
    );

    expect(find.text('Roberta Fiore'), findsOneWidget);
    expect(find.text('Um livro muito envolvente.'), findsOneWidget);
    expect(find.bySemanticsLabel('4,5 de 5 estrelas'), findsOneWidget);

    final rating = tester.widget<AppStarRating>(find.byType(AppStarRating));
    expect(rating.size, AppStarRatingSize.sm);

    final avatar = tester.widget<AppParticipantAvatar>(
      find.byType(AppParticipantAvatar),
    );
    expect(avatar.diameter, BookReviewTile.avatarDiameter);
  });
}
