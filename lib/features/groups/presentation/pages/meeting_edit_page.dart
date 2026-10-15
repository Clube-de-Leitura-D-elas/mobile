import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/pages/meeting_edit_screen.dart';

class MeetingEditPage extends StatelessWidget {
  const MeetingEditPage({super.key, required this.meeting});

  final MeetingDetailsEntity meeting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenHeader.back(title: context.l10n.meetingEditTitle),
      body: MeetingEditScreen(
        meeting: meeting,
        onSaved: (_) => Navigator.of(context).pop(),
      ),
    );
  }
}
