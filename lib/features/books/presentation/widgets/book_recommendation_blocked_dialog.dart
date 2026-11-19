import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

/// Modal informativo quando uma leitora já sorteada/anfitriã no rodízio
/// tenta indicar um livro naquele grupo.
class BookRecommendationBlockedDialog extends StatelessWidget {
  const BookRecommendationBlockedDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const BookRecommendationBlockedDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);

    return AppDialog(
      title: l10n.bookRecommendationHostBlockedTitle,
      onClose: navigator.pop,
      actions: [
        AppButton.primary(
          label: l10n.bookRecommendationHostBlockedAction,
          size: AppButtonSize.lg,
          onPressed: navigator.pop,
        ),
      ],
      child: Text(
        l10n.bookRecommendationHostBlocked,
        style: context.typography.bodyDefault.copyWith(
          color: context.colors.textMuted,
        ),
      ),
    );
  }
}
