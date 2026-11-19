import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile/core/extensions/build_context_l10n.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/raffles/domain/entities/raffle_participant.dart';

/// Baixa as capas antes da roleta girar: cada passo dura ~70 ms, menos que
/// o download de uma capa.
void precacheRaffleCovers(
  BuildContext context,
  List<RaffleParticipant> participants,
) {
  for (final p in participants) {
    final url = p.bookCoverUrl;
    if (url == null || url.isEmpty) continue;
    precacheImage(NetworkImage(url), context, onError: (_, _) {});
  }
}

/// Roleta que gira as indicações enquanto o servidor sorteia e desacelera até
/// parar na vencedora que ele devolveu.
class RaffleDrawReel extends StatefulWidget {
  final List<RaffleParticipant> participants;

  /// Nulo enquanto o sorteio ainda não voltou do servidor.
  final String? winnerId;
  final VoidCallback onRevealed;
  final Duration minSpin;
  final Duration celebration;

  const RaffleDrawReel({
    super.key,
    required this.participants,
    required this.winnerId,
    required this.onRevealed,
    this.minSpin = const Duration(milliseconds: 2400),
    this.celebration = const Duration(milliseconds: 1800),
  });

  @override
  State<RaffleDrawReel> createState() => _RaffleDrawReelState();
}

