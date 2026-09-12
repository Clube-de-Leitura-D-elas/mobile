import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

/// Splash screen displaying app logo while checking authentication session.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 160.0,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
