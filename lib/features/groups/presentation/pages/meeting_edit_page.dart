import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_edit_state.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_screen.dart';

class MeetingEditPage extends StatelessWidget {
  const MeetingEditPage({super.key, required this.meeting});

  final MeetingDetailsEntity meeting;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MeetingEditCubit, MeetingEditState>(
      listener: (context, state) {
        switch (state) {
          case MeetingEditSuccess():
            Navigator.of(context).pop(true);
          case MeetingEditError(:final message):
            context.showErrorToast(message);
          case MeetingEditIdle() || MeetingEditSubmitting():
            break;
        }
      },
      builder: (context, state) => Scaffold(
        appBar: ScreenHeader.back(title: context.l10n.meetingEditTitle),
        body: MeetingEditScreen(
          meeting: meeting,
          isSaving: state is MeetingEditSubmitting,
          onSaved: (result) => context.read<MeetingEditCubit>().submit(
            meetingId: meeting.id,
            date: result.date,
            googlePlaceId: result.googlePlaceId,
            description: result.description,
          ),
        ),
      ),
    );
  }
}
