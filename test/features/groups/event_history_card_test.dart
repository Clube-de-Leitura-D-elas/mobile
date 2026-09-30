import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

const _meeting = GroupMeeting(
  bookTitle: 'Quarto de Despejo',
  hostName: 'Ana Souza',
  date: '22/08/2026',
  location: 'Biblioteca Municipal',
);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('pt', 'BR'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('renders the completed event details', (tester) async {
    await tester.pumpWidget(_wrap(const EventHistoryCard(meeting: _meeting)));

    expect(find.text('Quarto de Despejo'), findsOneWidget);
    expect(find.text('Anfitriã: Ana Souza'), findsOneWidget);
    expect(find.text('22/08/2026'), findsOneWidget);
    expect(find.text('Confira mais detalhes'), findsOneWidget);
  });

  testWidgets('calls the details callback when it is provided', (tester) async {
    var detailsOpened = false;
    await tester.pumpWidget(
      _wrap(
        EventHistoryCard(
          meeting: _meeting,
          onDetailsPressed: () => detailsOpened = true,
        ),
      ),
    );

    await tester.tap(find.text('Confira mais detalhes'));

    expect(detailsOpened, isTrue);
  });

  testWidgets('keeps the details link enabled without a destination', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const EventHistoryCard(meeting: _meeting)));

    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Confira mais detalhes',
      ),
    );
    expect(semantics.properties.enabled, isTrue);
  });

  testWidgets('shows a placeholder when the book cover is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const EventHistoryCard(meeting: _meeting)));

    expect(find.byType(AppIcon), findsOneWidget);
  });

  testWidgets('formats an ISO meeting date for display', (tester) async {
    // 12:00 UTC nunca vira o dia ao converter para qualquer fuso das Américas.
    const meeting = GroupMeeting(
      bookTitle: 'Quarto de Despejo',
      hostName: 'Ana Souza',
      date: '2026-08-22T12:00:00Z',
      location: 'Biblioteca Municipal',
    );
    await tester.pumpWidget(_wrap(const EventHistoryCard(meeting: meeting)));

    expect(find.text('22/08/2026'), findsOneWidget);
  });

  testWidgets('limits long book titles and host names', (tester) async {
    const bookTitle =
        'Um título de livro muito longo que não deve ultrapassar o espaço disponível no card';
    const hostName =
        'Uma anfitriã com um nome muito longo que não deve quebrar o layout';
    await tester.pumpWidget(
      _wrap(
        const EventHistoryCard(
          meeting: GroupMeeting(
            bookTitle: bookTitle,
            hostName: hostName,
            date: '22/08/2026',
            location: 'Biblioteca Municipal',
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text(bookTitle));
    final host = tester.widget<Text>(find.text('Anfitriã: $hostName'));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(host.maxLines, 1);
    expect(host.overflow, TextOverflow.ellipsis);
  });
}
