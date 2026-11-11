import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/books/domain/entities/book_review_entity.dart';
import 'package:mobile/features/books/presentation/widgets/book_review_dialog.dart';
import 'package:mobile/l10n/app_localizations.dart';

typedef _Call = ({int rating, String? commentary});

void main() {
  late List<_Call> calls;
  late Future<bool> Function() answer;

  setUp(() {
    calls = [];
    answer = () async => true;
  });

  Future<bool> onSubmit({required int rating, String? commentary}) {
    calls.add((rating: rating, commentary: commentary));
    return answer();
  }

  Future<void> openDialog(
    WidgetTester tester, {
    MyBookReviewEntity? initialReview,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt', 'BR'),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showBookReviewDialog(
                context,
                onSubmit: onSubmit,
                initialReview: initialReview,
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  // O modal tem um só AppButton; enquanto salva, o texto vira um indicador.
  AppButton saveButton(WidgetTester tester) => tester.widget<AppButton>(
    find.descendant(
      of: find.byType(BookReviewDialog),
      matching: find.byType(AppButton),
    ),
  );

  Future<void> rate(WidgetTester tester, int stars) async {
    final star = find.descendant(
      of: find.byType(AppStarRating),
      matching: find.byType(GestureDetector),
    );
    await tester.tap(star.at(stars - 1));
    await tester.pump();
  }

  testWidgets('needs a rating before saving', (tester) async {
    await openDialog(tester);

    expect(find.text('Avaliar livro'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    await rate(tester, 4);

    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('saves rating and trimmed commentary, then closes', (
    tester,
  ) async {
    await openDialog(tester);
    await rate(tester, 4);
    await tester.enterText(find.byType(TextField), '  Gostei muito  ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(calls, [(rating: 4, commentary: 'Gostei muito')]);
    expect(find.byType(BookReviewDialog), findsNothing);
  });

  testWidgets('sends no commentary when the field is blank', (tester) async {
    await openDialog(tester);
    await rate(tester, 2);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(calls, [(rating: 2, commentary: null)]);
  });

  testWidgets('stays open with an error when saving fails', (tester) async {
    answer = () async => false;
    await openDialog(tester);
    await rate(tester, 3);
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(BookReviewDialog), findsOneWidget);
    expect(find.text('Não foi possível salvar sua avaliação.'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('blocks saving twice while the request is running', (
    tester,
  ) async {
    final pending = Completer<bool>();
    answer = () => pending.future;
    await openDialog(tester);
    await rate(tester, 5);
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(saveButton(tester).onPressed, isNull);
    expect(saveButton(tester).isLoading, isTrue);

    pending.complete(true);
    await tester.pumpAndSettle();
    expect(calls, hasLength(1));
  });

  testWidgets('rejects a commentary above the limit', (tester) async {
    await openDialog(tester);
    await rate(tester, 5);
    await tester.enterText(
      find.byType(TextField),
      'a' * (BookReviewDialog.maxCommentaryLength + 1),
    );
    await tester.pump();

    expect(
      find.text('O comentário pode ter até 1000 caracteres.'),
      findsOneWidget,
    );
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('opens filled for editing an existing review', (tester) async {
    await openDialog(
      tester,
      initialReview: MyBookReviewEntity(
        rating: 3,
        commentary: 'Bom',
        evaluatedAt: DateTime.utc(2026, 11, 1),
      ),
    );

    expect(find.text('Editar avaliação'), findsOneWidget);
    expect(find.text('Bom'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(calls, [(rating: 3, commentary: 'Bom')]);
  });
}
