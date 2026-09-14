import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';

enum QuickAccessItem { home, search, add, calendar, profile }

class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : assert(
         currentIndex >= 0 && currentIndex < QuickAccessItem.values.length,
       );

  final int currentIndex;

  final ValueChanged<int> onItemSelected;

  static const List<_QuickAccessIconData> _icons = [
    _QuickAccessIconData(
      outlined: Icons.home_outlined,
      filled: Icons.home,
      label: 'Início',
    ),
    _QuickAccessIconData(
      outlined: Icons.search,
      filled: Icons.search,
      label: 'Busca',
    ),
    _QuickAccessIconData(
      outlined: Icons.add,
      filled: Icons.add,
      label: 'Adicionar',
    ),
    _QuickAccessIconData(
      outlined: Icons.calendar_today_outlined,
      filled: Icons.calendar_today,
      label: 'Calendário',
    ),
    _QuickAccessIconData(
      outlined: Icons.person_outline,
      filled: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Material(
      color: colors.surfaceDefault,
      child: SafeArea(
        top: false,
        child: Container(
          height: spacing.s64,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.borderDefault, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_icons.length, (index) {
              final isSelected = index == currentIndex;
              final iconData = _icons[index];
              final iconColor = isSelected
                  ? colors.actionPrimary
                  : colors.textMuted;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: iconData.label,
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    child: SizedBox.expand(
                      child: Center(
                        child: Icon(
                          isSelected ? iconData.filled : iconData.outlined,
                          color: iconColor,
                          size: spacing.s24,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessIconData {
  const _QuickAccessIconData({
    required this.outlined,
    required this.filled,
    required this.label,
  });

  final IconData outlined;
  final IconData filled;
  final String label;
}

class QuickAccessExampleApp extends StatelessWidget {
  const QuickAccessExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Clube de Leitura D'Elas — exemplo",
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: const [AppColorTokens.light, AppSpacingTokens.standard],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: const [AppColorTokens.dark, AppSpacingTokens.standard],
      ),
      themeMode: ThemeMode.system,
      home: const _QuickAccessExampleScreen(),
    );
  }
}

class _QuickAccessExampleScreen extends StatefulWidget {
  const _QuickAccessExampleScreen();

  @override
  State<_QuickAccessExampleScreen> createState() =>
      _QuickAccessExampleScreenState();
}

class _QuickAccessExampleScreenState extends State<_QuickAccessExampleScreen> {
  int _currentIndex = 0;

  static const List<String> _sectionNames = [
    'Início',
    'Busca',
    'Adicionar',
    'Calendário',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      appBar: AppBar(
        title: const Text("Clube de Leitura D'Elas — exemplo"),
        backgroundColor: colors.surfaceDefault,
        foregroundColor: colors.textDefault,
      ),
      body: ListView.builder(
        itemCount: 40,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            'Item de conteúdo $index',
            style: TextStyle(color: colors.textDefault),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _currentIndex,
        onItemSelected: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.actionPrimary,
        foregroundColor: colors.textOnBrand,
        onPressed: () {},
        label: Text('Seção atual: ${_sectionNames[_currentIndex]}'),
      ),
    );
  }
}
