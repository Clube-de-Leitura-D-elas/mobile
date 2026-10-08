import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_card.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  runApp(const AppGroupCardPreviewApp());
}

class AppGroupCardPreviewApp extends StatelessWidget {
  const AppGroupCardPreviewApp({super.key});

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
      home: const AppGroupCardPreviewPage(),
    );
  }
}

class AppGroupCardPreviewPage extends StatelessWidget {
  const AppGroupCardPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(title: const Text('AppGroupCard')),
      body: ListView(
        padding: EdgeInsets.all(spacing.s16),
        children: [
          AppGroupCard(
            groupId: 'clube-central',
            groupName: 'Clube de Leitura Central',
            participantsCount: 18,
            cityState: 'Porto Alegre, RS',
            nextMeeting: const GroupMeeting(
              hostName: 'Roberta Martins',
              bookTitle: 'A vida invisível de Eurídice Gusmão',
              date: '29/08/2026',
              location: 'Café TecnoPUC',
            ),
            onTap: () => _showFeedback(context, 'Abrindo detalhes do grupo'),
          ),
          SizedBox(height: spacing.s16),
          const AppGroupCard(
            groupId: 'leitoras-zona-sul',
            groupName: 'Leitoras da Zona Sul',
            participantsCount: 12,
            cityState: 'Porto Alegre, RS',
            nextMeeting: GroupMeeting(
              hostName: 'Mariana Costa',
              bookTitle: 'Torto arado',
              date: '12/09/2026',
              location: 'Biblioteca Pública',
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
