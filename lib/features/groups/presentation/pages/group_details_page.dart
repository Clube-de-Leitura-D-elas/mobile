import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/next_event_entity.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/next_event_state.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_content.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';

class GroupDetailsPage extends StatelessWidget {
  const GroupDetailsPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailsCubit, GroupDetailsState>(
      builder: (context, state) {
        return switch (state) {
          GroupDetailsLoading() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          GroupDetailsError(:final message) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(message)),
          ),
          GroupDetailsLoaded(:final group) => GroupDetailsScreen(
            name: context.l10n.groupDetailsNumberLabel(int.parse(group.name)),
            genres: group.genres,
            participantCount: group.participantCount,
            city: group.city,
            stateCode: group.stateCode,
            coverImage: group.coverImageUrl != null
                ? NetworkImage(group.coverImageUrl!)
                : null,
            nextEvent: BlocBuilder<NextEventCubit, NextEventState>(
              builder: (context, nextEventState) => GroupNextEvent(
                status: _toWidgetStatus(nextEventState),
                data: _toWidgetData(nextEventState),
                onEventHistoryPressed: () => context.push(
                  Uri(
                    path: GroupRoutePaths.eventHistory,
                    queryParameters: {'group_id': groupId},
                  ).toString(),
                ),
              ),
            ),
            participantsContent: const GroupParticipantsContent(),
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
    final DateTime? parsed = DateTime.tryParse(event.date);
    return GroupNextEventData(
      location: event.location,
      date: parsed ?? DateTime.now(),
      hostName: event.hostName,
    );
  }
}
