import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';
import 'package:mobile/features/profile/presentation/widgets/edit_profile_photo_dialog.dart';

/// Foto, nome e tempo no clube da leitora, no topo do perfil.
class ProfileHeader extends StatefulWidget {
  final String name;

  /// Entrada no clube. Sem ela, o tempo no clube não aparece.
  final DateTime? joinedAt;

  /// Relógio do cálculo do tempo no clube; os testes passam uma data fixa.
  final DateTime Function() now;

  /// Foto já conhecida. O get-user-profile ainda não devolve a URL.
  final String? photoUrl;

  const ProfileHeader({
    super.key,
    required this.name,
    this.joinedAt,
    this.now = DateTime.now,
    this.photoUrl,
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

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.photoUrl;
  }

  @override
  void didUpdateWidget(covariant ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photoUrl != oldWidget.photoUrl) {
      _photoUrl = widget.photoUrl;
    }
  }

  Future<void> _openEditPhoto() async {
    final updatedUrl = await showEditProfilePhotoDialog(
      context,
      initialPhotoUrl: _photoUrl,
    );
    if (!mounted || updatedUrl == null) return;
    setState(() => _photoUrl = updatedUrl);
  }

  String? _clubTime(BuildContext context) {
    final joinedAt = widget.joinedAt;
    if (joinedAt == null) {
      return null;
    }

    final l10n = context.l10n;
    // O created_at chega em UTC; a virada do mês é a do aparelho.
    final months = ProfileHeader.monthsBetween(
      joinedAt.toLocal(),
      widget.now().toLocal(),
    );

    return months < 12
        ? l10n.profileClubTimeMonths(months)
        : l10n.profileClubTimeYears(months ~/ 12);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final clubTime = _clubTime(context);

    return Row(
      children: [
        Semantics(
          label: l10n.profilePhotoEditButtonLabel,
          button: true,
          child: InkWell(
            onTap: _openEditPhoto,
            customBorder: const CircleBorder(),
            child: ExcludeSemantics(
              child: AppParticipantAvatar(
                photoUrl: _photoUrl,
                diameter: ProfileHeader.avatarDiameter,
              ),
            ),
          ),
        ),
        SizedBox(width: spacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
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
