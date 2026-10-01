import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/domain/entities/user_entity.dart';
import 'package:mobile/features/auth/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
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
        currentIndex: 0,
        onItemSelected: (_) {},
      ),
      floatingActionButton: IntrinsicWidth(
        child: AppButton.secondary(
          label: context.l10n.logoutTooltip,
          onPressed: () => context.read<SessionCubit>().logOut(),
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
          groups: state.groups,
          isLoading: state.status == HomeStatus.loading,
          errorMessage: state.status == HomeStatus.error
              ? state.errorMessage
              : null,
          isExpanded: state.isGroupExpanded,
          onToggleExpanded: cubit.toggleCardExpansion,
          onRetry: cubit.loadGroups,
        ),
      ],
    );
  }
}
