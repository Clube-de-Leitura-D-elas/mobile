import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/home/presentation/widgets/home_pending_tasks_banner.dart';

class HomeHeader extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;

  /// Ação exibida à direita do título.
  final Widget? titleAction;

  /// Exibe o aviso de tarefas pendentes quando não nulo.
  final VoidCallback? onPendingTasksPressed;

  const HomeHeader({
    super.key,
    this.onSearchChanged,
    this.searchController,
    this.titleAction,
    this.onPendingTasksPressed,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final onPendingTasksPressed = this.onPendingTasksPressed;

    return Padding(
      padding: EdgeInsets.fromLTRB(spacing.s16, spacing.s16, spacing.s16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: _HomeTitle()),
              ?titleAction,
            ],
          ),
          SizedBox(height: spacing.s16),
          AppSearchField(
            hintText: context.l10n.searchGroupPlaceholder,
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          if (onPendingTasksPressed != null) ...[
            SizedBox(height: spacing.s16),
            HomePendingTasksBanner(onPressed: onPendingTasksPressed),
          ],
        ],
      ),
    );
  }
}

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = context.l10n;

    return Text(
      l10n.myGroupsTitle,
      style: typography.headingH2.copyWith(color: colors.textDefault),
    );
  }
}
