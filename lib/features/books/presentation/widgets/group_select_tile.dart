import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';

/// Item do modal "Selecione o grupo".
///
/// Grupo que já recebeu o livro fica com a tag "já indicado", o nome
/// esmaecido, a foto em preto e branco escuro e sem resposta ao toque.
///
/// No Figma a foto desse estado já chega tratada. Aqui a URL vem colorida,
/// então a matriz dessatura e escurece.
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

  /// Altura mínima do toque na linha.
  static const double hitHeight = 48;

  /// Preto e branco escuro da foto de grupo já indicado (luminância × 0,7).
  static const List<double> alreadySuggestedPhotoMatrix = <double>[
    0.149,
    0.501,
    0.051,
    0,
    0,
    0.149,
    0.501,
    0.051,
    0,
    0,
    0.149,
    0.501,
    0.051,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  final String? photoUrl;
  final String name;
  final bool alreadySuggested;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final suggestedLabel = context.l10n.bookGroupAlreadySuggested;
    final canSelect = !alreadySuggested && onTap != null;
    final avatar = AppGroupAvatar(photoUrl: photoUrl, diameter: avatarDiameter);

    return Semantics(
      button: canSelect,
      enabled: canSelect,
      label: alreadySuggested ? '$name, $suggestedLabel' : name,
      onTap: canSelect ? onTap : null,
      child: InkWell(
        onTap: canSelect ? onTap : null,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: hitHeight),
            child: Row(
              children: [
                alreadySuggested
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.matrix(
                          alreadySuggestedPhotoMatrix,
                        ),
                        child: avatar,
                      )
                    : avatar,
                SizedBox(width: spacing.s16),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.headingH3.copyWith(
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
