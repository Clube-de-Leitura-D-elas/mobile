import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';

enum QuickAccessItem { home, search, plus, calendar, profile }

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

  static const String _iconsBasePath = 'assets/si';

  static const List<_QuickAccessIconData> _icons = [
    _QuickAccessIconData(name: 'home', label: 'Início'),
    _QuickAccessIconData(name: 'search', label: 'Busca'),
    _QuickAccessIconData(name: 'plus', label: 'Adicionar'),
    _QuickAccessIconData(name: 'calendar', label: 'Calendário'),
    _QuickAccessIconData(name: 'profile', label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final assetBundle = DefaultAssetBundle.of(context);

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
              final state = isSelected ? 'active' : 'inactive';
              final assetPath =
                  '$_iconsBasePath/type=${iconData.name}_$state.si';

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: iconData.label,
                  child: InkWell(
                    onTap: () => onItemSelected(index),
                    child: SizedBox.expand(
                      child: Center(
                        child: SizedBox(
                          width: spacing.s24,
                          height: spacing.s24,
                          child: ScalableImageWidget.fromSISource(
                            si: ScalableImageSource.fromSI(
                              assetBundle,
                              assetPath,
                            ),
                            currentColor: iconColor,
                          ),
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
  const _QuickAccessIconData({required this.name, required this.label});

  final String name;
  final String label;
}
