import 'dart:math';

import 'package:flutter/material.dart';
import 'package:theorypocket/features/circle_of_fifths/circle_data.dart';
import 'package:theorypocket/features/circle_of_fifths/circle_provider.dart';

// Ring radii as fractions of the outer radius R
const double _outerFrac = 1.00;
const double _majInnerFrac = 0.60;
const double _minInnerFrac = 0.42;
const double _dimInnerFrac = 0.27;
const double _centerFrac = 0.20;
const double _gapAngle = pi / 80; // ~2.25° gap between segments

// ── Painter ───────────────────────────────────────────────────────────────────

class CircleOfFifthsPainter extends CustomPainter {
  final CircleSelection? selection;
  final ColorScheme colorScheme;

  CircleOfFifthsPainter({required this.selection, required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = min(size.width, size.height) / 2 * 0.92;

    final outerR = R * _outerFrac;
    final majInnerR = R * _majInnerFrac;
    final minInnerR = R * _minInnerFrac;
    final dimInnerR = R * _dimInnerFrac;
    final centerR = R * _centerFrac;

    for (int i = 0; i < 12; i++) {
      final double centerAngle = -pi / 2 + i * (2 * pi / 12);
      final double startAngle = centerAngle - pi / 12 + _gapAngle / 2;
      final double sweep = pi / 6 - _gapAngle;

      final bool majSel =
          selection?.index == i && selection?.ring == CircleRing.major;
      final bool minSel =
          selection?.index == i && selection?.ring == CircleRing.minor;
      final bool dimSel =
          selection?.index == i && selection?.ring == CircleRing.dim;

      // Companion highlight (same index, different ring)
      final bool majCompanion = selection?.index == i &&
          selection?.ring != CircleRing.major &&
          selection != null;
      final bool minCompanion = selection?.index == i &&
          selection?.ring != CircleRing.minor &&
          selection != null;

      // ── Major ring ────────────────────────────────────────────────────────
      _drawSegment(
        canvas: canvas,
        center: center,
        innerR: majInnerR,
        outerR: outerR,
        startAngle: startAngle,
        sweep: sweep,
        isSelected: majSel,
        isCompanion: majCompanion,
        gradientColors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
        companionColor: colorScheme.primary.withOpacity(0.15),
        defaultColor: colorScheme.surfaceContainerHigh,
        outlineColor: colorScheme.outline.withOpacity(0.5),
      );

      // ── Minor ring ────────────────────────────────────────────────────────
      _drawSegment(
        canvas: canvas,
        center: center,
        innerR: minInnerR,
        outerR: majInnerR,
        startAngle: startAngle,
        sweep: sweep,
        isSelected: minSel,
        isCompanion: minCompanion,
        gradientColors: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.7)],
        companionColor: colorScheme.secondary.withOpacity(0.15),
        defaultColor: colorScheme.surfaceContainer,
        outlineColor: colorScheme.outline.withOpacity(0.5),
      );

      // ── Dim ring ──────────────────────────────────────────────────────────
      _drawSegment(
        canvas: canvas,
        center: center,
        innerR: dimInnerR,
        outerR: minInnerR,
        startAngle: startAngle,
        sweep: sweep,
        isSelected: dimSel,
        isCompanion: false,
        gradientColors: [colorScheme.tertiary, colorScheme.tertiary.withOpacity(0.7)],
        companionColor: Colors.transparent,
        defaultColor: colorScheme.surface,
        outlineColor: colorScheme.outline.withOpacity(0.5),
      );
    }

    // ── Center circle ─────────────────────────────────────────────────────────
    _drawCenter(canvas, center, centerR);

