import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Splash screen displaying app logo and loading indicator while checking session.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final logoLabel = l10n?.appLogoSemanticLabel ?? 'Logo do aplicativo';

    return Scaffold(
      backgroundColor: colors.bgDefault,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: logoLabel,
              child: Image.asset(
                'assets/images/logo.png',
                width: 160.0,
                fit: BoxFit.contain,
              ),
            ),
            const Gap24(),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.actionPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

