import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.load();
  DependenciesContainer();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
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
      home: Column(
        children: [
          Text(
            'Hello, World!',
            style: context.text.display.copyWith(
              color: context.colors.actionDanger,
            ),
          ),
        ],
      ),
    );
  }
}
