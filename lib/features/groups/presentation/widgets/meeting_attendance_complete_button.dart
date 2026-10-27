import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

/// "Concluir lista de presença": fica em loading enquanto `onComplete` roda.
class MeetingAttendanceCompleteButton extends StatefulWidget {
  const MeetingAttendanceCompleteButton({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  State<MeetingAttendanceCompleteButton> createState() =>
      _MeetingAttendanceCompleteButtonState();
}

class _MeetingAttendanceCompleteButtonState
    extends State<MeetingAttendanceCompleteButton> {
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onComplete();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton.primary(
      label: context.l10n.meetingAttendanceCompleteAction,
      isLoading: _submitting,
      onPressed: _submitting ? null : _submit,
    );
  }
}
