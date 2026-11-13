import 'package:material_ui/material_ui.dart';
import 'package:mobile/design_system/design_system.dart';

/// Situação da leitora no grupo: ponto colorido e texto curto.
class MembershipStatusIndicator extends StatelessWidget {
  final String label;
  final Color color;

  const MembershipStatusIndicator({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dotSize = context.spacing.s8;

    // Sem liveRegion: a troca de status vem sempre com um AppToast, que já é
    // anunciado.
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: context.spacing.s8),
          Expanded(
            child: Text(
              label,
              style: context.typography.bodySmallEmphasis.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
