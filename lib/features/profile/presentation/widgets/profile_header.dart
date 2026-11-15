import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';
import 'package:mobile/features/profile/presentation/widgets/edit_profile_photo_dialog.dart';

/// Foto, nome, livros lidos e grupos da leitora, no topo do perfil.
class ProfileHeader extends StatefulWidget {
  final String name;

  /// Contadores do resumo do perfil. Enquanto não carregam, não aparecem.
  final int? booksReadCount;
  final int? groupsCount;

  /// Foto atual do perfil.
  final String? photoUrl;

  /// Avisa quem guarda o perfil, para a foto nova não se perder ao recriar a
  /// tela na troca de aba.
  final ValueChanged<String>? onPhotoChanged;

  const ProfileHeader({
    super.key,
    required this.name,
    this.booksReadCount,
    this.groupsCount,
    this.photoUrl,
    this.onPhotoChanged,
  });

  static const double avatarDiameter = 96;

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
    widget.onPhotoChanged?.call(updatedUrl);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final booksReadCount = widget.booksReadCount;
    final groupsCount = widget.groupsCount;

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
              if (booksReadCount != null) ...[
                SizedBox(height: spacing.s4),
                _ProfileStat(
                  icon: AppIcons.book,
                  text: l10n.profileBooksReadCount(booksReadCount),
                ),
              ],
              if (groupsCount != null) ...[
                SizedBox(height: spacing.s4),
                _ProfileStat(
                  icon: AppIcons.group,
                  text: l10n.profileGroupsCount(groupsCount),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.icon, required this.text});

  final AppIconAsset icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      children: [
        ExcludeSemantics(
          child: AppIcon(
            icon: icon,
            size: spacing.s16,
            color: colors.textMuted,
          ),
        ),
        SizedBox(width: spacing.s8),
        Flexible(
          child: Text(
            text,
            style: context.typography.bodySmall.copyWith(
              color: colors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
