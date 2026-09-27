import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class GroupSection extends StatelessWidget {
  const GroupSection({
    super.key,
    required this.title,
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final int? count;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final text = context.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            key: ValueKey('section-$title'),
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.s8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: text.headingH3.copyWith(
                              color: colors.textDefault,
                            ),
                          ),
                        ),
                        if (count != null) ...[
                          SizedBox(width: spacing.s4),
                          Text(
                            '$count',
                            style: text.bodySmall.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: spacing.s8),
                  Icon(
                    key: ValueKey('section-chevron-$title'),
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.textDefault,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded && children.isNotEmpty) ...[
          SizedBox(height: spacing.s8),
          ...children,
        ],
      ],
    );
  }
}
