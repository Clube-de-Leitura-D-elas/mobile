import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';

class MeetingEditResult {
  const MeetingEditResult({
    required this.date,
    required this.time,
    required this.locationName,
    required this.description,
  });

  final String date;
  final String time;
  final String locationName;
  final String description;
}

class MeetingEditScreen extends StatefulWidget {
  const MeetingEditScreen({super.key, required this.meeting, this.onSaved});

  final MeetingDetailsEntity meeting;
  final ValueChanged<MeetingEditResult>? onSaved;

  @override
  State<MeetingEditScreen> createState() => _MeetingEditScreenState();
}

class _MeetingEditScreenState extends State<MeetingEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final date = widget.meeting.date?.toLocal();
    _dateController = TextEditingController(
      text: date == null ? '' : DateFormat('dd/MM/yyyy').format(date),
    );
    _timeController = TextEditingController(
      text: date == null ? '' : DateFormat('HH:mm').format(date),
    );
    _locationController = TextEditingController(text: _locationValue);
    _descriptionController = TextEditingController(
      text: widget.meeting.description ?? '',
    );
  }

  String get _locationValue {
    final parts = [widget.meeting.locationName, widget.meeting.locationAddress]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    return parts.join(' - ');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSaved?.call(
      MeetingEditResult(
        date: _dateController.text.trim(),
        time: _timeController.text.trim(),
        locationName: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing.s24,
          spacing.s16,
          spacing.s24,
          spacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l10n.meetingEditDateLabel,
              controller: _dateController,
              hintText: l10n.meetingEditDateHint,
              keyboardType: TextInputType.datetime,
              validator: (value) => _required(value, l10n.meetingEditDateError),
            ),
            SizedBox(height: spacing.s16),
            AppTextField(
              label: l10n.meetingEditTimeLabel,
              controller: _timeController,
              hintText: l10n.meetingEditTimeHint,
              keyboardType: TextInputType.datetime,
              validator: (value) => _required(value, l10n.meetingEditTimeError),
            ),
            SizedBox(height: spacing.s16),
            AppTextField(
              label: l10n.meetingEditLocationLabel,
              controller: _locationController,
              hintText: l10n.meetingEditLocationHint,
              validator: (value) =>
                  _required(value, l10n.meetingEditLocationError),
            ),
            SizedBox(height: spacing.s16),
            AppTextField(
              label: l10n.meetingEditDescriptionLabel,
              controller: _descriptionController,
              hintText: l10n.meetingEditDescriptionHint,
              maxLines: 3,
            ),
            SizedBox(height: spacing.s24),
            Text(
              l10n.meetingEditReadOnlySection,
              style: context.text.bodyDefaultEmphasis.copyWith(
                color: context.colors.textDefault,
              ),
            ),
            SizedBox(height: spacing.s12),
            AppTextField(
              label: l10n.meetingEditBookLabel,
              initialValue: widget.meeting.bookTitle,
              enabled: false,
            ),
            SizedBox(height: spacing.s16),
            AppTextField(
              label: l10n.meetingEditHostLabel,
              initialValue: widget.meeting.hostName,
              enabled: false,
            ),
            SizedBox(height: spacing.s32),
            AppButton.primary(
              label: l10n.meetingEditSaveButton,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
