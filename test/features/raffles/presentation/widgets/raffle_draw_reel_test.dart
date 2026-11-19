import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';
import 'package:mobile/features/raffles/presentation/widgets/raffle_draw_reel.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  const participants = [
    RaffleParticipant(
      id: 'p1',
      name: 'Ana',
      hasAttended: true,
      bookTitle: 'Dom Casmurro',
    ),
    RaffleParticipant(
      id: 'p2',
      name: 'Bia',
      hasAttended: true,
      bookTitle: 'Torto Arado',
      bookCoverUrl: 'https://invalid.test/cover.png',
    ),
    RaffleParticipant(id: 'p3', name: 'Carla', hasAttended: true),
  ];

  Widget build({
    String? winnerId,
    required VoidCallback onRevealed,
    bool disableAnimations = false,
    double textScale = 1,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: RaffleDrawReel(
            participants: participants,
            winnerId: winnerId,
            onRevealed: onRevealed,
          ),
        ),
      ),
    );
  }

  testWidgets('keeps spinning while the server has not answered', (
    tester,
  ) async {
    var revealed = false;
    await tester.pumpWidget(build(onRevealed: () => revealed = true));

    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(revealed, isFalse);
    expect(find.text('Embaralhando as indicações…'), findsOneWidget);
  });

  testWidgets('lands on the server winner and then reveals', (tester) async {
    var revealed = 0;
    await tester.pumpWidget(build(onRevealed: () => revealed++));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.pumpWidget(
      build(winnerId: 'p2', onRevealed: () => revealed++),
    );

    var landed = false;
    for (var i = 0; i < 120 && !landed; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      landed = find.text('Temos um livro!').evaluate().isNotEmpty;
    }

    expect(landed, isTrue);
    expect(find.text('Torto Arado'), findsOneWidget);
    expect(find.text('indicado por Bia'), findsOneWidget);
    expect(revealed, 0);

    await tester.pump(const Duration(seconds: 2));
    expect(revealed, 1);
  });

  testWidgets('reveals at once when animations are disabled', (tester) async {
    var revealed = 0;
    await tester.pumpWidget(
      build(disableAnimations: true, onRevealed: () => revealed++),
    );
    await tester.pump();
    expect(revealed, 0);

    await tester.pumpWidget(
      build(
        winnerId: 'p3',
        disableAnimations: true,
        onRevealed: () => revealed++,
      ),
    );
    await tester.pump();

    expect(revealed, 1);
    expect(find.text('Carla'), findsOneWidget);
  });

  testWidgets('reveals without landing when the winner is not on the reel', (
    tester,
  ) async {
    var revealed = 0;
    await tester.pumpWidget(
      build(winnerId: 'someone-else', onRevealed: () => revealed++),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(revealed, 1);
  });

  testWidgets('hides who is on the reel while waiting without motion', (
    tester,
  ) async {
    await tester.pumpWidget(build(disableAnimations: true, onRevealed: () {}));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('indicado por'), findsNothing);
  });

  testWidgets(
    'reveals without motion even when the winner is not on the reel',
    (tester) async {
      var revealed = 0;
      await tester.pumpWidget(
        build(disableAnimations: true, onRevealed: () => revealed++),
      );
      await tester.pump();

      await tester.pumpWidget(
        build(
          winnerId: 'someone-else',
          disableAnimations: true,
          onRevealed: () => revealed++,
        ),
      );
      await tester.pump();

      expect(revealed, 1);
    },
  );

  testWidgets('does not overflow with large text on a short screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 330);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      build(winnerId: 'p2', textScale: 2, onRevealed: () {}),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a placeholder while a cover is still loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 120,
            height: 180,
            child: RaffleBookCover(url: 'https://invalid.test/slow.png'),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
  });

  testWidgets('fans out up to three covers before the draw', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: RaffleCoverFan(participants: participants)),
        ),
      ),
    );

    expect(find.byType(RaffleBookCover), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps swapping cards while the server has not answered', (
    tester,
  ) async {
    await tester.pumpWidget(build(onRevealed: () {}));
    await tester.pump();

    final seen = <String>{};
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 70));
      seen.addAll(
        tester
            .widgetList<Text>(find.textContaining('indicado por'))
            .map((text) => text.data!),
      );
    }

    expect(seen.length, greaterThan(1));
  });

  testWidgets('honours the iOS reduce motion setting', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    var revealed = 0;
    await tester.pumpWidget(build(onRevealed: () => revealed++));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      build(winnerId: 'p2', onRevealed: () => revealed++),
    );
    await tester.pump();

    expect(revealed, 1);
    expect(find.text('Torto Arado'), findsOneWidget);
  });
}