class _RaffleDrawReelState extends State<RaffleDrawReel>
    with SingleTickerProviderStateMixin {
  static const _fastTick = Duration(milliseconds: 70);
  static const _brakeTicks = [
    Duration(milliseconds: 90),
    Duration(milliseconds: 115),
    Duration(milliseconds: 150),
    Duration(milliseconds: 195),
    Duration(milliseconds: 255),
    Duration(milliseconds: 330),
    Duration(milliseconds: 430),
    Duration(milliseconds: 560),
  ];

  late final AnimationController _celebration;
  Timer? _timer;
  int _index = 0;
  int _ticks = 0;
  Duration _spun = Duration.zero;
  List<Duration>? _landing;
  bool _landed = false;
  bool _revealed = false;
  bool _motionless = false;

  @override
  void initState() {
    super.initState();
    _celebration = AnimationController(
      vsync: this,
      duration: widget.celebration,
    );
    _index = math.Random().nextInt(widget.participants.length);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _precacheCovers();
      if (MediaQuery.disableAnimationsOf(context)) {
        setState(() => _motionless = true);
        _revealWithoutMotion();
      } else {
        _schedule(_fastTick);
      }
    });
  }

  @override
  void didUpdateWidget(RaffleDrawReel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.winnerId == null && widget.winnerId != null) {
      if (_motionless) _revealWithoutMotion();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebration.dispose();
    super.dispose();
  }

  void _precacheCovers() => precacheRaffleCovers(context, widget.participants);

  int? get _winnerIndex {
    final id = widget.winnerId;
    if (id == null) return null;
    final i = widget.participants.indexWhere((p) => p.id == id);
    return i < 0 ? null : i;
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () => _tick(delay));
  }

  void _tick(Duration lastDelay) {
    if (!mounted) return;
    _spun += lastDelay;

    if (widget.winnerId != null && _winnerIndex == null) {
      // Vencedora fora da lista exibida: não há onde parar a roleta.
      _reveal();
      return;
    }

    setState(() {
      _index = (_index + 1) % widget.participants.length;
      _ticks++;
    });
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);

    final landing = _landing ??= _planLanding();
    if (landing == null) {
      _schedule(_fastTick);
    } else if (landing.isEmpty) {
      _land();
    } else {
      _schedule(landing.removeAt(0));
    }
  }

  /// Passos finais que fazem o último cair exatamente na vencedora.
  List<Duration>? _planLanding() {
    final winner = _winnerIndex;
    if (winner == null || _spun < widget.minSpin) return null;
    final n = widget.participants.length;
    final cruise = (winner - (_index + _brakeTicks.length)) % n;
    return [for (var i = 0; i < cruise; i++) _fastTick, ..._brakeTicks];
  }

  void _land() {
    setState(() => _landed = true);
    HapticFeedback.heavyImpact();
    _celebration.forward().whenComplete(_reveal);
  }

  void _revealWithoutMotion() {
    if (widget.winnerId == null) return;
    final winner = _winnerIndex;
    if (winner == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
      return;
    }
    setState(() {
      _index = winner;
      _landed = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  void _reveal() {
    if (!mounted || _revealed) return;
    _revealed = true;
    widget.onRevealed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final participant = widget.participants[_index];
    final status = _landed
        ? context.l10n.raffleRevealLabel
        : context.l10n.raffleShufflingLabel;
    final hidesParticipant = _motionless && !_landed;

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                label: _landed
                    ? '$status ${participant.bookTitle ?? ''}, '
                          '${context.l10n.raffleReelIndicatedBy(participant.name)}'
                    : status,
                child: ExcludeSemantics(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      status,
                      key: ValueKey(_landed),
                      textAlign: TextAlign.center,
                      style: typography.headingH3.copyWith(
                        color: _landed ? colors.textBrand : colors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap24(),
              AnimatedBuilder(
                animation: _celebration,
                builder: (context, child) => Transform.scale(
                  scale: _landed ? _popScale(_celebration.value) : 1,
                  child: child,
                ),
                child: ExcludeSemantics(
                  child: _ReelWindow(
                    highlighted: _landed,
                    child: hidesParticipant
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.actionPrimary,
                              ),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 60),
                            transitionBuilder: _slideUp,
                            child: _ReelCard(
                              key: ValueKey(_ticks),
                              participant: participant,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _celebration,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(
                  progress: _celebration.value,
                  colors: [
                    colors.actionPrimary,
                    colors.feedbackWarning,
                    colors.feedbackSuccess,
                    colors.feedbackInfo,
                    colors.textBrand,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static double _popScale(double t) {
    if (t < 0.15) return 1 + 0.12 * (t / 0.15);
    if (t < 0.35) return 1.12 - 0.08 * ((t - 0.15) / 0.2);
    return 1.04;
  }

  static Widget _slideUp(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final leaving = animation.status == AnimationStatus.reverse;
        final distance = 1 - animation.value;
        return FractionalTranslation(
          translation: Offset(0, (leaving ? -distance : distance) * 0.35),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }
}

const _windowSize = Size(240, 320);
const _coverAspectRatio = 128 / 184;

class _ReelWindow extends StatelessWidget {
  final bool highlighted;
  final Widget child;

  const _ReelWindow({required this.highlighted, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _windowSize.width,
      height: _windowSize.height,
      decoration: BoxDecoration(
        color: colors.bgDefault,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colors.actionPrimary,
          width: highlighted ? 4 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.actionPrimary.withValues(
              alpha: highlighted ? 0.45 : 0.18,
            ),
            blurRadius: highlighted ? 36 : 16,
            spreadRadius: highlighted ? 4 : 0,
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(26), child: child),
    );
  }
}

class _ReelCard extends StatelessWidget {
  final RaffleParticipant participant;

  const _ReelCard({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final cover = participant.bookCoverUrl;
    final title = participant.bookTitle;

    return Padding(
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: AspectRatio(
              aspectRatio: _coverAspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RaffleBookCover(url: cover),
              ),
            ),
          ),
          const Gap12(),
          Text(
            title != null && title.isNotEmpty ? title : participant.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.bodyDefault.copyWith(
              color: colors.textDefault,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap4(),
          Text(
            context.l10n.raffleReelIndicatedBy(participant.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.bodySmall.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class RaffleBookCover extends StatelessWidget {
  final String? url;

  const RaffleBookCover({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final cover = url;
    if (cover == null || cover.isEmpty) return const _CoverPlaceholder();
    return Image.network(
      cover,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (_, child, frame, loadedSync) =>
          loadedSync || frame != null ? child : const _CoverPlaceholder(),
      errorBuilder: (_, _, _) => const _CoverPlaceholder(),
    );
  }
}

/// Capas indicadas em leque, na mesma moldura em que a roleta vai girar.
class RaffleCoverFan extends StatefulWidget {
  final List<RaffleParticipant> participants;

  const RaffleCoverFan({super.key, required this.participants});

  @override
  State<RaffleCoverFan> createState() => _RaffleCoverFanState();
}

class _RaffleCoverFanState extends State<RaffleCoverFan> {
  static const _angles = [-0.14, 0.14, 0.0];
  static const _shifts = [-46.0, 46.0, 0.0];

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    precacheRaffleCovers(context, widget.participants);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = widget.participants.take(_angles.length).toList();
    final offset = _angles.length - shown.length;

    return ExcludeSemantics(
      child: SizedBox(
        width: _windowSize.width + 40,
        height: _windowSize.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < shown.length; i++)
              Transform.translate(
                offset: Offset(_shifts[i + offset], 0),
                child: Transform.rotate(
                  angle: _angles[i + offset],
                  child: Container(
                    width: 150,
                    height: 150 / _coverAspectRatio,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.borderDefault),
                      boxShadow: [
                        BoxShadow(
                          color: colors.textDefault.withValues(alpha: 0.12),
                          offset: const Offset(0, 6),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: RaffleBookCover(url: shown[i].bookCoverUrl),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceBrandSoft,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 56,
          color: colors.actionPrimary,
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _ConfettiPainter({required this.progress, required this.colors});

  static final List<_Piece> _pieces = _buildPieces();

  static List<_Piece> _buildPieces() {
    final random = math.Random(7);
    return List.generate(70, (i) {
      final angle = -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.6;
      return _Piece(
        angle: angle,
        speed: 260 + random.nextDouble() * 320,
        spin: (random.nextDouble() - 0.5) * 14,
        size: 6 + random.nextDouble() * 6,
        colorIndex: i,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final origin = Offset(size.width / 2, size.height / 2);
    final t = progress * 1.6;
    final opacity = progress < 0.7 ? 1.0 : (1 - progress) / 0.3;
    final paint = Paint();

    for (final piece in _pieces) {
      final dx = math.cos(piece.angle) * piece.speed * t;
      final dy = math.sin(piece.angle) * piece.speed * t + 420 * t * t;
      paint.color = colors[piece.colorIndex % colors.length].withValues(
        alpha: opacity,
      );
      canvas
        ..save()
        ..translate(origin.dx + dx, origin.dy + dy)
        ..rotate(piece.spin * t)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.55,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Piece {
  final double angle;
  final double speed;
  final double spin;
  final double size;
  final int colorIndex;

  const _Piece({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.colorIndex,
  });
}
