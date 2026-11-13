import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_details_state.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_details_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/group_error_state.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/cubit/meeting_guest_requests_cubit.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/routes/meeting_guest_requests_route_paths.dart';
import 'package:mobile/features/meeting_guest_requests/presentation/widgets/guest_requests_access_button.dart';

class MeetingDetailsPage extends StatelessWidget {
  const MeetingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingDetailsCubit, MeetingDetailsState>(
      builder: (context, state) => switch (state) {
        MeetingDetailsLoading() => Scaffold(
          appBar: ScreenHeader.back(title: context.l10n.meetingDetailsHeader),
          body: const Center(child: CircularProgressIndicator()),
        ),
        MeetingDetailsError(:final failure) => Scaffold(
          appBar: ScreenHeader.back(title: context.l10n.meetingDetailsHeader),
          body: GroupErrorState(
            failure: failure,
            onRetry: () {
              context.read<MeetingDetailsCubit>().retry();
              context.read<MeetingGuestRequestsCubit>().retry();
            },
          ),
        ),
        MeetingDetailsLoaded(:final meeting) => MeetingDetailsScreen(
          meeting: meeting,
          canEdit: meeting.canEdit,
          guestRequestsAccess: GuestRequestsAccessButton(
            onPressed: () async {
              await context.push(
                MeetingGuestRequestsRoutePaths.guestRequestsFor(meeting.id),
              );
              if (!context.mounted) return;
              await context.read<MeetingGuestRequestsCubit>().refresh();
            },
          ),
        ),
      },
    );
  }
}
