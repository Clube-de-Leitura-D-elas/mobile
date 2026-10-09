import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_state.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_screen.dart';

class MeetingDetailsPage extends StatelessWidget {
  const MeetingDetailsPage({
    super.key,
    this.canEdit = false,
    // TODO: receber permissão calculada pela integração (coordenadora ou anfitriã).
  });

  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingDetailsCubit, MeetingDetailsState>(
      builder: (context, state) => switch (state) {
        MeetingDetailsLoading() => Scaffold(
          appBar: ScreenHeader.back(title: context.l10n.meetingDetailsHeader),
          body: const Center(child: CircularProgressIndicator()),
        ),
        MeetingDetailsError(:final message) => Scaffold(
          appBar: ScreenHeader.back(title: context.l10n.meetingDetailsHeader),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(context.spacing.s24),
              child: Text(
                message,
                style: context.typography.bodyDefault.copyWith(
                  color: context.colors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        MeetingDetailsLoaded(:final meeting) => MeetingDetailsScreen(
          meeting: meeting,
          canEdit: canEdit,
        ),
      },
    );
  }
}
