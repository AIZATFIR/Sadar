import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../models/future_self.dart';

class FutureSelfVisualizer extends StatelessWidget {
  const FutureSelfVisualizer({
    super.key,
    required this.snapshot,
    this.size = 110.0,
    this.strokeWidth = 10.0,
    this.showCenterText = true,
  });

  final FutureSelfSnapshot snapshot;
  final double size;
  final double strokeWidth;
  final bool showCenterText;

  @override
  Widget build(BuildContext context) {
    final semanticLabel =
        'Visualisasi Masa Depan: ${snapshot.completedActivities} dari ${snapshot.totalActivities} kegiatan selesai (${(snapshot.completionRatio * 100).toInt()}%)';

    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _FutureSelfDialPainter(
                activities: snapshot.activities,
                strokeWidth: strokeWidth,
                completionRatio: snapshot.completionRatio,
              ),
            ),
            if (showCenterText)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${snapshot.completedActivities}/${snapshot.totalActivities}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF0C987), // Calm gold
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    snapshot.isFulfilled ? 'FULFILLED' : 'SELESAI',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: math.max(8.0, size * 0.08),
                      fontWeight: FontWeight.w700,
                      color: snapshot.isFulfilled
                          ? const Color(0xFF10B981) // Serene emerald
                          : const Color(0xFF8E8B99),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FutureSelfDialPainter extends CustomPainter {
  _FutureSelfDialPainter({
    required this.activities,
    required this.strokeWidth,
    required this.completionRatio,
  });

  final List<FutureSelfActivityItem> activities;
  final double strokeWidth;
  final double completionRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final total = activities.length;

    final bgPaint = Paint()
      ..color = const Color(0xFF26252E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      canvas.drawCircle(center, radius, bgPaint);
      return;
    }

    final sweepPerItem = (2 * math.pi) / total;
    const gapAngle = 0.08; // gap between segments in radians

    for (int i = 0; i < total; i++) {
      final act = activities[i];
      final startAngle = -math.pi / 2 + (i * sweepPerItem) + (gapAngle / 2);
      final itemSweep = sweepPerItem - gapAngle;

      // Base track segment
      final segmentBgPaint = Paint()
        ..color = const Color(0xFF21202A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        itemSweep,
        false,
        segmentBgPaint,
      );

      if (act.isCompleted) {
        final activeColor = Color(act.colorValue != 0 ? act.colorValue : 0xFF10B981);
        final fillPaint = Paint()
          ..color = activeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          itemSweep,
          false,
          fillPaint,
        );
      } else {
        // Pending indicator dot in the middle of the segment
        final midAngle = startAngle + (itemSweep / 2);
        final dotPos = Offset(
          center.dx + radius * math.cos(midAngle),
          center.dy + radius * math.sin(midAngle),
        );
        final dotPaint = Paint()
          ..color = const Color(0xFF43414F)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotPos, strokeWidth * 0.22, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FutureSelfDialPainter oldDelegate) {
    return oldDelegate.completionRatio != completionRatio ||
        oldDelegate.activities != activities ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
