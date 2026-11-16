import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/pending_raffle.dart';

/// Ação de sorteio inaugural ou pendente, com o mesmo texto na Home e na
/// tela do grupo.
class PendingRaffleButton extends StatelessWidget {
  final PendingRaffle pendingRaffle;
  final VoidCallback? onPressed;

  const PendingRaffleButton({
    super.key,
    required this.pendingRaffle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: pendingRaffle.isInaugural
          ? context.l10n.homePendingTasksRaffleInaugural
          : context.l10n.homePendingTasksRafflePending,
      onPressed: onPressed,
    );
  }
}
