import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class GroupActions extends StatelessWidget {
  const GroupActions({
    super.key,
    this.whatsappUrl,
    this.onOpenWhatsApp,
  });

  final String? whatsappUrl;
  final Future<bool> Function(Uri url)? onOpenWhatsApp;

  bool get _hasWhatsAppUrl =>
      whatsappUrl != null && whatsappUrl!.trim().isNotEmpty;

  Future<void> _handleWhatsAppTap(BuildContext context) async {
    if (!_hasWhatsAppUrl) return;

    final uri = Uri.tryParse(whatsappUrl!.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      _showErrorSnackBar(context);
      return;
    }

    try {
      final launchFn = onOpenWhatsApp ??
          (url) => launcher.launchUrl(
                url,
                mode: launcher.LaunchMode.externalApplication,
              );
      final success = await launchFn(uri);
      if (!success && context.mounted) {
        _showErrorSnackBar(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.whatsappLaunchError),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttons = [
          AppButton.secondary(
            label: l10n.groupOpenWhatsAppButton,
            size: AppButtonSize.sm,
            onPressed:
                _hasWhatsAppUrl ? () => _handleWhatsAppTap(context) : null,
          ),
          AppButton.primary(
            label: l10n.groupRecommendBookButton,
            size: AppButtonSize.sm,
            onPressed: () {},
          ),
        ];

        if (constraints.maxWidth < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buttons.first,
              SizedBox(height: spacing.s8),
              buttons.last,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: buttons.first),
            SizedBox(width: spacing.s8),
            Expanded(child: buttons.last),
          ],
        );
      },
    );
  }
}
