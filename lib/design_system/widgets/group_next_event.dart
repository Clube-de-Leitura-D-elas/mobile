import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/icons/app_icons.dart';
import 'package:mobile/design_system/tokens/color_tokens.dart';
import 'package:mobile/design_system/tokens/spacing_tokens.dart';
import 'package:mobile/design_system/tokens/typography_tokens.dart';
import 'package:mobile/design_system/widgets/app_card.dart';
import 'package:mobile/design_system/widgets/app_icon.dart';

enum GroupNextEventStatus { loading, loaded, empty, error }

class GroupNextEventData {
  const GroupNextEventData({
    required this.location,
    required this.date,
    required this.hostName,
    this.bookTitle,
    this.bookCover,
  });

  final String location;
  final DateTime date;
  final String hostName;

  /// Null when the event has no book yet.
  final String? bookTitle;
  final ImageProvider<Object>? bookCover;
}

class GroupNextEvent extends StatelessWidget {
  const GroupNextEvent({
    super.key,
    this.status = GroupNextEventStatus.empty,
    this.data,
    this.onEventHistoryPressed,
  }) : assert(
         status != GroupNextEventStatus.loaded || data != null,
         'Loaded state requires event data.',
       );

  final GroupNextEventStatus status;
  final GroupNextEventData? data;

  /// Called when the user taps the "Ver histórico de eventos" link.
  /// When null, the link is not rendered.
  final VoidCallback? onEventHistoryPressed;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      GroupNextEventStatus.loading => const _LoadingState(),
      GroupNextEventStatus.error => _MessageState(
        icon: Icons.error_outline,
        message: context.l10n.genericError,
      ),
      GroupNextEventStatus.empty => _MessageState(
        icon: Icons.event_busy_outlined,
        message: context.l10n.groupNextEventEmpty,
      ),
      GroupNextEventStatus.loaded when data != null => _EventDetails(
        data: data!,
        onEventHistoryPressed: onEventHistoryPressed,
      ),
      GroupNextEventStatus.loaded => _MessageState(
        icon: Icons.error_outline,
        message: context.l10n.genericError,
      ),
    };
  }
}

class _EventDetails extends StatelessWidget {
  const _EventDetails({required this.data, this.onEventHistoryPressed});

  final GroupNextEventData data;
  final VoidCallback? onEventHistoryPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final date = DateFormat('dd/MM/yyyy', 'pt_BR').format(data.date.toLocal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _EventMetadata(
                icon: AppIcons.location,
                label: data.location.isEmpty
                    ? context.l10n.groupNextEventNoLocation
                    : data.location,
              ),
            ),
            SizedBox(width: spacing.s16),
            Expanded(
              child: _EventMetadata(icon: AppIcons.calendar, label: date),
            ),
          ],
        ),
        SizedBox(height: spacing.s16),
        _EventMetadata(
          icon: AppIcons.user,
          label: context.l10n.groupNextEventHost(data.hostName),
        ),
        SizedBox(height: spacing.s16),
        _CurrentBook(title: data.bookTitle, cover: data.bookCover),
        if (onEventHistoryPressed != null) ...[
          SizedBox(height: spacing.s12),
          Center(
            child: Semantics(
              button: true,
              enabled: true,
              label: context.l10n.groupNextEventHistoryLink,
              child: InkWell(
                onTap: onEventHistoryPressed,
                borderRadius: BorderRadius.circular(spacing.s4),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.s4),
                  child: Text(
                    context.l10n.groupNextEventHistoryLink,
                    style: context.text.bodyDefaultEmphasis.copyWith(
                      color: context.colors.textBrand,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EventMetadata extends StatelessWidget {
  const _EventMetadata({required this.icon, required this.label});

  final AppIconAsset icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon: icon, size: spacing.s16, color: colors.textMuted),
        SizedBox(width: spacing.s8),
        Flexible(
          child: Text(
            label,
            style: context.text.bodySmall.copyWith(color: colors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _CurrentBook extends StatelessWidget {
  const _CurrentBook({required this.title, required this.cover});

  final String? title;
  final ImageProvider<Object>? cover;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.groupNextEventCurrentBookLabel,
          style: context.text.bodyDefault.copyWith(
            color: context.colors.textDefault,
          ),
        ),
        SizedBox(height: context.spacing.s12),
        Center(
          child: _BookCover(title: title, cover: cover),
        ),
      ],
    );
  }
}

abstract final class _BookCoverSize {
  static const double width = 180;
  static const double height = 240;
}

class _BookCover extends StatelessWidget {
  const _BookCover({required this.title, required this.cover});

  final String? title;
  final ImageProvider<Object>? cover;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = this.title;
    final cover = this.cover;

    if (title == null) {
      return _BookCoverPlaceholder(message: l10n.groupNextEventBookUndefined);
    }
    if (cover == null) {
      return _BookCoverPlaceholder(
        message: l10n.groupNextEventBookCoverUnavailable,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppCard.borderRadius / 2),
      child: Image(
        image: cover,
        width: _BookCoverSize.width,
        height: _BookCoverSize.height,
        fit: BoxFit.cover,
        semanticLabel: l10n.groupNextEventBookCoverSemanticLabel(title),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const _BookCoverLoading(),
        errorBuilder: (_, _, _) => _BookCoverPlaceholder(
          message: l10n.groupNextEventBookCoverUnavailable,
        ),
      ),
    );
  }
}

class _BookCoverFrame extends StatelessWidget {
  const _BookCoverFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _BookCoverSize.width,
      height: _BookCoverSize.height,
      alignment: Alignment.center,
      padding: EdgeInsets.all(context.spacing.s16),
      decoration: BoxDecoration(
        color: context.colors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppCard.borderRadius / 2),
      ),
      child: child,
    );
  }
}

class _BookCoverPlaceholder extends StatelessWidget {
  const _BookCoverPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return _BookCoverFrame(
      key: const ValueKey('group-next-event-book-placeholder'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            icon: AppIcons.book,
            size: spacing.s48,
            color: colors.textMuted,
          ),
          SizedBox(height: spacing.s8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodySmall.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _BookCoverLoading extends StatelessWidget {
  const _BookCoverLoading();

  @override
  Widget build(BuildContext context) {
    return _BookCoverFrame(
      key: const ValueKey('group-next-event-book-loading'),
      child: SizedBox.square(
        dimension: context.spacing.s24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.actionPrimary,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Row(
      children: [
        Icon(icon, size: spacing.s16, color: colors.textMuted),
        SizedBox(width: spacing.s8),
        Expanded(
          child: Text(
            message,
            style: context.text.bodySmall.copyWith(color: colors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: context.spacing.s16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.actionPrimary,
        ),
      ),
    );
  }
}
