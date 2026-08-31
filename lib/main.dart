import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await mainAsync();
}

Future<void> mainAsync() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.load();

  if (Environment.hasSupabaseConfig) {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      publishableKey: Environment.supabaseAnonKey,
    );
  } else {
    debugPrint(
      'Supabase não configurado. Defina SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY no .env.',
    );
  }

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.appTitle,
          style: text.headingH3.copyWith(color: colors.textBrand),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.welcomeMessage,
                style: text.display.copyWith(color: colors.textDefault),
                textAlign: TextAlign.center,
              ),
              const Gap12(),
              Text(
                'Design system initialized',
                style: text.bodyDefaultEmphasis.copyWith(
                  color: colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap24(),
              AppButton.primary(label: 'Confirmar', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
