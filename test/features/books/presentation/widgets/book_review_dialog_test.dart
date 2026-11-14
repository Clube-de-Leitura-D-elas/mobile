import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/tools/result.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_details_entity.dart';
import 'package:mobile/features/books/domain/entities/book_failure.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/domain/repository/book_repository.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_cubit.dart';
import 'package:mobile/features/books/presentation/cubit/book_details_state.dart';
import 'package:mobile/features/books/presentation/widgets/book_review_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockBookRepository extends Mock implements BookRepository {}

BookDetailsEntity _details() => const BookDetailsEntity(
  id: 'b1',
  title: 'Livro',
  author: 'Autora',
  genre: '',
  publisher: '',
  ratingsCount: 0,
);

void main() {
  late MockBookRepository repository;

  setUp(() {
    repository = MockBookRepository();
  });

  Future<void> pumpDialog(
    WidgetTester tester, {
    MyBookReviewEntity? review,
  }) async {
    final cubit = BookDetailsCubit(repository: repository)
      ..emit(
        BookDetailsState(status: BookDetailsStatus.loaded, details: _details()),
      );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: BlocProvider.value(
          value: cubit,
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => BookReviewDialog.show(context, review: review),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders disabled submit and the visual star requirements', (
    tester,
  ) async {
    await pumpDialog(tester);

    final dialogRatingFinder = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(AppStarRating),
    );
    expect(find.text('Sua nota'), findsOneWidget);
    expect(find.text('Adicione seu comentário (opcional)'), findsOneWidget);
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Concluir'))
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<AppStarRating>(dialogRatingFinder).emptyColor,
      AppColorTokens.light.textMuted,
    );
    expect(
      tester.getCenter(dialogRatingFinder).dx,
      closeTo(tester.getCenter(find.byType(Dialog)).dx, 0.1),
    );
  });

  testWidgets('pre-fills rating and commentary when editing', (tester) async {
    await pumpDialog(
      tester,
      review: MyBookReviewEntity(
        rating: 4,
        commentary: 'Comentário anterior',
        evaluatedAt: DateTime.utc(2026, 11, 14),
      ),
    );

    expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(1));
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Comentário anterior',
    );
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Concluir'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('limits the commentary to 1000 characters', (tester) async {
    await pumpDialog(tester);

    final text = 'a' * 1001;
    await tester.enterText(find.byType(TextField), text);

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text.length,
      1000,
    );
  });

  testWidgets('stays open and stops loading when saving fails', (tester) async {
    when(
      () => repository.upsertBookReview(
        bookId: 'b1',
        rating: 3,
        commentary: null,
      ),
    ).thenAnswer((_) async => const Failure(BookReviewFailure()));

    await pumpDialog(tester);
    await tester.tap(find.bySemanticsLabel('3 de 5 estrelas'));
    await tester.pump();
    await tester.tap(find.widgetWithText(AppButton, 'Concluir'));
    await tester.pumpAndSettle();

    expect(find.byType(BookReviewDialog), findsOneWidget);
    expect(
      tester
          .widget<AppButton>(find.widgetWithText(AppButton, 'Concluir'))
          .onPressed,
      isNotNull,
    );
    verify(
      () => repository.upsertBookReview(
        bookId: 'b1',
        rating: 3,
        commentary: null,
      ),
    ).called(1);
  });
}
