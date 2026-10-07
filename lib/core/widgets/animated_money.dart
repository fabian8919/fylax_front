import 'package:fylax_front/core/utils/formatters.dart';
import 'package:flutter/material.dart';

/// Contador animado de dinero: el valor "cuenta" desde cero (o desde el
/// valor anterior) hasta el monto objetivo con easing suave.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({
    required this.amount,
    this.currency = 'COP',
    this.duration = const Duration(milliseconds: 1200),
    this.style,
    this.prefix = '',
    super.key,
  });

  final double amount;
  final String currency;
  final Duration duration;
  final TextStyle? style;

  /// Prefijo adicional al símbolo de moneda (ej. '-' para gastos).
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(
        '$prefix${Formatters.currency(value, currency: currency)}',
        style: style,
      ),
    );
  }
}
