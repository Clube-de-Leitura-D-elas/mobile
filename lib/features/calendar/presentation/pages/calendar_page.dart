import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/core/routes/quick_access_routes.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:mobile/features/calendar/domain/entities/calendar_failure.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:mobile/features/calendar/presentation/cubit/calendar_state.dart';
import 'package:mobile/features/calendar/presentation/routes/calendar_route_paths.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_day_header.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_filter_chips.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_list_skeleton.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_meeting_tile.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_month_grid.dart';
import 'package:mobile/features/calendar/presentation/widgets/calendar_month_header.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDefault,
      body: SafeArea(
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, state) => _CalendarContent(state: state),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: QuickAccessItem.calendar.index,
        onItemSelected: (index) => context.goToQuickAccessTab(
          index,
          currentIndex: QuickAccessItem.calendar.index,
        ),
      ),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  final CalendarState state;

  const _CalendarContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final cubit = context.read<CalendarCubit>();
    final selectedDay = state.selectedDay;
    final horizontal = EdgeInsets.symmetric(horizontal: spacing.s16);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            spacing.s16,
            spacing.s16,
            spacing.s8,
            spacing.s8,
          ),
          sliver: SliverToBoxAdapter(
            child: CalendarMonthHeader(
              month: state.month,
              onPrevious: cubit.showPreviousMonth,
              onNext: cubit.showNextMonth,
            ),
          ),
        ),
        // Margem menor que a da tela para cada coluna ter pelo menos 48 de
        // largura em aparelhos de 360.
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s8),
          sliver: SliverToBoxAdapter(
            child: CalendarMonthGrid(
              month: state.month,
              today: state.today,
              selectedDay: selectedDay,
              meetingCountByDay: state.meetingCountByDay,
              onDaySelected: cubit.selectDay,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            spacing.s16,
            spacing.s16,
            spacing.s8,
            spacing.s8,
          ),
          sliver: SliverToBoxAdapter(
            child: selectedDay != null
                ? CalendarDayHeader(
                    day: selectedDay,
                    onClear: cubit.clearSelectedDay,
                  )
                : state.status == CalendarStatus.loaded
                ? CalendarFilterChips(
                    selected: state.filter,
                    upcomingCount: state.upcoming.length,
                    onSelected: cubit.selectFilter,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        ..._body(context, horizontal),
      ],
    );
  }

  List<Widget> _body(BuildContext context, EdgeInsets horizontal) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final cubit = context.read<CalendarCubit>();

    switch (state.status) {
      case CalendarStatus.loading:
        return [
          SliverPadding(
            padding: horizontal,
            sliver: const SliverToBoxAdapter(child: CalendarListSkeleton()),
          ),
        ];
      case CalendarStatus.error:
        final failure = state.failure;
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppErrorState(
              message: switch (failure) {
                CalendarNetworkFailure() => l10n.errorNoConnection,
                CalendarSessionExpiredFailure() => l10n.errorSessionExpired,
                CalendarForbiddenFailure() => l10n.errorForbidden,
                _ => l10n.calendarLoadError,
              },
              onRetry: failure is CalendarForbiddenFailure ? null : cubit.load,
              secondaryLabel: failure is CalendarSessionExpiredFailure
                  ? l10n.logoutTooltip
                  : null,
              onSecondary: () => context.read<SessionCubit>().logOut(),
            ),
          ),
        ];
      case CalendarStatus.loaded:
        final meetings = state.visibleMeetings;
        if (meetings.isEmpty) {
          return [
            SliverPadding(
              padding: EdgeInsets.all(spacing.s24),
              sliver: SliverToBoxAdapter(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _emptyMessage(context),
                    textAlign: TextAlign.center,
                    style: context.typography.bodyDefault.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: horizontal.copyWith(bottom: spacing.s16),
            sliver: SliverList.separated(
              itemCount: meetings.length,
              separatorBuilder: (_, _) => SizedBox(height: spacing.s12),
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                final destination = CalendarRoutePaths.destinationFor(meeting);
                return CalendarMeetingTile(
                  key: ValueKey(meeting.id),
                  meeting: meeting,
                  showDate: state.selectedDay == null,
                  onTap: () => unawaited(context.push<Object?>(destination)),
                );
              },
            ),
          ),
        ];
    }
  }

  String _emptyMessage(BuildContext context) {
    final l10n = context.l10n;
    if (state.selectedDay != null) return l10n.calendarEmptyDay;
    return switch (state.filter) {
      CalendarFilter.all => l10n.calendarEmptyMonth,
      CalendarFilter.upcoming => l10n.calendarEmptyUpcoming,
      CalendarFilter.past => l10n.calendarEmptyPast,
    };
  }
}
