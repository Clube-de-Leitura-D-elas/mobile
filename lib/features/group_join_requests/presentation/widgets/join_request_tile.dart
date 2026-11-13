import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/tools/sao_paulo_time.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/group_join_requests/domain/entities/group_join_request_entity.dart';
import 'package:mobile/features/group_join_requests/domain/entities/join_request_decision.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/participant_avatar.dart';

/// Um pedido de entrada: foto, nome, data e as ações de aceitar e recusar.
class JoinRequestTile extends StatelessWidget {
  final GroupJoinRequestEntity request;

  /// Decisão em andamento neste pedido.
  final JoinRequestDecision? reviewing;

  /// `false` enquanto outro pedido está sendo decidido.
  final bool enabled;

  final VoidCallback onApprove;
  final VoidCallback onReject;

  const JoinRequestTile({
    super.key,
    required this.request,
    required this.reviewing,
    required this.enabled,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final requestedAt = request.requestedAt;
    final requestedAtLabel = requestedAt == null
        ? null
        : l10n.groupJoinRequestsRequestedAt(
            toSaoPaulo(requestedAt),
            toSaoPaulo(requestedAt),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: [request.name, ?requestedAtLabel].join(', '),
          excludeSemantics: true,
          child: Row(
            children: [
              ParticipantAvatar(photoUrl: request.photoUrl),
              SizedBox(width: spacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      request.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodyDefaultEmphasis.copyWith(
                        color: colors.textDefault,
                      ),
                    ),
                    if (requestedAtLabel != null) ...[
                      SizedBox(height: spacing.s4),
                      Text(
                        requestedAtLabel,
                        style: typography.bodySmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.s12),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: l10n.groupJoinRequestsReject,
                size: AppButtonSize.lg,
                isLoading: reviewing == JoinRequestDecision.reject,
                onPressed: enabled ? onReject : null,
              ),
            ),
            SizedBox(width: spacing.s8),
            Expanded(
              child: AppButton.primary(
                label: l10n.groupJoinRequestsApprove,
                size: AppButtonSize.lg,
                isLoading: reviewing == JoinRequestDecision.approve,
                onPressed: enabled ? onApprove : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
