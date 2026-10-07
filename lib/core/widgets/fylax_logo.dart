import 'dart:math' as math;

import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Logo de Fylax: monograma "F" en degradado azul → verde cuya barra
/// central es un trazo ascendente — el pulso de crecimiento de la salud
/// financiera. Minimalista: una sola forma, dos colores, cero texto.
///
/// Es un vector (CustomPainter), por lo que se ve nítido a cualquier
/// tamaño: favicon, launcher, splash o marketing.
///
/// - [badge] = true: sobre squircle negro con borde sutil (login/splash).
/// - [badge] = false: solo el glifo con degradado (fondos oscuros).
class FylaxLogo extends StatelessWidget {
  const FylaxLogo({this.size = 92, this.badge = true, super.key});

  final double size;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FylaxLogoPainter(badge: badge)),
    );
  }
}

class _FylaxLogoPainter extends CustomPainter {
  const _FylaxLogoPainter({required this.badge});

  final bool badge;

  /// Trazo de la "F" en coordenadas normalizadas 0..1.
  /// Compartida con el generador de íconos (tools/gen_icons.py): si se
  /// ajusta aquí, ajustar allá también.
  static Path glyphPath(Size size) {
    double x(double v) => v * size.width;
    double y(double v) => v * size.height;

    final path = Path()
      // Vástago vertical.
      ..addRect(Rect.fromLTRB(x(0.34), y(0.26), x(0.46), y(0.74)))
      // Brazo superior.
      ..addRect(Rect.fromLTRB(x(0.34), y(0.26), x(0.74), y(0.38)));

    // Barra central como trazo ascendente (rotada −24°): el detalle
    // original que sugiere crecimiento.
    const cx = 0.57, cy = 0.52, halfW = 0.13, halfH = 0.055;
    const angle = -0.42; // radianes ≈ −24°
    final cos = math.cos(angle), sin = math.sin(angle);
    final dx = Offset(cos * halfW, sin * halfW);
    final dy = Offset(-sin * halfH, cos * halfH);
    const Offset c = Offset(cx, cy);
    Offset px(Offset o) => Offset(x(o.dx), y(o.dy));
    path.addPolygon(
      [
        px(c - dx - dy),
        px(c + dx - dy),
        px(c + dx + dy),
        px(c - dx + dy),
      ],
      true,
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;

    if (badge) {
      // Squircle negro con tinte azulado y borde apenas visible.
      final rect = Offset.zero & size;
      final rrect = RRect.fromRectAndRadius(
        rect.deflate(s * 0.02),
        Radius.circular(s * 0.28),
      );
      final bg = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101C28), Color(0xFF0A121B)],
        ).createShader(rect);
      canvas.drawRRect(rrect, bg);

      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.012
        ..color = Colors.white.withValues(alpha: 0.08);
      canvas.drawRRect(rrect, border);

      // Glow verde-azul detrás del glifo.
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.blue.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRRect(rrect, glow);
    }

    // Glifo "F" con el degradado de marca, calculado sobre el bounding
    // box del glifo para que el verde sí llegue a verse.
    final glyph = glyphPath(size);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.blueDeep, AppColors.blue, AppColors.green],
        stops: [0, 0.45, 1],
      ).createShader(glyph.getBounds());
    canvas.drawPath(glyph, paint);
  }

  @override
  bool shouldRepaint(_FylaxLogoPainter old) => old.badge != badge;
}
