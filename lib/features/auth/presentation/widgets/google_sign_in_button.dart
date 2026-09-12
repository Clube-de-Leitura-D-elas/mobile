import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

/// Button component for Google OAuth authentication.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.text;
    final l10n = context.l10n;
    final borderRadius = BorderRadius.circular(999.0);

    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: colors.bgDefault,
        borderRadius: borderRadius,
        border: Border.all(color: colors.borderDefault, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.textDefault),
                    ),
                  )
                else ...[
                  SvgPicture.asset(
                    'assets/icons/google_icon.svg',
                    width: 14.0,
                    height: 14.0,
                  ),
                  const Gap12(),
                  Text(
                    l10n.signInWithGoogle,
                    style: typography.labelButton.copyWith(
                      color: colors.textDefault,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
