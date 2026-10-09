import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

class ParticipantAvatarPlaceholder extends StatelessWidget {
  const ParticipantAvatarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.surfaceSunken,
      child: Icon(Icons.person_outline, color: colors.textMuted, size: 28),
    );
  }
}
