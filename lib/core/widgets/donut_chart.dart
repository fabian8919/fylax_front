import 'dart:math' as math;

import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:flutter/material.dart';

/// Gráfico de dona animado para la distribución del gasto por categoría
/// (F3.1). Los arcos barren de 0 a su proporción con un easing fluido y
/// el centro muestra el gasto total.
class DonutChart extends StatefulWidget {
  const DonutChart({
    required this.spending,
    this.size = 190,
    this.strokeWidth = 22,
    super.key,
  });

  final List<CategorySpending> spending;
  final double size;
  final double strokeWidth;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _sweep = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.spending.fold<double>(0, (s, e) => s + e.amount);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _sweep,
        builder: (context, child) => CustomPaint(
          painter: _DonutPainter(
            spending: widget.spending,
            progress: _sweep.value,
            strokeWidth: widget.strokeWidth,
            trackColor: AppColors.surfaceBright,
          ),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gasto del mes',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              AnimatedBuilder(
                animation: _sweep,
                builder: (context, _) => Text(
                  _compact(total * _sweep.value),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _compact(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(0)}K';
    return '\$${value.toStringAsFixed(0)}';
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.spending,
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
  });

  final List<CategorySpending> spending;
  final double progress;
  final double strokeWidth;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final total = spending.fold<double>(0, (s, e) => s + e.amount);
    if (total <= 0) return;

    var start = -math.pi / 2;
    const gap = 0.035; // separación entre segmentos, look moderno
    for (final item in spending) {
      final sweep = (item.amount / total) * 2 * math.pi * progress;
      if (sweep <= 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = _parseColor(item.color);
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(0, sweep - gap),
        false,
        paint,
      );
      start += item.amount / total * 2 * math.pi * progress;
    }
  }

  static Color _parseColor(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    return value == null ? AppColors.blue : Color(0xFF000000 + value);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.spending != spending;
}
