import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:mobile/features/home/presentation/cubit/home_state.dart';
import 'package:mobile/features/home/presentation/widgets/home_groups_list.dart';

/// Lista os grupos em que a anfitriã tem tarefas pendentes.
class PendingTasksScreen extends StatelessWidget {
  const PendingTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      appBar: ScreenHeader.back(title: context.l10n.pendingTasksTitle),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => _PendingTasksContent(state: state),
      ),
    );
  }
}

class _PendingTasksContent extends StatelessWidget {
  final HomeState state;

  const _PendingTasksContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final groups = state.pendingTasksGroups;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
      slivers: [
        HomeGroupsList(
          groups: groups,
          emptyKind: groups.isEmpty ? HomeEmptyKind.noPendingTasks : null,
          isLoading:
              state.status == HomeStatus.initial ||
              state.status == HomeStatus.loading,
          errorMessage: state.status == HomeStatus.error
              ? state.errorMessage
              : null,
          isExpanded: state.isGroupExpanded,
          onToggleExpanded: cubit.toggleCardExpansion,
          onRetry: cubit.loadGroups,
          onMeetingResponseSuccess: cubit.loadGroups,
          tasksOnly: true,
        ),
      ],
    );
  }
}
