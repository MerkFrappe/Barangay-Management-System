import 'package:flutter/material.dart';

/// Lightweight Google-style G mark drawn locally, so no image asset or
/// additional package is needed for the Google authentication buttons.
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _GoogleLogoPainter()),
  );
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2.25;
    final stroke = size.shortestSide / 5.2;
    void arc(Color color, double start, double sweep) => canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );

    arc(const Color(0xFF4285F4), -0.72, 1.45);
    arc(const Color(0xFF34A853), 0.73, 1.15);
    arc(const Color(0xFFFBBC05), 1.88, 1.1);
    arc(const Color(0xFFEA4335), 2.98, 1.58);
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width - stroke / 2, center.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
