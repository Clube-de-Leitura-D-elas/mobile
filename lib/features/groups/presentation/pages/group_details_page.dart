import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_state.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/groups/presentation/widgets/group_next_event.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_content.dart';
import 'package:mobile/features/home/presentation/routes/home_routes.dart';

class GroupDetailsPage extends StatelessWidget {
  const GroupDetailsPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        return switch (state) {
          GroupDetailsLoading() => Scaffold(
            appBar: ScreenHeader.back(
              title: context.l10n.groupDetailsHeader,
              onBackPressed: () => context.canPop()
                  ? context.pop()
                  : context.go(HomeRoutes.home),
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          GroupDetailsError(:final message) => Scaffold(
            appBar: ScreenHeader.back(
              title: context.l10n.groupDetailsHeader,
              onBackPressed: () => context.canPop()
                  ? context.pop()
                  : context.go(HomeRoutes.home),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.s24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: context.text.bodyDefault.copyWith(
                        color: context.colors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacing.s16),
                    AppButton(
                      label: context.l10n.groupDetailsRetryButton,
                      onPressed: () =>
                          context.read<GroupDetailsCubit>().load(groupId),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GroupDetailsLoaded(:final group) => GroupDetailsScreen(
            name: 'Grupo ${group.name}',
            genres: group.genres,
            participantCount: group.participantCount,
            city: group.city,
            stateCode: group.stateCode,
            coverImage: group.coverImageUrl != null
                ? NetworkImage(group.coverImageUrl!)
                : null,
            whatsappUrl: group.whatsappUrl,
            nextEvent: BlocBuilder<NextEventCubit, NextEventState>(
              builder: (context, nextEventState) {
                final meetingId = nextEventState is NextEventLoaded
                    ? nextEventState.event.id
                    : null;
                return GroupNextEvent(
                  status: _toWidgetStatus(nextEventState),
                  data: _toWidgetData(nextEventState),
                  onMoreDetailsPressed: meetingId == null
                      ? null
                      : () async {
                          await context.push(
                            Uri(
                              path: GroupRoutePaths.meetingDetails,
                              queryParameters: {'meeting_id': meetingId},
                            ).toString(),
                          );
                          if (context.mounted) {
                            await context.read<NextEventCubit>().load(groupId);
                          }
                        },
                );
              },
            ),
            participantsContent: const GroupParticipantsContent(),
            onEventHistoryPressed: () => context.push(
              Uri(
                path: GroupRoutePaths.eventHistory,
                queryParameters: {'group_id': groupId},
              ).toString(),
            ),
          ),
        };
      },
    );
  }

  GroupNextEventStatus _toWidgetStatus(NextEventState state) {
    return switch (state) {
      NextEventLoading() => GroupNextEventStatus.loading,
      NextEventEmpty() => GroupNextEventStatus.empty,
      NextEventLoaded() => GroupNextEventStatus.loaded,
      NextEventError() => GroupNextEventStatus.error,
    };
  }

  GroupNextEventData? _toWidgetData(NextEventState state) {
    if (state is! NextEventLoaded) return null;
    final NextEventEntity event = state.event;
    final coverUrl = event.bookCoverUrl;
    return GroupNextEventData(
      location: event.location,
      date: event.date,
      hostName: event.hostName,
      bookTitle: event.bookTitle,
      bookCover: coverUrl == null || coverUrl.isEmpty
          ? null
          : NetworkImage(coverUrl),
    );
  }
}
