import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_reviewed_books.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const books = [
    ProfileReviewedBookEntity(
      bookId: 'b-1',
      title: 'Harry Potter e a Pedra Filosofal',
      coverUrl: 'https://example.com/capa.jpg',
      rating: 5,
    ),
    ProfileReviewedBookEntity(
      bookId: 'b-2',
      title: 'Harry Potter e a Câmara Secreta',
      rating: 4,
    ),
  ];

  Future<void> pumpBooks(
    WidgetTester tester, {
    ValueChanged<String>? onBookTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: ProfileReviewedBooks(
            books: books,
            onBookTap: onBookTap ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('mostra a capa e o título de cada livro', (tester) async {
    await pumpBooks(tester);

    expect(find.byType(AppBookCover), findsNWidgets(2));
    expect(
      tester.widget<AppBookCover>(find.byType(AppBookCover).first).imageUrl,
      'https://example.com/capa.jpg',
    );
    expect(find.text('Harry Potter e a Câmara Secreta'), findsOneWidget);
  });

  testWidgets('cada livro é um botão com o título e abre o livro', (
    tester,
  ) async {
    final opened = <String>[];
    await pumpBooks(tester, onBookTap: opened.add);

    expect(
      tester.getSemantics(
        find.bySemanticsLabel('Harry Potter e a Pedra Filosofal'),
      ),
      isSemantics(label: 'Harry Potter e a Pedra Filosofal', isButton: true),
    );

    await tester.tap(find.text('Harry Potter e a Câmara Secreta'));
    expect(opened, ['b-2']);
  });
}
