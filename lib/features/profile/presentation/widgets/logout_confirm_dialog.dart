import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importe para usar o context.read
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart'; // Ajuste o caminho se necessário

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;

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
                    'Sair da conta',
                    style: typography.headingH3.copyWith(
                      color: colors.textDefault,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(spacing.s8),
                  child: Icon(
                    Icons.close,
                    color: colors.textMuted,
                    size: spacing.s24,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.s16),
            Text(
              'Você deseja mesmo sair do aplicativo? Será necessário fazer login novamente para acessar sua conta.',
              style: typography.bodyDefault.copyWith(color: colors.textMuted),
            ),
            SizedBox(height: spacing.s32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton.ghost(
                  label: 'Cancelar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: spacing.s8),
                AppButton.primary(
                  label: 'Sair',
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
