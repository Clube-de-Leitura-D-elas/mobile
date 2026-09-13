// Preview ISOLADO do AppDropdown — sem Cubit, sem feature: o componente
// em si já é "burro" (recebe items/value, executa onChanged), então essa
// tela é só um harness de visualização com setState local, não faz parte
// da árvore de features do app.
//
// Todas as strings vêm de context.l10n (AppLocalizations), igual uma
// tela real faria — nada hardcoded aqui além dos textos que descrevem
// cada variante de demonstração.
//
// Rodar com: flutter run -t lib/dropdown_preview_main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() => runApp(const DropdownPreviewApp());

class DropdownPreviewApp extends StatelessWidget {
  const DropdownPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppDropdown - Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('pt', 'BR'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _DropdownPreviewPage(),
    );
  }
}

class _DropdownPreviewPage extends StatefulWidget {
  const _DropdownPreviewPage();

  @override
  State<_DropdownPreviewPage> createState() => _DropdownPreviewPageState();
}

class _DropdownPreviewPageState extends State<_DropdownPreviewPage> {
  String? _genero;
  String? _generoComItem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final generos = [
      l10n.genreRomance,
      l10n.genreFantasy,
      l10n.genreSuspense,
      l10n.genreNonFiction,
    ];

    _generoComItem ??= l10n.genreRomance;

    return Scaffold(
      appBar: AppBar(title: const Text('AppDropdown - Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDropdown<String>(
              label: l10n.genreFieldLabel,
              hintText: l10n.genreFieldHint,
              items: generos,
              value: _genero,
              onChanged: (value) => setState(() => _genero = value),
            ),
            const SizedBox(height: 24.0),
            AppDropdown<String>(
              label: l10n.genreFieldLabel,
              hintText: l10n.genreFieldHint,
              items: generos,
              value: _generoComItem,
              onChanged: (value) => setState(() => _generoComItem = value),
            ),
            const SizedBox(height: 24.0),
            AppDropdown<String>(
              label: l10n.genreFieldLabel,
              hintText: l10n.genreFieldHint,
              items: generos,
              value: l10n.genreRomance,
              enabled: false,
              onChanged: (_) {},
            ),
            const SizedBox(height: 24.0),
            AppDropdown<String>(
              label: l10n.genreFieldLabel,
              hintText: l10n.genreFieldHint,
              size: AppDropdownSize.lg,
              items: generos,
              value: _generoComItem,
              onChanged: (value) => setState(() => _generoComItem = value),
            ),
          ],
        ),
      ),
    );
  }
}
