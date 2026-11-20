import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Imagen de portada. Si hay URL la muestra; si no hay (o falla),
/// dibuja una portada con los colores del tema y un ícono según el tema.
class Portada extends StatelessWidget {
  final String? url;
  final String texto; // título o etiquetas: sirve para elegir el ícono
  final int semilla; // cambia el ángulo y el color del brillo
  final double? altura;

  const Portada({
    super.key,
    this.url,
    required this.texto,
    required this.semilla,
    this.altura,
  });

  static IconData iconoPara(String texto) {
    final t = texto.toLowerCase();
    if (t.contains('audífono') || t.contains('audifono') || t.contains('sonido')) {
      return Icons.headset_mic;
    }
    if (t.contains('teclado')) return Icons.keyboard;
    if (t.contains('mouse')) return Icons.mouse;
    if (t.contains('silla')) return Icons.event_seat;
    if (t.contains('tarjeta') || t.contains('regalo')) return Icons.card_giftcard;
    if (t.contains('nube') || t.contains('streaming')) return Icons.cloud;
    if (t.contains('indie')) return Icons.auto_awesome;
    if (t.contains('setup') || t.contains('pc')) return Icons.desktop_windows;
    if (t.contains('shooter') || t.contains('puntería') || t.contains('punteria')) {
      return Icons.gps_fixed;
    }
    if (t.contains('retro') || t.contains('arcade')) return Icons.videogame_asset;
    return Icons.sports_esports;
  }

  @override
  Widget build(BuildContext context) {
    final generada = _PortadaGenerada(texto: texto, semilla: semilla);

    final contenido = (url == null || url!.isEmpty)
        ? generada
         : Image.network(
            url!,
            fit: BoxFit.cover,
            width: double.infinity,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (context, error, stack) => generada,
          );

    return SizedBox(
      height: altura,
      width: double.infinity,
      child: contenido,
    );
  }
}

class _PortadaGenerada extends StatelessWidget {
  final String texto;
  final int semilla;

  const _PortadaGenerada({required this.texto, required this.semilla});

  @override
  Widget build(BuildContext context) {
    final brillo = semilla.isEven ? AppColores.acento : AppColores.secundario;
    final alineacion = [
      Alignment.topRight,
      Alignment.bottomRight,
      Alignment.topLeft,
      Alignment.bottomLeft,
    ][semilla.abs() % 4];

    return Container(
      decoration: BoxDecoration(
        color: AppColores.superficieAlta,
        gradient: RadialGradient(
          center: alineacion,
          radius: 1.3,
          colors: [
            brillo.withValues(alpha: 0.28),
            AppColores.superficieAlta,
            AppColores.fondo,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _Cuadricula(brillo)),
          ),
          Center(
            child: Icon(
              Portada.iconoPara(texto),
              size: 64,
              color: brillo.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Puntos tipo "pixel" de fondo.
class _Cuadricula extends CustomPainter {
  final Color color;

  _Cuadricula(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()..color = color.withValues(alpha: 0.10);
    const paso = 18.0;
    for (double x = paso / 2; x < size.width; x += paso) {
      for (double y = paso / 2; y < size.height; y += paso) {
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 2, height: 2), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Cuadricula oldDelegate) => oldDelegate.color != color;
}
