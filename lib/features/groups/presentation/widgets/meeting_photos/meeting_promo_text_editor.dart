import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';

typedef MeetingPromoTextSaver = Future<bool> Function(String text);

abstract final class MeetingPromoTextLimits {
  static const maxLength = 2000;
}

class MeetingPromoTextEditor extends StatefulWidget {
  const MeetingPromoTextEditor({
    super.key,
    required this.initialText,
    required this.onSave,
  });

  final String initialText;
  final MeetingPromoTextSaver onSave;

  static Future<void> show(
    BuildContext context, {
    required String initialText,
    required MeetingPromoTextSaver onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.bgDefault,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (_) =>
          MeetingPromoTextEditor(initialText: initialText, onSave: onSave),
    );
  }

  @override
  State<MeetingPromoTextEditor> createState() => _MeetingPromoTextEditorState();
}

class _MeetingPromoTextEditorState extends State<MeetingPromoTextEditor> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isTooLong =>
      _controller.text.trim().length > MeetingPromoTextLimits.maxLength;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final saved = await widget.onSave(_controller.text);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    const max = MeetingPromoTextLimits.maxLength;

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
            l10n.meetingPromoTextTitle,
            style: context.typography.headingH3.copyWith(
              color: context.colors.textDefault,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: spacing.s16),
          AppTextField(
            key: const ValueKey('meeting-promo-text-field'),
            controller: _controller,
            hintText: l10n.meetingPromoTextHint,
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            autofocus: true,
            helperText: _isTooLong
                ? null
                : l10n.meetingPromoTextCounter(
                    _controller.text.trim().length,
                    max,
                  ),
            errorText: _isTooLong ? l10n.meetingPromoTextTooLong(max) : null,
          ),
          SizedBox(height: spacing.s24),
          AppButton.primary(
            key: const ValueKey('meeting-promo-text-save'),
            label: l10n.meetingPromoTextSave,
            isLoading: _isSaving,
            onPressed: _isSaving || _isTooLong ? null : _save,
          ),
        ],
      ),
    );
  }
}
