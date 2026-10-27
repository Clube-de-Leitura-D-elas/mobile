import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/place_search_field.dart';

class MeetingEditResult {
  const MeetingEditResult({
    required this.date,
    this.googlePlaceId,
    this.description,
  });

  final DateTime date;

  final String? googlePlaceId;

  final String? description;
}

class MeetingEditScreen extends StatefulWidget {
  const MeetingEditScreen({
    super.key,
    required this.meeting,
    this.onSaved,
    this.isSaving = false,
  });

  final MeetingDetailsEntity meeting;
  final ValueChanged<MeetingEditResult>? onSaved;
  final bool isSaving;

  @override
  State<MeetingEditScreen> createState() => _MeetingEditScreenState();
}

class _MeetingEditScreenState extends State<MeetingEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final String _initialLocation;
  String? _selectedPlaceId;

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
    _initialLocation = _locationValue;
    _locationController = TextEditingController(text: _initialLocation);
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

    final date = _parse(_dateFormat, _dateController.text)!;
    final time = _parse(_timeFormat, _timeController.text)!;
    final description = _descriptionController.text.trim();

    widget.onSaved?.call(
      MeetingEditResult(
        date: DateTime(date.year, date.month, date.day, time.hour, time.minute),
        googlePlaceId: _selectedPlaceId,
        description: description.isEmpty ? null : description,
      ),
    );
  }

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');

  DateTime? _parse(DateFormat format, String value) {
    try {
      return format.parseStrict(value.trim());
    } on FormatException {
      return null;
    }
  }

  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  String? _validateDateTime(
    String? value,
    DateFormat format,
    String requiredMessage,
    String invalidMessage,
  ) {
    return _required(value, requiredMessage) ??
        (_parse(format, value!) == null ? invalidMessage : null);
  }

  String? _validateLocation(String? value) {
    final l10n = context.l10n;
    final missing = _required(value, l10n.meetingEditLocationError);
    if (missing != null) return missing;

    final changed = value!.trim() != _initialLocation;
    return changed && _selectedPlaceId == null
        ? l10n.meetingEditLocationSelectError
        : null;
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
              validator: (value) => _validateDateTime(
                value,
                _dateFormat,
                l10n.meetingEditDateError,
                l10n.meetingEditDateInvalidError,
              ),
            ),
            SizedBox(height: spacing.s16),
            AppTextField(
              label: l10n.meetingEditTimeLabel,
              controller: _timeController,
              hintText: l10n.meetingEditTimeHint,
              keyboardType: TextInputType.datetime,
              validator: (value) => _validateDateTime(
                value,
                _timeFormat,
                l10n.meetingEditTimeError,
                l10n.meetingEditTimeInvalidError,
              ),
            ),
            SizedBox(height: spacing.s16),
            PlaceSearchField(
              controller: _locationController,
              validator: _validateLocation,
              onEdited: () => _selectedPlaceId = null,
              onSelected: (place) => _selectedPlaceId = place.googlePlaceId,
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
              isLoading: widget.isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
