import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_promo_text_editor.dart';

/// Texto de divulgação do encontro, logo abaixo das fotos.
class MeetingPromoText extends StatelessWidget {
  const MeetingPromoText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingPhotosCubit, MeetingPhotosState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.promoText != current.promoText ||
          previous.canAddPhotos != current.canAddPhotos,
      builder: (context, state) {
        if (state.status != MeetingPhotosStatus.loaded) {
          return const SizedBox.shrink();
        }
        return _MeetingPromoTextContent(
          text: state.promoText,
          canEdit: state.canAddPhotos,
        );
      },
    );
  }
}

class _MeetingPromoTextContent extends StatelessWidget {
  const _MeetingPromoTextContent({required this.text, required this.canEdit});

  final String? text;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final current = text;

    return Column(
      key: const ValueKey('meeting-promo-text'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.meetingPromoTextTitle,
          style: context.typography.bodyDefaultEmphasis.copyWith(
            color: colors.textDefault,
          ),
        ),
        SizedBox(height: context.spacing.s8),
        if (current == null)
          Text(
            l10n.meetingPromoTextEmpty,
            key: const ValueKey('meeting-promo-text-empty'),
            style: context.typography.bodySmall.copyWith(
              color: colors.textMuted,
            ),
          )
        else
          SelectableText(
            current,
            key: const ValueKey('meeting-promo-text-value'),
            style: context.typography.bodyDefault.copyWith(
              color: colors.textDefault,
            ),
          ),
        SizedBox(height: context.spacing.s12),
        _MeetingPromoTextActions(text: current, canEdit: canEdit),
      ],
    );
  }
}

class _MeetingPromoTextActions extends StatelessWidget {
  const _MeetingPromoTextActions({required this.text, required this.canEdit});

  final String? text;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = text;
    if (current == null && !canEdit) return const SizedBox.shrink();

    return Wrap(
      spacing: context.spacing.s8,
      runSpacing: context.spacing.s8,
      children: [
        if (current != null)
          AppButton.secondary(
            key: const ValueKey('meeting-promo-text-copy'),
            label: l10n.meetingPromoTextCopy,
            icon: const Icon(Icons.copy_outlined, size: 18),
            size: AppButtonSize.sm,
            onPressed: () => _copy(context, current),
          ),
        if (canEdit)
          AppButton.secondary(
            key: const ValueKey('meeting-promo-text-edit'),
            label: current == null
                ? l10n.meetingPromoTextAdd
                : l10n.meetingPromoTextEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            size: AppButtonSize.sm,
            onPressed: () => MeetingPromoTextEditor.show(
              context,
              initialText: current ?? '',
              onSave: context.read<MeetingPhotosCubit>().savePromoText,
            ),
          ),
      ],
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      context.showAppToast(context.l10n.meetingPromoTextCopied);
    }
  }
}
