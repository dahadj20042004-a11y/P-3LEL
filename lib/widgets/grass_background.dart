// lib/widgets/grass_background.dart
import 'dart:math';
import 'package:flutter/material.dart';

class GrassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deep base
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A1A0A),
          const Color(0xFF0F2310),
          const Color(0xFF142B14),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Mowed stripe pattern - alternating lighter/darker rows
    final stripe1 = Paint()
      ..color = const Color(0xFF0D1F0D)
      ..style = PaintingStyle.fill;
    final stripe2 = Paint()
      ..color = const Color(0xFF112511)
      ..style = PaintingStyle.fill;

    const stripeHeight = 60.0;
    int idx = 0;
    for (double y = 0; y < size.height; y += stripeHeight) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, stripeHeight),
        idx.isEven ? stripe1 : stripe2,
      );
      idx++;
    }

    // Subtle cutting lines (diagonal)
    final linePaint = Paint()
      ..color = const Color(0x0A4CAF50)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double x = -size.height; x < size.width + size.height; x += 40) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        linePaint,
      );
    }

    // Grass blade texture dots (random but seeded)
    final rng = Random(42);
    final bladePaint = Paint()
      ..color = const Color(0x0A6FCF6F)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 300; i++) {
      final bx = rng.nextDouble() * size.width;
      final by = rng.nextDouble() * size.height;
      final bh = rng.nextDouble() * 8 + 4;
      final bw = rng.nextDouble() * 1.5 + 0.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(bx, by), width: bw, height: bh),
          const Radius.circular(1),
        ),
        bladePaint,
      );
    }

    // Subtle vignette overlay
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withAlpha(140),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GrassBackground extends StatelessWidget {
  final Widget child;
  const GrassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: GrassBackgroundPainter()),
        child,
      ],
    );
  }
}
