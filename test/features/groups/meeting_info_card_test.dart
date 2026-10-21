import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_info_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

const _meeting = MeetingDetailsEntity(
  id: 'meeting-1',
  bookTitle: 'Dom Casmurro',
  hostName: 'Beatriz Souza',
  locationName: 'Café Literário',
  locationAddress: 'Rua das Flores, 12',
  locationGooglePlaceId: 'place-1',
);

const _locationLabel = 'Local: Café Literário - Rua das Flores, 12';

Widget _wrap(
  MeetingDetailsEntity meeting, {
  Future<bool> Function(Uri url)? onOpenMap,
}) {
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
    home: Scaffold(
      body: MeetingInfoCard(
        meeting: meeting,
        title: 'Encontro 12',
        onOpenMap: onOpenMap,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'given a location, when the card is shown, then the location looks like a link',
    (tester) async {
      await tester.pumpWidget(_wrap(_meeting, onOpenMap: (_) async => true));

      final text = tester.widget<Text>(find.text(_locationLabel));
      final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
      expect(spans[0].text, 'Local: ');
      expect(spans[0].style?.decoration, isNull);
      expect(spans[1].text, 'Café Literário - Rua das Flores, 12');
      expect(spans[1].style?.decoration, TextDecoration.underline);
      expect(find.byKey(const ValueKey('meeting-info-link')), findsOneWidget);
    },
  );

  testWidgets(
    'given a Google place, when tapping the location, then opens that place in Google Maps',
    (tester) async {
      Uri? opened;
      await tester.pumpWidget(
        _wrap(
          _meeting,
          onOpenMap: (url) async {
            opened = url;
            return true;
          },
        ),
      );

      await tester.tap(find.text(_locationLabel));
      await tester.pump();

      expect(
        opened,
        Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': 'Café Literário, Rua das Flores, 12',
          'query_place_id': 'place-1',
        }),
      );
    },
  );

  testWidgets(
    'given the map cannot be opened, when tapping the location, then shows an error',
    (tester) async {
      await tester.pumpWidget(_wrap(_meeting, onOpenMap: (_) async => false));

      await tester.tap(find.text(_locationLabel));
      await tester.pump();

      expect(find.text('Não foi possível abrir o mapa.'), findsOneWidget);

      // Deixa o toast terminar antes de encerrar o teste.
      await tester.pump(const Duration(seconds: 4));
    },
  );

  testWidgets(
    'given no location, when the card is shown, then there is no link',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MeetingDetailsEntity(
            id: 'draft',
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
          ),
        ),
      );

      expect(find.text('Local: a definir'), findsOneWidget);
      expect(find.byKey(const ValueKey('meeting-info-link')), findsNothing);
    },
  );
}
