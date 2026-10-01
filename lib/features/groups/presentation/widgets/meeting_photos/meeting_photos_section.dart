import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_content.dart';
import 'package:mobile/l10n/app_localizations.dart';

class MeetingPhotosSection extends StatelessWidget {
  const MeetingPhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<MeetingPhotosCubit, MeetingPhotosState>(
      listenWhen: (previous, current) =>
          current.notice != null && previous.notice != current.notice,
      listener: (context, state) =>
          context.showAppToast(_noticeMessage(context.l10n, state.notice!)),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.meetingPhotosTitle,
              style: context.typography.bodyDefaultEmphasis.copyWith(
                color: colors.textDefault,
              ),
            ),
            SizedBox(height: context.spacing.s12),
            const MeetingPhotosContent(),
          ],
        ),
      ),
    );
  }

  String _noticeMessage(AppLocalizations l10n, MeetingPhotosNotice notice) {
    return switch (notice) {
      MeetingPhotosAccessDeniedNotice() => l10n.meetingPhotosAccessDenied,
      MeetingPhotosPickerFailedNotice() => l10n.meetingPhotosPickerFailed,
      MeetingPhotosSkippedNotice(:final count) => l10n.meetingPhotosSkipped(
        count,
      ),
      MeetingPhotosLimitReachedNotice() => l10n.meetingPhotosLimitReached(
        MeetingPhotoLimits.perMeeting,
      ),
      MeetingPhotosRejectedNotice(:final count) => l10n.meetingPhotosRejected(
        count,
      ),
    };
  }
}
