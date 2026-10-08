import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';

class MeetingPhotosUploadProgressView extends StatelessWidget {
  const MeetingPhotosUploadProgressView({super.key, required this.progress});

  final MeetingPhotosUploadProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      key: const ValueKey('meeting-photos-upload-progress'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.meetingPhotosUploading(progress.current, progress.total),
          style: context.typography.bodySmall.copyWith(color: colors.textMuted),
        ),
        SizedBox(height: context.spacing.s8),
        LinearProgressIndicator(
          value: (progress.current - 1) / progress.total,
          color: colors.actionPrimary,
          backgroundColor: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}
