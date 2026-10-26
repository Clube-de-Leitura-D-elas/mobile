import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/domain/entities/meeting_details_entity.dart';
import 'package:mobile/features/groups/presentation/widgets/meeting_info_row.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class MeetingInfoCard extends StatelessWidget {
  const MeetingInfoCard({
    super.key,
    required this.meeting,
    required this.title,
    this.onOpenMap,
  });

  final MeetingDetailsEntity meeting;
  final String title;

  final Future<bool> Function(Uri url)? onOpenMap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final l10n = context.l10n;
    final description = meeting.description;
    final mapUri = _mapUri();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: typography.headingH3.copyWith(color: colors.textDefault),
          ),
          SizedBox(height: spacing.s16),
          MeetingInfoRow(icon: AppIcons.calendar, label: _dateLabel(context)),
          SizedBox(height: spacing.s12),
          MeetingInfoRow(
            icon: AppIcons.book,
            label: l10n.meetingDetailsBook(meeting.bookTitle),
          ),
          SizedBox(height: spacing.s12),
          MeetingInfoRow(
            icon: AppIcons.user,
            label: l10n.meetingDetailsHost(meeting.hostName),
          ),
          SizedBox(height: spacing.s12),
          MeetingInfoRow(
            icon: AppIcons.location,
            label: _locationLabel(context),
            linkHint: mapUri == null ? null : l10n.meetingDetailsOpenMapHint,
            linkLabel: _locationText(),
            onTap: mapUri == null ? null : () => _openMap(context, mapUri),
          ),
          if (description != null && description.trim().isNotEmpty) ...[
            SizedBox(height: spacing.s24),
            Text(
              l10n.meetingDetailsDescriptionTitle,
              style: typography.bodyDefaultEmphasis.copyWith(
                color: colors.textDefault,
              ),
            ),
            SizedBox(height: spacing.s8),
            Text(
              description.trim(),
              key: const ValueKey('meeting-description'),
              style: typography.bodySmall.copyWith(color: colors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  String _dateLabel(BuildContext context) {
    final date = meeting.date;
    if (date == null) return context.l10n.meetingDetailsDateUndefined;

    final formatted = DateFormat(
      'dd/MM/yyyy',
      Localizations.localeOf(context).toString(),
    ).format(date.toLocal());
    return context.l10n.meetingDetailsDate(formatted);
  }

  String? _locationText() {
    final parts = [meeting.locationName, meeting.locationAddress]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    return parts.isEmpty ? null : parts.join(' - ');
  }

  String _locationLabel(BuildContext context) {
    final location = _locationText();
    if (location == null) return context.l10n.meetingDetailsLocationUndefined;
    return context.l10n.meetingDetailsLocation(location);
  }

  Uri? _mapUri() {
    final query = [meeting.locationName, meeting.locationAddress]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(', ');
    if (query.isEmpty) return null;

    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
      'query_place_id': ?meeting.locationGooglePlaceId,
    });
  }

  Future<void> _openMap(BuildContext context, Uri uri) async {
    final open =
        onOpenMap ??
        (url) => launcher.launchUrl(
          url,
          mode: launcher.LaunchMode.externalApplication,
        );

    try {
      final opened = await open(uri);
      if (!opened && context.mounted) {
        context.showErrorToast(context.l10n.meetingDetailsMapLaunchError);
      }
    } catch (_) {
      if (context.mounted) {
        context.showErrorToast(context.l10n.meetingDetailsMapLaunchError);
      }
    }
  }
}
