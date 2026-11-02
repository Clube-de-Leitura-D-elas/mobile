import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';

/// Avaliação na tela de detalhes: avatar, nome, nota e comentário.
///
/// O avatar desta linha tem 24 px no Figma, menor que o das listas de
/// participantes. A nota é só leitura, no tamanho sm.
class BookReviewTile extends StatelessWidget {
  const BookReviewTile({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
    this.photoUrl,
  });

  static const double avatarDiameter = 24;

  final String? photoUrl;
  final String name;
  final double rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ExcludeSemantics(
              child: AppParticipantAvatar(
                photoUrl: photoUrl,
                diameter: avatarDiameter,
              ),
            ),
            SizedBox(width: spacing.s8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.bodyDefaultEmphasis.copyWith(
                  color: colors.textDefault,
                ),
              ),
            ),
            SizedBox(width: spacing.s8),
            AppStarRating.display(rating: rating, size: AppStarRatingSize.sm),
          ],
        ),
        if (comment.isNotEmpty) ...[
          SizedBox(height: spacing.s8),
          Text(
            comment,
            style: typography.bodySmall.copyWith(color: colors.textDefault),
          ),
        ],
      ],
    );
  }
}
