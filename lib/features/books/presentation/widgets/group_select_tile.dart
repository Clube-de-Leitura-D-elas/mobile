import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Item do modal "Selecione o grupo".
///
/// Grupo que já recebeu o livro fica com a tag "já indicado", o nome
/// esmaecido e sem resposta ao toque.
class GroupSelectTile extends StatelessWidget {
  const GroupSelectTile({
    super.key,
    required this.name,
    this.photoUrl,
    this.alreadySuggested = false,
    this.onTap,
  });

  /// Diâmetro do avatar nesta linha, como no quadro do modal.
  static const double avatarDiameter = 48;

  final String? photoUrl;
  final String name;
  final bool alreadySuggested;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final suggestedLabel = l10n?.bookGroupAlreadySuggested ?? 'já indicado';
    final canSelect = !alreadySuggested && onTap != null;

    return Semantics(
      button: canSelect,
      enabled: canSelect,
      label: alreadySuggested ? '$name, $suggestedLabel' : name,
      onTap: canSelect ? onTap : null,
      child: InkWell(
        onTap: canSelect ? onTap : null,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                AppGroupAvatar(photoUrl: photoUrl, diameter: avatarDiameter),
                SizedBox(width: spacing.s16),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: alreadySuggested
                          ? colors.textMuted
                          : colors.textDefault,
                    ),
                  ),
                ),
                if (alreadySuggested) ...[
                  SizedBox(width: spacing.s8),
                  AppTag(label: suggestedLabel, variant: TagVariant.neutral),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
