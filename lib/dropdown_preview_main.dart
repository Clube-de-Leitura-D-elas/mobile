// Preview ISOLADO do AppDropdown — sem Cubit, sem feature: o componente
// em si já é "burro" (recebe items/value, executa onChanged), então essa
// tela é só um harness de visualização com setState local, não faz parte
// da árvore de features do app.
//
// Rodar com: flutter run -t lib/dropdown_preview_main.dart
import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

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
  String? _generoComItem = 'Romance';

  static const _generos = ['Romance', 'Fantasia', 'Suspense', 'Não-ficção'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppDropdown - Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDropdown<String>(
              label: 'Gênero (vazio)',
              hintText: 'Selecione um gênero',
              items: _generos,
              value: _genero,
              onChanged: (value) => setState(() => _genero = value),
            ),
            const SizedBox(height: 24.0),
            AppDropdown<String>(
              label: 'Gênero (com item selecionado)',
              hintText: 'Selecione um gênero',
              items: _generos,
              value: _generoComItem,
              onChanged: (value) => setState(() => _generoComItem = value),
            ),
            const SizedBox(height: 24.0),
            AppDropdown<String>(
              label: 'Gênero (desabilitado)',
              hintText: 'Selecione um gênero',
              items: _generos,
              value: 'Romance',
              enabled: false,
              onChanged: (_) {},
            ),
            const SizedBox(height: 24.0),
            AppDropdown<String>(
              label: 'Gênero (tamanho Lg)',
              hintText: 'Selecione um gênero',
              size: AppDropdownSize.lg,
              items: _generos,
              value: _generoComItem,
              onChanged: (value) => setState(() => _generoComItem = value),
            ),
          ],
        ),
      ),
    );
  }
}