    // ── Text labels ───────────────────────────────────────────────────────────
    for (int i = 0; i < 12; i++) {
      final double centerAngle = -pi / 2 + i * (2 * pi / 12);

      final bool isSelected = selection?.index == i;

      // Major label — inside outer ring
      _drawLabel(
        canvas: canvas,
        center: center,
        text: majorKeys[i],
        angle: centerAngle,
        radius: R * (_outerFrac + _majInnerFrac) / 2,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isSelected && selection?.ring == CircleRing.major
            ? colorScheme.onPrimary
            : colorScheme.onSurface,
      );

      // Minor label — inside minor ring
      _drawLabel(
        canvas: canvas,
        center: center,
        text: minorKeys[i],
        angle: centerAngle,
        radius: R * (_majInnerFrac + _minInnerFrac) / 2,
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: isSelected && selection?.ring == CircleRing.minor
            ? colorScheme.onSecondary
            : colorScheme.onSurfaceVariant,
      );

      // Dim label — inside dim ring
      _drawLabel(
        canvas: canvas,
        center: center,
        text: dimKeys[i],
        angle: centerAngle,
        radius: R * (_minInnerFrac + _dimInnerFrac) / 2,
        fontSize: 7.5,
        fontWeight: FontWeight.w500,
        color: isSelected && selection?.ring == CircleRing.dim
            ? colorScheme.onTertiary
            : colorScheme.onSurfaceVariant.withOpacity(0.7),
      );
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _drawSegment({
    required Canvas canvas,
    required Offset center,
    required double innerR,
    required double outerR,
    required double startAngle,
    required double sweep,
    required bool isSelected,
    required bool isCompanion,
    required List<Color> gradientColors,
    required Color companionColor,
    required Color defaultColor,
    required Color outlineColor,
  }) {
    final path = _buildAnnularPath(center, innerR, outerR, startAngle, sweep);

    final fillPaint = Paint()..style = PaintingStyle.fill;

    if (isSelected) {
      fillPaint.shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: outerR));
    } else if (isCompanion) {
      fillPaint.color = companionColor;
    } else {
      fillPaint.color = defaultColor;
    }

    canvas.drawPath(path, fillPaint);

    // Outline
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = outlineColor
        ..strokeWidth = 0.8,
    );
  }

  Path _buildAnnularPath(
    Offset center,
    double innerR,
    double outerR,
    double startAngle,
    double sweep,
  ) {
    final outerRect = Rect.fromCircle(center: center, radius: outerR);
    final innerRect = Rect.fromCircle(center: center, radius: innerR);
    final path = Path()
      ..moveTo(
        center.dx + innerR * cos(startAngle),
        center.dy + innerR * sin(startAngle),
      )
      ..arcTo(outerRect, startAngle, sweep, false)
      ..arcTo(innerRect, startAngle + sweep, -sweep, false)
      ..close();
    return path;
  }

  void _drawCenter(Canvas canvas, Offset center, double radius) {
    // Gradient fill
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [colorScheme.surfaceContainerHigh, colorScheme.surface],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);

    // Border glow
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = colorScheme.primary.withOpacity(0.3)
        ..strokeWidth = 1.5,
    );

    // Music note emoji via TextPainter
    final tp = TextPainter(
      text: TextSpan(
        text: '𝄞', // treble clef unicode
        style: TextStyle(fontSize: 26, color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  void _drawLabel({
    required Canvas canvas,
    required Offset center,
    required String text,
    required double angle,
    required double radius,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = center.dx + radius * cos(angle);
    final y = center.dy + radius * sin(angle);
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(CircleOfFifthsPainter old) =>
      old.selection != selection || old.colorScheme != colorScheme;
}

// ── Hit testing helper ────────────────────────────────────────────────────────

({int index, CircleRing ring})? hitTest(
  Offset localPos,
  Size size,
) {
  final center = Offset(size.width / 2, size.height / 2);
  final R = min(size.width, size.height) / 2 * 0.92;

  final dx = localPos.dx - center.dx;
  final dy = localPos.dy - center.dy;
  final dist = sqrt(dx * dx + dy * dy);

  // Determine ring
  CircleRing? ring;
  if (dist >= R * _dimInnerFrac && dist < R * _minInnerFrac) {
    ring = CircleRing.dim;
  } else if (dist >= R * _minInnerFrac && dist < R * _majInnerFrac) {
    ring = CircleRing.minor;
  } else if (dist >= R * _majInnerFrac && dist <= R * _outerFrac) {
    ring = CircleRing.major;
  }

  if (ring == null) return null;

  // Determine segment: C is at top (-π/2), clockwise
  double angle = atan2(dy, dx) + pi / 2; // shift so top = 0
  if (angle < 0) angle += 2 * pi;

  final int index = ((angle + pi / 12) / (pi / 6)).floor() % 12;
  return (index: index, ring: ring);
}
