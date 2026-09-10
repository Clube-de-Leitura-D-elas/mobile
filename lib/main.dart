import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/theme/app_theme.dart';
import 'package:mobile/design_system/widgets/app_dropdown.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() {
  runApp(const DropdownTestApp());
}

class DropdownTestApp extends StatelessWidget {
  const DropdownTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Design System
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Localização
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),

      home: const DropdownTestScreen(),
    );
  }
}

class DropdownTestScreen extends StatefulWidget {
  const DropdownTestScreen({super.key});

  @override
  State<DropdownTestScreen> createState() => _DropdownTestScreenState();
}

class _DropdownTestScreenState extends State<DropdownTestScreen> {
  String? selectedGenre;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final genreEntries = [
      DropdownMenuEntry<String>(
        value: l10n.genreRomance,
        label: l10n.genreRomance,
      ),
      DropdownMenuEntry<String>(
        value: l10n.genreFantasy,
        label: l10n.genreFantasy,
      ),
      DropdownMenuEntry<String>(
        value: l10n.genreSuspense,
        label: l10n.genreSuspense,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.nextMeeting,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teste do Dropdown',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 24),

            AppDropdown<String>(
              label: 'Gênero',
              initialSelection: selectedGenre,
              items: genreEntries,
              onSelected: (value) {
                setState(() {
                  selectedGenre = value;
                });
              },
            ),

            const SizedBox(height: 32),

            AppDropdown<String>(
              label: 'Desabilitado',
              initialSelection: l10n.genreRomance,
              items: genreEntries,
              enabled: false,
              onSelected: (_) {},
            ),

            const SizedBox(height: 32),

            Text(
              'Selecionado: ${selectedGenre ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }
}