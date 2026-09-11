import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/design_system/widgets/app_toast.dart';

void main() {
  runApp(const ToastTestApp());
}

class ToastTestApp extends StatelessWidget {
  const ToastTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Design System do projeto
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

      home: const ToastTestPage(),
    );
  }
}

class ToastTestPage extends StatelessWidget {
  const ToastTestPage({super.key});

  void _showSuccess(BuildContext context) {
    AppToast.show(
      context,
      message: context.l10n.confirm,
      type: AppToastType.success,
    );
  }

  void _showError(BuildContext context) {
    AppToast.show(
      context,
      message: 'Não foi possível salvar. Tente de novo.',
      type: AppToastType.error,
    );
  }

  void _showWarning(BuildContext context) {
    AppToast.show(
      context,
      message: 'O encontro ainda está sem local.',
      type: AppToastType.warning,
    );
  }

  void _showInfo(BuildContext context) {
    AppToast.show(
      context,
      message: 'As participantes foram avisadas.',
      type: AppToastType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _showSuccess(context),
              child: const Text('Sucesso'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showError(context),
              child: const Text('Erro'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showWarning(context),
              child: const Text('Alerta'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showInfo(context),
              child: const Text('Informação'),
            ),
          ],
        ),
      ),
    );
  }
}