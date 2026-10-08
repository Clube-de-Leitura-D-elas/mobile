import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_screen.dart';
import 'package:mobile/l10n/app_localizations.dart';

Widget _wrap({
  required MeetingDetailsEntity meeting,
  ValueChanged<MeetingEditResult>? onSaved,
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
      body: MeetingEditScreen(meeting: meeting, onSaved: onSaved),
    ),
  );
}

void main() {
  const meeting = MeetingDetailsEntity(
    id: 'meeting-1',
    number: 12,
    bookTitle: 'Dom Casmurro',
    hostName: 'Beatriz Souza',
    locationName: 'Café Literário',
    locationAddress: 'Rua das Flores, 12',
    description: 'Discussão dos principais temas do livro.',
  );

  testWidgets('prefills editable and read-only meeting fields', (tester) async {
    await tester.pumpWidget(_wrap(meeting: meeting));

    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.text('Beatriz Souza'), findsOneWidget);
    expect(find.text('Café Literário - Rua das Flores, 12'), findsOneWidget);
    expect(
      find.text('Discussão dos principais temas do livro.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows validation errors and keeps form open when required fields are empty',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          meeting: const MeetingDetailsEntity(
            id: 'draft',
            bookTitle: 'Dom Casmurro',
            hostName: 'Beatriz Souza',
          ),
        ),
      );

      final saveButton = find.text('Salvar alterações');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Informe a data.'), findsOneWidget);
      expect(find.text('Informe o horário.'), findsOneWidget);
      expect(find.text('Informe o local.'), findsOneWidget);
      expect(find.byType(MeetingEditScreen), findsOneWidget);
    },
  );
}
