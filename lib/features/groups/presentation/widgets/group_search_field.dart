import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupSearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const GroupSearchField({
    super.key,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.bgDefault,
        borderRadius: BorderRadius.circular(98),
        border: Border.all(color: colors.borderDefault),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: Row(
        children: [
          AppIcon(icon: AppIcons.search, size: 18, color: colors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: _SearchInputField(
              controller: controller,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInputField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const _SearchInputField({
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: typography.bodyDefault.copyWith(color: colors.textDefault),
      decoration: InputDecoration(
        isDense: true,
        hintText: l10n.searchGroupPlaceholder,
        hintStyle: typography.bodyDefault.copyWith(
          color: colors.actionDisabledFg,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
