import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:flutter/material.dart';

/// Distribución del gasto por categoría (F3.1).
///
/// Por simplicidad del MVP: barras proporcionales por categoría.
class CategoryDistribution extends StatelessWidget {
  const CategoryDistribution({required this.spending, super.key});

  final List<CategorySpending> spending;

  @override
  Widget build(BuildContext context) {
    if (spending.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aún no hay gastos este mes. Cuando lleguen recibos a tu '
            'correo, aparecerán aquí automáticamente.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final total = spending.fold<double>(0, (sum, e) => sum + e.amount);
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          for (final item in spending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.categoryName),
                      Text(
                        Formatters.currency(item.amount),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: total > 0 ? item.amount / total : 0,
                    color: _parseColor(item.color),
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static Color _parseColor(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    return value == null ? Colors.grey : Color(0xFF000000 + value);
  }
}
