import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/group_details_state.dart';
import 'package:mobile/features/groups/presentation/pages/group_details_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/participants/group_participants_content.dart';

class GroupDetailsPage extends StatelessWidget {
  const GroupDetailsPage({super.key});

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
            participantsContent: const GroupParticipantsContent(),
          ),
        };
      },
    );
  }
}
