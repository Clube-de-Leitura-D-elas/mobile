import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

class MeetingTasksScreen extends StatelessWidget {
  const MeetingTasksScreen({super.key, this.meetingId});

  final String? meetingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHeader.back(title: context.l10n.groupMeetingMyTasksAction),
      body: const SizedBox.shrink(),
    );
  }
}

