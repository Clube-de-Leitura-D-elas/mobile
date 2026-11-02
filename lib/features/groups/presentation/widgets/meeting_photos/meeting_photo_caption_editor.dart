import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

abstract final class MeetingPhotoCaptionLimits {
  static const maxLength = 500;
}

class MeetingPhotoCaptionEditor extends StatefulWidget {
  const MeetingPhotoCaptionEditor({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const MeetingPhotoCaptionEditor(),
    );
  }

  @override
  State<MeetingPhotoCaptionEditor> createState() =>
      _MeetingPhotoCaptionEditorState();
}

class _MeetingPhotoCaptionEditorState extends State<MeetingPhotoCaptionEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _isTooLong =>
      _controller.text.trim().length > MeetingPhotoCaptionLimits.maxLength;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const max = MeetingPhotoCaptionLimits.maxLength;

    return AppDialog(
      title: l10n.meetingPhotoCaptionTitle,
      actions: [
        AppButton.primary(
          key: const ValueKey('meeting-photo-caption-save'),
          label: l10n.meetingPhotoCaptionSave,
          onPressed: _isTooLong
              ? null
              : () => Navigator.of(context).pop(_controller.text.trim()),
        ),
        AppButton.secondary(
          key: const ValueKey('meeting-photo-caption-skip'),
          label: l10n.meetingPhotoCaptionSkip,
          onPressed: () => Navigator.of(context).pop(''),
        ),
      ],
      child: AppTextField(
        key: const ValueKey('meeting-photo-caption-field'),
        controller: _controller,
        hintText: l10n.meetingPhotoCaptionHint,
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        autofocus: true,
        helperText: _isTooLong
            ? null
            : l10n.meetingPhotoCaptionCounter(
                _controller.text.trim().length,
                max,
              ),
        errorText: _isTooLong ? l10n.meetingPhotoCaptionTooLong(max) : null,
      ),
    );
  }
}
