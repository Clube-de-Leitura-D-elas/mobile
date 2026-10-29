import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_photo_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_photos_state.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_photos/meeting_photo_viewer.dart';
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
          previous.failedPhotos != current.failedPhotos ||
          previous.canAddPhotos != current.canAddPhotos,
      builder: (context, state) => switch (state.status) {
        MeetingPhotosStatus.loading => const Center(
          key: ValueKey('meeting-photos-loading'),
          child: CircularProgressIndicator(),
        ),
        MeetingPhotosStatus.error => MeetingPhotosMessage(
          message: context.l10n.meetingPhotosLoadError,
          onRetry: context.read<MeetingPhotosCubit>().reload,
        ),
        MeetingPhotosStatus.loaded => _MeetingPhotosLoadedContent(state: state),
      },
    );
  }
}

class _MeetingPhotosLoadedContent extends StatelessWidget {
  const _MeetingPhotosLoadedContent({required this.state});

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
        if (state.photos.isEmpty && state.canAddPhotos)
          MeetingPhotosEmptyState(onTap: onAdd)
        else if (state.photos.isEmpty)
          Text(
            context.l10n.meetingPhotosEmpty,
            key: const ValueKey('meeting-photos-empty-read-only'),
            style: context.typography.bodySmall.copyWith(
              color: context.colors.textMuted,
            ),
          )
        else
          MeetingPhotosGrid(
            photos: state.photos,
            showAddTile:
                state.canAddPhotos &&
                state.photos.length < MeetingPhotoLimits.perMeeting,
            onAdd: onAdd,
            onReload: cubit.reload,
            onOpen: (index) => MeetingPhotoViewer.open(
              context,
              photo: state.photos[index],
              index: index,
              total: state.photos.length,
              onDelete: state.canAddPhotos && !state.isUploading
                  ? cubit.deletePhoto
                  : null,
            ),
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
