import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/groups/presentation/widgets/app_group_avatar.dart';
import 'package:mobile/features/profile/domain/entities/profile_summary_entity.dart';

/// Fotos dos grupos da leitora em linha, com uma seta enquanto houver mais
/// grupos à direita.
class ProfileGroupsCarousel extends StatefulWidget {
  const ProfileGroupsCarousel({
    super.key,
    required this.groups,
    required this.onGroupTap,
  });

  final List<ProfileGroupEntity> groups;
  final ValueChanged<String> onGroupTap;

  static const double avatarDiameter = 96;

  @override
  State<ProfileGroupsCarousel> createState() => _ProfileGroupsCarouselState();
}

class _ProfileGroupsCarouselState extends State<ProfileGroupsCarousel> {
  final _controller = ScrollController();
  bool _canScrollForward = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrow());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Chamado a cada mudança de medidas da rolagem: rolar, trocar a lista ou
  // mudar a largura da tela (girar o celular, tela dividida).
  bool _onScrollMetrics(ScrollMetricsNotification notification) {
    _updateArrow();
    return false;
  }

  void _updateArrow() {
    if (!mounted || !_controller.hasClients) return;
    final canScrollForward = _controller.position.extentAfter > 0;
    if (canScrollForward != _canScrollForward) {
      setState(() => _canScrollForward = canScrollForward);
    }
  }

  void _scrollForward() {
    final position = _controller.position;
    _controller.animateTo(
      math.min(
        position.pixels + position.viewportDimension * 0.8,
        position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final l10n = context.l10n;

    return SizedBox(
      height: ProfileGroupsCarousel.avatarDiameter,
      child: Row(
        children: [
          Expanded(
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: _onScrollMetrics,
              child: ListView.separated(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                itemCount: widget.groups.length,
                separatorBuilder: (_, _) => SizedBox(width: spacing.s16),
                itemBuilder: (context, index) {
                  final group = widget.groups[index];
                  void open() => widget.onGroupTap(group.id);
                  return Semantics(
                    container: true,
                    button: true,
                    label: l10n.profileGroupLabel(group.number),
                    onTap: open,
                    child: InkWell(
                      key: ValueKey('profile-group-${group.id}'),
                      excludeFromSemantics: true,
                      onTap: open,
                      customBorder: const CircleBorder(),
                      child: ExcludeSemantics(
                        child: AppGroupAvatar(
                          photoUrl: group.photoUrl,
                          diameter: ProfileGroupsCarousel.avatarDiameter,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_canScrollForward)
            Semantics(
              container: true,
              button: true,
              label: l10n.profileMoreGroupsButtonLabel,
              onTap: _scrollForward,
              child: InkWell(
                excludeFromSemantics: true,
                onTap: _scrollForward,
                customBorder: const CircleBorder(),
                // 12 + 24 + 12: alvo de toque de 48.
                child: Padding(
                  padding: EdgeInsets.all(spacing.s12),
                  child: Icon(
                    Icons.chevron_right,
                    size: spacing.s24,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
