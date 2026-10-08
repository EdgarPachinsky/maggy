/// SUPERSEDED: use `python3 tool/generate_icon.py` instead.
///
/// This script renders the OLD purple icon. Running it will overwrite the
/// current charcoal/lavender icon. Kept only for reference; safe to delete
/// (along with the `image` dev dependency).
///
/// Generates macOS app icon PNGs for Magic using the `image` package.
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final sizes = [16, 32, 64, 128, 256, 512, 1024];
  const outputDir = 'macos/Runner/Assets.xcassets/AppIcon.appiconset';

  for (final size in sizes) {
    final image = renderIcon(size);
    final bytes = img.encodePng(image);
    final file = File('$outputDir/app_icon_$size.png');
    file.writeAsBytesSync(bytes);
    print('Wrote ${file.path} (${bytes.length} bytes)');
  }

  print('Done.');
}

img.Image renderIcon(int size) {
  final image = img.Image(width: size, height: size);
  final s = size.toDouble();
  final cx = s / 2;
  final cy = s / 2;

  // Fill background with purple gradient (approximate with vertical bands).
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final t = (x + y) / (2 * s); // diagonal gradient
      final r = _lerp(108, 72, t).round();
      final g = _lerp(92, 52, t).round();
      final b = _lerp(231, 212, t).round();

      // Round-rect mask: skip corners.
      final cornerR = s * 0.22;
      if (_outsideRoundRect(x.toDouble(), y.toDouble(), s, s, cornerR)) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  // Draw four-point star.
  final outerR = s * 0.36;
  final innerR = s * 0.12;
  final starPoints = <math.Point<double>>[];
  for (var i = 0; i < 8; i++) {
    final angle = (i * math.pi / 4) - math.pi / 2;
    final r = i.isEven ? outerR : innerR;
    starPoints.add(math.Point(cx + r * math.cos(angle), cy + r * math.sin(angle)));
  }
  _fillPolygon(image, starPoints, 255, 255, 255, 240);

  // Center dot.
  _fillCircle(image, cx, cy, s * 0.04, 255, 255, 255, 255);

  // Sparkle lines.
  for (final angle in [0.0, math.pi / 2, math.pi, 3 * math.pi / 2]) {
    final innerD = s * 0.06;
    final outerD = s * 0.11;
    _drawLine(
      image,
      cx + innerD * math.cos(angle),
      cy + innerD * math.sin(angle),
      cx + outerD * math.cos(angle),
      cy + outerD * math.sin(angle),
      255, 255, 255, 170,
      (s * 0.02).clamp(1, 4).toInt(),
    );
  }

  return image;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

bool _outsideRoundRect(double x, double y, double w, double h, double r) {
  // Check if point is in one of the four corner regions and outside the arc.
  if (x < r && y < r) {
    return _dist(x, y, r, r) > r;
  }
  if (x > w - r && y < r) {
    return _dist(x, y, w - r, r) > r;
  }
  if (x < r && y > h - r) {
    return _dist(x, y, r, h - r) > r;
  }
  if (x > w - r && y > h - r) {
    return _dist(x, y, w - r, h - r) > r;
  }
  return false;
}

double _dist(double x1, double y1, double x2, double y2) {
  return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}

void _fillCircle(img.Image image, double cx, double cy, double r,
    int red, int green, int blue, int alpha) {
  final ri = r.ceil();
  for (var dy = -ri; dy <= ri; dy++) {
    for (var dx = -ri; dx <= ri; dx++) {
      if (dx * dx + dy * dy <= r * r) {
        final px = (cx + dx).round();
        final py = (cy + dy).round();
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          image.setPixelRgba(px, py, red, green, blue, alpha);
        }
      }
    }
  }
}

void _drawLine(img.Image image, double x1, double y1, double x2, double y2,
    int r, int g, int b, int a, int thickness) {
  final steps = (_dist(x1, y1, x2, y2) * 2).ceil();
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final x = x1 + (x2 - x1) * t;
    final y = y1 + (y2 - y1) * t;
    _fillCircle(image, x, y, thickness / 2, r, g, b, a);
  }
}

/// Scanline fill a convex polygon.
void _fillPolygon(img.Image image, List<math.Point<double>> points,
    int r, int g, int b, int a) {
  if (points.isEmpty) return;

  var minY = points[0].y;
  var maxY = points[0].y;
  for (final p in points) {
    if (p.y < minY) minY = p.y;
    if (p.y > maxY) maxY = p.y;
  }

  for (var y = minY.floor(); y <= maxY.ceil(); y++) {
    final intersections = <double>[];
    for (var i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      final p1 = points[i];
      final p2 = points[j];
      if ((p1.y <= y && p2.y > y) || (p2.y <= y && p1.y > y)) {
        final x = p1.x + (y - p1.y) / (p2.y - p1.y) * (p2.x - p1.x);
        intersections.add(x);
      }
    }
    intersections.sort();
    for (var i = 0; i + 1 < intersections.length; i += 2) {
      for (var x = intersections[i].floor();
          x <= intersections[i + 1].ceil();
          x++) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          image.setPixelRgba(x, y, r, g, b, a);
        }
      }
    }
  }
}
