import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/core/media/photo_picker.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_participant_avatar.dart';
import 'package:mobile/features/profile/domain/repository/profile_repository.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_photo_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_photo_state.dart';
import 'package:mobile/l10n/app_localizations.dart';

Future<String?> showEditProfilePhotoDialog(
  BuildContext context, {
  String? initialPhotoUrl,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BlocProvider(
        create: (_) => EditProfilePhotoCubit(
          profileRepository: serviceLocator<ProfileRepository>(),
          photoPicker: serviceLocator<PhotoPicker>(),
          initialPhotoUrl: initialPhotoUrl,
        ),
        child: EditProfilePhotoDialog(initialPhotoUrl: initialPhotoUrl),
      );
    },
  );
}

class EditProfilePhotoDialog extends StatelessWidget {
  const EditProfilePhotoDialog({super.key, this.initialPhotoUrl});

  final String? initialPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final previewSize = spacing.s64 + spacing.s48;

    return BlocConsumer<EditProfilePhotoCubit, EditProfilePhotoState>(
      listenWhen: (previous, current) {
        if (current.notice != null && previous.notice != current.notice) {
          return true;
        }
        return previous.status != EditProfilePhotoStatus.success &&
            current.status == EditProfilePhotoStatus.success;
      },
      listener: (context, state) {
        final notice = state.notice;
        if (notice != null) {
          context.showErrorToast(_noticeMessage(l10n, notice));
          return;
        }
        Navigator.of(context).pop(state.photoUrl);
      },
      builder: (context, state) {
        final cubit = context.read<EditProfilePhotoCubit>();

        return PopScope(
          canPop: !state.isUploading,
          child: AppDialog(
            title: l10n.editProfilePhotoDialogTitle,
            onClose: state.isUploading ? () {} : null,
            actions: [
              AppButton.primary(
                label: l10n.editProfilePhotoChangeButton,
                isLoading: state.isUploading,
                onPressed: state.isUploading ? null : cubit.pickAndUpload,
              ),
            ],
            child: Center(
              child: Semantics(
                image: state.photoUrl != null && state.photoUrl!.isNotEmpty,
                label: l10n.profilePhotoPreviewSemanticLabel,
                child: AppParticipantAvatar(
                  photoUrl: state.photoUrl ?? initialPhotoUrl,
                  diameter: previewSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _noticeMessage(AppLocalizations l10n, EditProfilePhotoNotice notice) {
    return switch (notice) {
      EditProfilePhotoUploadFailedNotice() => l10n.editProfilePhotoUploadFailed,
      EditProfilePhotoRejectedNotice() => l10n.editProfilePhotoRejected,
      EditProfilePhotoTooLargeNotice() => l10n.editProfilePhotoTooLarge,
      EditProfilePhotoPickerDeniedNotice() => l10n.meetingPhotosAccessDenied,
      EditProfilePhotoPickerFailedNotice() => l10n.meetingPhotosPickerFailed,
      EditProfilePhotoInvalidFormatNotice() => l10n.meetingPhotosSkipped(1),
    };
  }
}
