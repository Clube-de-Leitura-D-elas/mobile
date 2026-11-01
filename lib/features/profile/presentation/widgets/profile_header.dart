import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';

/// Foto, nome e tempo no clube da leitora, no topo do perfil.
class ProfileHeader extends StatelessWidget {
  final String name;

  /// Entrada no clube. Sem ela, o tempo no clube não aparece.
  final DateTime? joinedAt;

  /// Relógio do cálculo do tempo no clube; os testes passam uma data fixa.
  final DateTime Function() now;

  const ProfileHeader({
    super.key,
    required this.name,
    this.joinedAt,
    this.now = DateTime.now,
  });

  static const double avatarDiameter = 96;

  /// Meses completos entre [from] e [to], nunca negativo.
  static int monthsBetween(DateTime from, DateTime to) {
    var months = (to.year - from.year) * 12 + to.month - from.month;
    // Último dia do mês fecha o mês: de 31/01 a 28/02 já é 1 mês.
    final lastDayOfMonth = DateTime(to.year, to.month + 1, 0).day;
    if (to.day < from.day && to.day < lastDayOfMonth) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  String? _clubTime(BuildContext context) {
    final joinedAt = this.joinedAt;
    if (joinedAt == null) {
      return null;
    }

    final l10n = context.l10n;
    // O created_at chega em UTC; a virada do mês é a do aparelho.
    final months = monthsBetween(joinedAt.toLocal(), now().toLocal());

    return months < 12
        ? l10n.profileClubTimeMonths(months)
        : l10n.profileClubTimeYears(months ~/ 12);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final clubTime = _clubTime(context);

    return Row(
      children: [
        // O get-user-profile ainda não devolve a URL da foto; fica o avatar
        // padrão. O nome ao lado já identifica a leitora para o leitor de tela.
        const ExcludeSemantics(
          child: AppParticipantAvatar(photoUrl: null, diameter: avatarDiameter),
        ),
        SizedBox(width: spacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: typography.headingH3.copyWith(color: colors.textDefault),
              ),
              if (clubTime != null) ...[
                SizedBox(height: spacing.s4),
                Text(
                  clubTime,
                  style: typography.bodyDefault.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
