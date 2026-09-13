import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:mobile/core/environment/environment.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
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

Future<void> mainAsync() async {
  final widgetsBinding = kDebugMode
      ? MarionetteBinding.ensureInitialized()
      : WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  DependenciesContainer();
  FlutterNativeSplash.remove();
  runApp(const MainApp());
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
