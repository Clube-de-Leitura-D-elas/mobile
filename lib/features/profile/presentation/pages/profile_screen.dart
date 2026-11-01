import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/profile/presentation/widgets/logout_confirm_dialog.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_header.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfileEntity? profile;

  const ProfileScreen({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final name = profile?.name ?? '';

    return ListView(
      padding: EdgeInsets.all(spacing.s16),
      children: [
        const _ProfileTitleRow(),
        SizedBox(height: spacing.s16),
        ProfileHeader(
          name: name.isEmpty ? l10n.defaultUserName : name,
          joinedAt: profile?.createdAt,
        ),
      ],
    );
  }
}

class _ProfileTitleRow extends StatelessWidget {
  const _ProfileTitleRow();

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return const LogoutConfirmDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.profileTitle,
              style: typography.headingH2.copyWith(color: colors.textDefault),
            ),
          ),
        ),
        Semantics(
          label: l10n.profileLogoutButtonLabel,
          button: true,
          child: InkWell(
            onTap: () => _showLogoutConfirmation(context),
            borderRadius: BorderRadius.circular(spacing.s8),
            // 12 + 24 + 12: alvo de toque de 48.
            child: Padding(
              padding: EdgeInsets.all(spacing.s12),
              child: AppIcon(
                icon: AppIcons.leave,
                size: spacing.s24,
                color: colors.textDefault,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
