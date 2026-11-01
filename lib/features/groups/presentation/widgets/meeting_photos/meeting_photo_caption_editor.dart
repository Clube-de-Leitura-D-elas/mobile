import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

abstract final class MeetingPhotoCaptionLimits {
  static const maxLength = 500;
}

class MeetingPhotoCaptionEditor extends StatefulWidget {
  const MeetingPhotoCaptionEditor({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.bgDefault,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
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
    final spacing = context.spacing;
    const max = MeetingPhotoCaptionLimits.maxLength;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s24,
        spacing.s24,
        spacing.s24,
        spacing.s24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.meetingPhotoCaptionTitle,
            style: context.typography.headingH3.copyWith(
              color: context.colors.textDefault,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.s16),
          AppTextField(
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
          SizedBox(height: spacing.s24),
          AppButton.primary(
            key: const ValueKey('meeting-photo-caption-save'),
            label: l10n.meetingPhotoCaptionSave,
            onPressed: _isTooLong
                ? null
                : () => Navigator.of(context).pop(_controller.text.trim()),
          ),
          SizedBox(height: spacing.s8),
          AppButton.secondary(
            key: const ValueKey('meeting-photo-caption-skip'),
            label: l10n.meetingPhotoCaptionSkip,
            onPressed: () => Navigator.of(context).pop(''),
          ),
        ],
      ),
    );
  }
}
