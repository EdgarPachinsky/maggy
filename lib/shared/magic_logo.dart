import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Magic logo — a glowing wand star icon with "MAGIC" wordmark.
///
/// Can be used at various sizes. [size] controls the icon diameter;
/// the wordmark scales proportionally.
class MagicLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const MagicLogo({super.key, this.size = 64, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoMark(size: size, color: color),
        if (showWordmark) ...[
          SizedBox(height: size * 0.2),
          Text(
            'MAGGY',
            style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w800,
              letterSpacing: size * 0.08,
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

/// The icon portion of the logo — a diamond/star shape painted on canvas.
class _LogoMark extends StatelessWidget {
  final double size;
  final Color color;

  const _LogoMark({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoMarkPainter(color: color),
      ),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  final Color color;

  _LogoMarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Outer glow.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4);
    canvas.drawCircle(Offset(cx, cy), r * 0.7, glowPaint);

    // Four-point star.
    final starPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          Color.lerp(color, Colors.white, 0.3)!,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    final starPath = Path();
    const points = 4;
    final outerR = r * 0.85;
    final innerR = r * 0.3;

    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final radius = i.isEven ? outerR : innerR;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);

    // Center bright dot.
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(cx, cy), r * 0.08, dotPaint);

    // Small sparkle lines.
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = r * 0.03
      ..strokeCap = StrokeCap.round;

    for (var angle in [0.0, math.pi / 2, math.pi, 3 * math.pi / 2]) {
      final inner = r * 0.12;
      final outer = r * 0.22;
      canvas.drawLine(
        Offset(cx + inner * math.cos(angle), cy + inner * math.sin(angle)),
        Offset(cx + outer * math.cos(angle), cy + outer * math.sin(angle)),
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LogoMarkPainter oldDelegate) =>
      color != oldDelegate.color;
}
