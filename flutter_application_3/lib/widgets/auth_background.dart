import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColores.fondo,
        gradient: RadialGradient(
          center: Alignment(-0.8, -0.9),
          radius: 1.4,
          colors: [
            Color(0xFF233010), // brillo lima muy tenue
            AppColores.fondo,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _Lineas())),
          child,
        ],
      ),
    );
  }
}

/// Líneas diagonales sutiles de fondo.
class _Lineas extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = AppColores.borde.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    const separacion = 42.0;
    for (double x = -size.height; x < size.width; x += separacion) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), pincel);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
