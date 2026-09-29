import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_state.dart';
import 'package:mobile/features/groups/presentation/pages/event_history_screen.dart';

class EventHistoryPage extends StatelessWidget {
  const EventHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHeader.back(title: context.l10n.groupEventHistoryTitle),
      body: BlocBuilder<EventHistoryCubit, EventHistoryState>(
        builder: (context, state) => switch (state) {
          EventHistoryLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          EventHistoryEmpty() => Center(
            child: Text(
              context.l10n.groupEventHistoryEmpty,
              style: context.typography.bodyDefault.copyWith(
                color: context.colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          EventHistoryLoaded(:final meetings) => EventHistoryScreen(
            meetings: meetings,
          ),
          EventHistoryError(:final message) => Center(child: Text(message)),
        },
      ),
    );
  }
}
