import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_result.dart';

class RaffleResultScreen extends StatelessWidget {
  final RaffleResult result;
  final bool isPersisted;
  final bool isSubmitting;
  final VoidCallback? onDrawAgain;
  final VoidCallback? onFinish;

  const RaffleResultScreen({
    super.key,
    required this.result,
    this.isPersisted = false,
    this.isSubmitting = false,
    this.onDrawAgain,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: colors.bgDefault,
      appBar: ScreenHeader.back(
        title: context.l10n.raffleResultTitle,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Gap16(),
                      _DrawnBookSection(result: result),
                      const Gap16(),
                      _HostSection(result: result),
                      const Gap24(),
                    ],
                  ),
                ),
              ),
              _ResultActionButtons(
                isPersisted: isPersisted,
                isSubmitting: isSubmitting,
                onDrawAgain: onDrawAgain,
                onFinish: onFinish,
              ),
              const Gap16(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawnBookSection extends StatelessWidget {
  final RaffleResult result;

  const _DrawnBookSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgDefault,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: colors.borderDefault),
      ),
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.raffleDrawnBookLabel,
            style: typography.bodySmall.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap4(),
          Text(
            result.bookTitle,
            style: typography.headingH2.copyWith(
              color: colors.textDefault,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (result.bookAuthor != null && result.bookAuthor!.isNotEmpty) ...[
            const Gap4(),
            Text(
              result.bookAuthor!,
              style: typography.bodyDefault.copyWith(
                color: colors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Gap16(),
          _BookCoverWidget(coverUrl: result.bookCoverUrl),
        ],
      ),
    );
  }
}

class _BookCoverWidget extends StatelessWidget {
  final String? coverUrl;

  const _BookCoverWidget({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Semantics(
          image: true,
          label: 'Capa do livro sorteado',
          child: Image.network(
            coverUrl!,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const _BookCoverPlaceholder(),
          ),
        ),
      );
    }

    return const _BookCoverPlaceholder();
  }
}

class _BookCoverPlaceholder extends StatelessWidget {
  const _BookCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.bgSubtle,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 64,
          color: colors.textMuted,
        ),
      ),
    );
  }
}

class _HostSection extends StatelessWidget {
  final RaffleResult result;

  const _HostSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: colors.bgDefault,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: colors.borderDefault),
      ),
      padding: EdgeInsets.all(spacing.s16),
      child: Row(
        children: [
          _HostAvatar(avatarUrl: result.winnerAvatarUrl),
          const Gap16(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.raffleHostLabel,
                  style: typography.bodySmall.copyWith(
                    color: colors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap4(),
                Text(
                  result.winnerName,
                  style: typography.headingH3.copyWith(
                    color: colors.textDefault,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _HostAvatar({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.bgSubtle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.person,
                  size: 32,
                  color: colors.textMuted,
                ),
              )
            : Icon(
                Icons.person,
                size: 32,
                color: colors.textMuted,
              ),
      ),
    );
  }
}

class _ResultActionButtons extends StatelessWidget {
  final bool isPersisted;
  final bool isSubmitting;
  final VoidCallback? onDrawAgain;
  final VoidCallback? onFinish;

  const _ResultActionButtons({
    required this.isPersisted,
    required this.isSubmitting,
    this.onDrawAgain,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton.primary(
          label: context.l10n.raffleFinishButton,
          onPressed: isSubmitting ? null : onFinish,
        ),
        if (!isPersisted && onDrawAgain != null) ...[
          const Gap12(),
          AppButton.secondary(
            label: context.l10n.raffleDrawAgainButton,
            onPressed: isSubmitting ? null : onDrawAgain,
          ),
        ],
      ],
    );
  }
}
