import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/groups/domain/entities/group_meeting.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mobile/features/home/presentation/widgets/home_groups_list.dart';
import 'package:mobile/features/home/presentation/widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  final UserEntity? user;
  final UserProfileEntity? profile;

  const HomeScreen({super.key, this.user, this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) => _HomeContent(state: state),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: QuickAccessItem.home.index,
        onItemSelected: (index) => context.goToQuickAccessTab(
          index,
          currentIndex: QuickAccessItem.home.index,
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeState state;

  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final l10n = context.l10n;
    final visibleGroups = state.filteredGroups(
      (group) => l10n.groupDetailsNumberLabel(group.number),
    );

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
      slivers: [
        SliverToBoxAdapter(
          child: HomeHeader(
            selectedFilterIndex: state.selectedFilterIndex,
            onFilterSelected: cubit.selectFilter,
            onSearchChanged: cubit.updateSearch,
            unansweredCount: state.unansweredCount,
          ),
        ),
        HomeGroupsList(
          groups: visibleGroups,
          emptyKind: state.emptyKindFor(visibleGroups),
          isLoading: state.status == HomeStatus.loading,
          errorMessage: state.status == HomeStatus.error
              ? state.errorMessage
              : null,
          isExpanded: state.isGroupExpanded,
          onToggleExpanded: cubit.toggleCardExpansion,
          onRetry: cubit.loadGroups,
          onConfirmPresence: (meetingId) => cubit.setMeetingPresence(
            meetingId,
            MeetingPresenceResponse.present,
          ),
          onDeclinePresence: (meetingId) => cubit.setMeetingPresence(
            meetingId,
            MeetingPresenceResponse.absent,
          ),
        ),
      ],
    );
  }
}
