import 'package:flutter/material.dart';

class MeetingPhotosDashedBorder extends StatelessWidget {
  const MeetingPhotosDashedBorder({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
  });

  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius});

  static const _strokeWidth = 1.5;
  static const _dashLength = 6.0;
  static const _gapLength = 4.0;

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final rect = (Offset.zero & size).deflate(_strokeWidth / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashLength),
          paint,
        );
        distance += _dashLength + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
