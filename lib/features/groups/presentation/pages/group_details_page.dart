import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/features/groups/presentation/routes/group_route_paths.dart';

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
            name: group.name,
            genres: group.genres,
            participantCount: group.participantCount,
            city: group.city,
            stateCode: group.stateCode,
            coverImage: group.coverImageUrl != null
                ? NetworkImage(group.coverImageUrl!)
                : null,
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
}
