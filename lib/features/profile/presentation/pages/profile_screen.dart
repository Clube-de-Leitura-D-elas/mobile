import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Permite fechar clicando fora
      builder: (BuildContext dialogContext) {
        return const LogoutConfirmDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(right: spacing.s16, top: spacing.s16),
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () => _showLogoutConfirmation(context),
          borderRadius: BorderRadius.circular(spacing.s8),
          child: Padding(
            padding: EdgeInsets.all(spacing.s8),
            child: AppIcon(
              icon: AppIcons.leave,
              size: spacing.s24,
              color: colors.textDefault,
            ),
          ),
        ),
      ),
    );
  }
}
