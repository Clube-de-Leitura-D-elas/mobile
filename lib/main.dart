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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
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
  String? selectedValue = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('proximo encontro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDropdown<String>(
              label: 'Status',
              items: const [
                'Todos',
                'Ativos',
                'Inativos',
              ],
              value: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
            const SizedBox(height: 32),
            AppDropdown<String>(
              label: 'Desabilitado',
              items: const [
                'Opção 1',
                'Opção 2',
              ],
              value: 'Opção 1',
              enabled: false,
              onChanged: (_) {},
            ),
            const SizedBox(height: 32),
            Text(
              'Selecionado: ${selectedValue ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }
}