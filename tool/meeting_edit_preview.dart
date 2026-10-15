import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_page.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  runApp(const MeetingEditPreviewApp());
}

class MeetingEditPreviewApp extends StatelessWidget {
  const MeetingEditPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MeetingEditPage(
        meeting: MeetingDetailsEntity(
          id: 'meeting-preview-1',
          number: 12,
          date: null,
          bookTitle: 'Torto Arado',
          hostName: 'Roberta Martins',
          locationName: 'Café Literário',
          locationAddress: 'Rua das Flores, 123',
          description: 'Discussão sobre a primeira metade do livro.',
        ),
      ),
    );
  }
}

