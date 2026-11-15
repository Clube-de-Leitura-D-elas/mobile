import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/group_discovery/domain/entities/discovery_group_entity.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_discovery_failure.dart';
import 'package:mobile/features/group_discovery/domain/entities/group_search_filters.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_cubit.dart';
import 'package:mobile/features/group_discovery/presentation/cubit/group_search_state.dart';
import 'package:mobile/features/group_discovery/presentation/routes/group_discovery_route_paths.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_card.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_filters_dialog.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/group_search_skeleton.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/join_request_dialog.dart';
import 'package:mobile/features/group_discovery/presentation/widgets/join_request_feedback.dart';

/// Aba "Grupos" da busca: grupos de todas as cidades (ou da escolhida no
/// filtro; sem a lista de cidades, da cidade da leitora), com busca, filtros
/// e pedido de entrada direto no card.
class GroupSearchView extends StatelessWidget {
  const GroupSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;

    return BlocConsumer<GroupSearchCubit, GroupSearchState>(
      listenWhen: (previous, current) =>
          !previous.hasJoinFeedback && current.hasJoinFeedback,
      listener: (context, state) {
        showJoinRequestFeedback(context, failure: state.joinFailure);
        context.read<GroupSearchCubit>().clearJoinFeedback();
      },
      builder: (context, state) {
        final cubit = context.read<GroupSearchCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader.simple(title: l10n.groupSearchTitle),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s16,
                spacing.s16,
                spacing.s8,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      hintText: l10n.groupSearchHint,
                      onChanged: cubit.search,
                    ),
                  ),
                  _FiltersButton(state: state),
                ],
              ),
            ),
            Expanded(child: _GroupSearchBody(state: state)),
          ],
        );
      },
    );
  }
}

class _FiltersButton extends StatelessWidget {
  final GroupSearchState state;

  const _FiltersButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isActive = !state.filters.isEmpty;

    // O MergeSemantics junta o valor ao nó do botão (o Tooltip cria o seu).
    return MergeSemantics(
      child: Semantics(
        value: isActive ? l10n.groupSearchFiltersActive : null,
        child: IconButton(
          tooltip: l10n.groupSearchFiltersButton,
          color: isActive ? colors.actionPrimary : colors.textMuted,
          icon: Icon(isActive ? Icons.filter_alt : Icons.filter_alt_outlined),
          onPressed: () => _openFilters(context),
        ),
      ),
    );
  }

  Future<void> _openFilters(BuildContext context) async {
    final cubit = context.read<GroupSearchCubit>();
    final filters = await GroupSearchFiltersDialog.show(
      context,
      initial: state.filters,
      cities: state.citiesAvailable ? state.cities : null,
    );
    if (filters != null) await cubit.applyFilters(filters);
  }
}

class _GroupSearchBody extends StatelessWidget {
  final GroupSearchState state;

  const _GroupSearchBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<GroupSearchCubit>();
    final failure = state.failure;

    return switch (state.status) {
      GroupSearchStatus.loading => const GroupSearchSkeleton(),
      GroupSearchStatus.error => AppErrorState(
        message: switch (failure) {
          GroupDiscoveryNetworkFailure() => l10n.errorNoConnection,
          GroupDiscoverySessionExpiredFailure() => l10n.errorSessionExpired,
          GroupDiscoveryInactiveAccountFailure() => l10n.errorForbidden,
          _ => l10n.groupSearchLoadError,
        },
        onRetry: failure is GroupDiscoveryInactiveAccountFailure
            ? null
            : cubit.retry,
        secondaryLabel: failure is GroupDiscoverySessionExpiredFailure
            ? l10n.logoutTooltip
            : null,
        onSecondary: () => context.read<SessionCubit>().logOut(),
      ),
      GroupSearchStatus.loaded when state.items.isEmpty => _EmptyMessage(
        state: state,
      ),
      GroupSearchStatus.loaded => _GroupList(state: state),
    };
  }
}

class _EmptyMessage extends StatelessWidget {
  final GroupSearchState state;

  const _EmptyMessage({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              state.isFiltered
                  ? l10n.groupSearchEmptyFiltered
                  : l10n.groupSearchEmpty,
              textAlign: TextAlign.center,
              style: context.typography.bodyDefault.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
          if (!state.filters.isEmpty) ...[
            SizedBox(height: spacing.s16),
            AppButton.secondary(
              label: l10n.groupSearchFiltersClear,
              size: AppButtonSize.lg,
              onPressed: () => context.read<GroupSearchCubit>().applyFilters(
                GroupSearchFilters.empty,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupList extends StatelessWidget {
  final GroupSearchState state;

  const _GroupList({required this.state});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final l10n = context.l10n;
    final cubit = context.read<GroupSearchCubit>();
    final items = state.items;

    return ListView.separated(
      padding: EdgeInsets.all(spacing.s16),
      itemCount: items.length + 1,
      separatorBuilder: (_, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s16),
        child: Divider(height: 1, color: colors.borderDefault),
      ),
      itemBuilder: (context, index) {
        if (index < items.length) {
          final group = items[index];
          return GroupSearchCard(
            key: ValueKey(group.id),
            group: group,
            isRequesting: state.requestingIds.contains(group.id),
            onOpenDetails: () => _openDetails(context, group),
            onRequestJoin: () => _confirmJoin(context, group),
          );
        }
        if (state.loadMoreFailed) {
          return _LoadMoreError(onRetry: cubit.retry);
        }
        if (state.hasMore) {
          return _LoadMoreTrigger(
            key: ValueKey(state.page),
            onVisible: cubit.loadMore,
          );
        }
        return Text(
          l10n.groupSearchEnd,
          textAlign: TextAlign.center,
          style: context.typography.bodySmall.copyWith(color: colors.textMuted),
        );
      },
    );
  }

  /// Ao voltar, o status pode ter mudado (pedido feito na tela do grupo).
  Future<void> _openDetails(
    BuildContext context,
    DiscoveryGroupEntity group,
  ) async {
    final cubit = context.read<GroupSearchCubit>();
    await context.push<Object?>(GroupDiscoveryRoutePaths.detailsFor(group));
    await cubit.refreshGroup(group.id);
  }

  Future<void> _confirmJoin(
    BuildContext context,
    DiscoveryGroupEntity group,
  ) async {
    final cubit = context.read<GroupSearchCubit>();
    final confirmed = await JoinRequestDialog.show(
      context,
      groupNumber: group.number,
    );
    if (confirmed == true) await cubit.requestJoin(group.id);
  }
}

class _LoadMoreError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadMoreError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            context.l10n.groupSearchLoadMoreError,
            textAlign: TextAlign.center,
            style: context.typography.bodyDefault.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ),
        SizedBox(height: context.spacing.s12),
        AppButton.secondary(
          label: context.l10n.errorRetryButton,
          size: AppButtonSize.lg,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

/// Fim da lista: o ListView só constrói este item quando ele se aproxima da
/// tela, o que também cobre a primeira página que não preenche a tela toda.
class _LoadMoreTrigger extends StatefulWidget {
  final VoidCallback onVisible;

  const _LoadMoreTrigger({super.key, required this.onVisible});

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: context.l10n.groupSearchLoadingMore,
        child: CircularProgressIndicator(color: context.colors.actionPrimary),
      ),
    );
  }
}
