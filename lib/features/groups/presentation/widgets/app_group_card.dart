import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/serviceLocator/service_locator.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/groups/domain/repository/group_repository.dart';
import 'package:mobile/features/groups/presentation/cubit/meeting_invitation_cubit.dart';
import 'package:mobile/features/groups/presentation/routes/group_routes.dart';
import 'package:mobile/features/groups/presentation/widgets/app_meeting_response_buttons.dart';
import 'package:mobile/features/groups/presentation/widgets/group_card/group_card_header.dart';
import 'package:mobile/features/groups/presentation/widgets/group_card/group_card_meeting_details_grid.dart';
import 'package:mobile/features/groups/presentation/widgets/group_card/group_card_meeting_header_row.dart';
import 'package:mobile/features/groups/presentation/widgets/group_card/group_card_my_tasks_button.dart';

class AppGroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String? photoUrl;
  final int participantsCount;
  final String cityState;
  final GroupMeeting? nextMeeting;
  final bool expanded;
  final VoidCallback? onTap;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onMeetingResponseSuccess;
  final VoidCallback? onMyTasksPressed;

  /// Chamado ao voltar de "Suas tarefas", para atualizar o contador.
  final VoidCallback? onTasksClosed;

  /// Mostra só o botão "Minhas tarefas" no lugar do próximo evento.
  final bool tasksOnly;

  const AppGroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.participantsCount,
    required this.cityState,
    this.photoUrl,
    this.nextMeeting,
    this.expanded = true,
    this.onTap,
    this.onToggleExpanded,
    this.onMeetingResponseSuccess,
    this.onMyTasksPressed,
    this.onTasksClosed,
    this.tasksOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final meeting = nextMeeting;

    return AppCard(
      showBorder: false,
      onTap:
          onTap ??
          () => context.push(
            Uri(
              path: GroupRoutes.groupDetails,
              queryParameters: {'group_id': groupId},
            ).toString(),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GroupCardHeader(
            photoUrl: photoUrl,
            groupName: groupName,
            participantsCount: participantsCount,
            cityState: cityState,
          ),
          if (tasksOnly) ...[
            if (meeting != null && meeting.canManageTasks) ...[
              SizedBox(height: spacing.s16),
              GroupCardMyTasksButton(
                meeting: meeting,
                onPressed: onMyTasksPressed,
                onClosed: onTasksClosed,
              ),
            ],
          ] else if (meeting != null && !meeting.isEnded) ...[
            SizedBox(height: spacing.s16),
            GroupCardMeetingHeaderRow(
              expanded: expanded,
              onToggleExpanded: onToggleExpanded,
            ),
            if (expanded) ...[
              SizedBox(height: spacing.s8),
              GroupCardMeetingDetailsGrid(meeting: meeting),
              SizedBox(height: spacing.s16),
              if (meeting.id != null && !meeting.canManageTasks)
                BlocProvider(
                  create: (context) => MeetingInvitationCubit(
                    groupRepository: serviceLocator<GroupRepository>(),
                    meetingId: meeting.id!,
                    initialStatus: meeting.invitationStatus,
                  ),
                  child: AppMeetingResponseButtons(
                    onResponseSuccess: onMeetingResponseSuccess,
                  ),
                ),
              if (meeting.canManageTasks)
                GroupCardMyTasksButton(
                  meeting: meeting,
                  onPressed: onMyTasksPressed,
                  onClosed: onTasksClosed,
                ),
            ],
          ],
        ],
      ),
    );
  }
}
