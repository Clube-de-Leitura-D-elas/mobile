import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';

/// Centered text message used for empty and error states in the event
/// history screen. Mirrors the pattern of [GroupParticipantsErrorView].
class EventHistoryMessageView extends StatelessWidget {
  const EventHistoryMessageView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: context.typography.bodyDefault.copyWith(
            color: context.colors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
