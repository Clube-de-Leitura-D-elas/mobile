import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/marionette/app_marionette_configuration.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/dependencies.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await mainAsync();
}

/// Em debug, o binding do Marionette (automação via Marionette MCP) com os
/// widgets do material_ui; em release, o binding padrão.
WidgetsBinding ensureAppBinding({
  bool isDebug = kDebugMode,
  WidgetsBinding Function(MarionetteConfiguration) initMarionette =
      MarionetteBinding.ensureInitialized,
  WidgetsBinding Function() initDefault =
      WidgetsFlutterBinding.ensureInitialized,
}) {
  return isDebug ? initMarionette(appMarionetteConfiguration) : initDefault();
}

Future<void> mainAsync({
  WidgetsBinding Function() ensureBinding = ensureAppBinding,
}) async {
  final widgetsBinding = ensureBinding();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    final environment = Environment.instance;
    await environment.load();

    if (environment.hasSupabaseConfig) {
      await Supabase.initialize(
        url: environment.supabaseUrl,
        publishableKey: environment.supabaseAnonKey,
      );
    } else {
      debugPrint(
        'Supabase não configurado. Defina SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY no .env.',
      );
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    DependenciesContainer();
    runApp(const MainApp());
  } catch (error, stackTrace) {
    debugPrint('Erro durante a inicialização do app: $error\n$stackTrace');
    runApp(const StartupErrorApp());
  } finally {
    FlutterNativeSplash.remove();
  }
}

/// Tela de quando o app não consegue iniciar. Não oferece "Tentar novamente":
/// Supabase e o service locator não aceitam ser inicializados duas vezes.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt', 'BR'),
      home: Builder(
        builder: (context) => Scaffold(
          body: AppErrorState(message: context.l10n.appStartupError),
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>(
      create: (_) => serviceLocator<SessionCubit>(),
      child: Builder(
        builder: (context) {
          final sessionCubit = context.read<SessionCubit>();
          final router = AppRoutes.createRouter(sessionCubit);

          return MaterialApp.router(
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
            routerConfig: router,
          );
        },
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';

import 'dropdown_showcase.dart'; // Import da tela criada

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DropdownShowcaseScreen(),
    ),
  );
}
*/
