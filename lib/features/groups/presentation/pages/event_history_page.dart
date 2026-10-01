import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_cubit.dart';
import 'package:mobile/features/groups/presentation/cubit/event_history_state.dart';
import 'package:mobile/features/groups/presentation/pages/event_history_screen.dart';
import 'package:mobile/features/groups/presentation/widgets/event_history_message_view.dart';

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
          EventHistoryEmpty() => EventHistoryMessageView(
            message: context.l10n.groupEventHistoryEmpty,
          ),
          EventHistoryLoaded(:final meetings) => EventHistoryScreen(
            meetings: meetings,
          ),
          EventHistoryError(:final message) => EventHistoryMessageView(
            message: message,
          ),
        },
      ),
    );
  }
}
