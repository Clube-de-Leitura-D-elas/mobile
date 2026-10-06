import 'package:flutter/material.dart';
import 'package:mobile/design_system/icons/app_icons.dart';
import 'package:mobile/design_system/widgets/app_icon.dart';

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

  static const List<_QuickAccessIconData> _icons = [
    _QuickAccessIconData(icon: AppIcons.home, label: 'Início'),
    _QuickAccessIconData(icon: AppIcons.search, label: 'Busca'),
    _QuickAccessIconData(icon: AppIcons.plus, label: 'Adicionar'),
    _QuickAccessIconData(icon: AppIcons.calendar, label: 'Calendário'),
    _QuickAccessIconData(icon: AppIcons.user, label: 'Perfil'),
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
                        child: SizedBox(
                          width: spacing.s24,
                          height: spacing.s24,
                          child: AppIcon(
                            icon: iconData.icon,
                            size: spacing.s24,
                            color: iconColor,
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
  const _QuickAccessIconData({required this.icon, required this.label});

  final AppIconAsset icon;
  final String label;
}
