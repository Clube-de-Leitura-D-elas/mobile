import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: colors.surfaceDefault,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.logoutDialogTitle,
                    style: typography.headingH3.copyWith(
                      color: colors.textDefault,
                    ),
                  ),
                ),
                Tooltip(
                  message: l10n.close,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(spacing.s8),
                    child: Icon(
                      Icons.close,
                      color: colors.textMuted,
                      size: spacing.s24,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.s16),
            Text(
              l10n.logoutDialogMessage,
              style: typography.bodyDefault.copyWith(color: colors.textMuted),
            ),
            SizedBox(height: spacing.s32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton.ghost(
                  label: l10n.logoutDialogCancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: spacing.s8),
                AppButton.primary(
                  label: l10n.logoutDialogConfirm,
                  onPressed: () {
                    context.read<SessionCubit>().logOut();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
