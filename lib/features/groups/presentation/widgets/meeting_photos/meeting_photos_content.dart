import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_empty_state.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_grid.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_message.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photos_upload_progress.dart';

class MeetingPhotosContent extends StatelessWidget {
  const MeetingPhotosContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingPhotosCubit, MeetingPhotosState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.photos != current.photos ||
          previous.progress != current.progress ||
          previous.failedPhotos != current.failedPhotos,
      builder: (context, state) => switch (state.status) {
        MeetingPhotosStatus.loading => const Center(
          key: ValueKey('meeting-photos-loading'),
          child: CircularProgressIndicator(),
        ),
        MeetingPhotosStatus.error => MeetingPhotosMessage(
          message: context.l10n.meetingPhotosLoadError,
          onRetry: context.read<MeetingPhotosCubit>().reload,
        ),
        MeetingPhotosStatus.loaded => MeetingPhotosLoadedContent(state: state),
      },
    );
  }
}

class MeetingPhotosLoadedContent extends StatelessWidget {
  const MeetingPhotosLoadedContent({super.key, required this.state});

  final MeetingPhotosState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MeetingPhotosCubit>();
    final onAdd = state.isUploading ? null : cubit.pickAndUpload;
    final progress = state.progress;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.photos.isEmpty)
          MeetingPhotosEmptyState(onTap: onAdd)
        else
          MeetingPhotosGrid(
            photos: state.photos,
            showAddTile: state.photos.length < MeetingPhotoLimits.perMeeting,
            onAdd: onAdd,
            onReload: cubit.reload,
          ),
        if (progress != null) ...[
          SizedBox(height: spacing.s16),
          MeetingPhotosUploadProgressView(progress: progress),
        ],
        if (!state.isUploading && state.failedPhotos.isNotEmpty) ...[
          SizedBox(height: spacing.s16),
          MeetingPhotosMessage(
            message: context.l10n.meetingPhotosUploadFailed(
              state.failedPhotos.length,
            ),
            onRetry: cubit.retryFailed,
          ),
        ],
      ],
    );
  }
}
