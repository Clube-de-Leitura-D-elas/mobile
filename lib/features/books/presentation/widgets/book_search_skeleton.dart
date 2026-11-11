import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:shimmer/shimmer.dart';

class BookSearchSkeleton extends StatelessWidget {
  const BookSearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: context.l10n.bookSearchLoading,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: colors.surfaceSunken,
          highlightColor: colors.bgSubtle,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(4, (_) => const _BookSearchSkeletonRow()),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookSearchSkeletonRow extends StatelessWidget {
  const _BookSearchSkeletonRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.s16),
      child: Row(
        children: [
          Container(
            width: AppBookCover.listSize.width,
            height: AppBookCover.listSize.height,
            decoration: BoxDecoration(
              color: colors.bgDefault,
              borderRadius: BorderRadius.circular(AppBookCover.borderRadius),
            ),
          ),
          const Gap16(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 20, color: colors.bgDefault),
                const Gap8(),
                Container(height: 14, width: 120, color: colors.bgDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
