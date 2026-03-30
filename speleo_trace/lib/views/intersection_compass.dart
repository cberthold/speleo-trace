import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../utils/geometry.dart';

/// Compass overlay: arrow toward [target] relative to device [headingDeg].
class IntersectionCompass extends StatelessWidget {
  const IntersectionCompass({
    super.key,
    required this.user,
    required this.headingDeg,
    required this.target,
  });

  final LatLng user;
  final double headingDeg;
  final LatLng target;

  @override
  Widget build(BuildContext context) {
    final bearing = bearingDegrees(user, target);
    final relative = ((bearing - headingDeg + 540) % 360) - 180;
    final dist = distanceMeters(user, target);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 112,
              height: 112,
              child: CustomPaint(
                painter: _CompassPainter(relativeDeg: relative),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${dist.toStringAsFixed(0)} m',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${relative >= 0 ? '+' : ''}${relative.toStringAsFixed(0)}°',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.relativeDeg});

  final double relativeDeg;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2 - 4;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black38;
    canvas.drawCircle(c, r, ring);

    final nPaint = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    nPaint.paint(canvas, Offset(c.dx - nPaint.width / 2, c.dy - r + 2));

    final rad = relativeDeg * math.pi / 180;
    final len = r - 10;
    final tip = Offset(
      c.dx + len * math.sin(rad),
      c.dy - len * math.cos(rad),
    );

    final arrow = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c, tip, arrow);

    final head = Paint()..color = Colors.deepOrange;
    canvas.drawCircle(tip, 5, head);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.relativeDeg != relativeDeg;
  }
}