import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/utils/category_icons.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/core/widgets/donut_chart.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:flutter/material.dart';

/// Distribución del gasto por categoría (F3.1): dona animada con leyenda
/// de las categorías principales y su participación porcentual.
class CategoryDistribution extends StatelessWidget {
  const CategoryDistribution({required this.spending, super.key});

  final List<CategorySpending> spending;

  @override
  Widget build(BuildContext context) {
    if (spending.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Aún no hay gastos este mes. Cuando lleguen recibos a tu '
            'correo, aparecerán aquí automáticamente.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final total = spending.fold<double>(0, (sum, e) => sum + e.amount);
    final top = spending.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DonutChart(spending: spending),
            const SizedBox(height: 20),
            for (var i = 0; i < top.length; i++)
              _LegendRow(
                item: top[i],
                share: total > 0 ? top[i].amount / total : 0,
              ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item, required this.share});

  final CategorySpending item;
  final double share;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = categoryColor(item.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(categoryIcon(item.icon), color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: share),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      color: color,
                      backgroundColor: AppColors.surfaceBright,
                      minHeight: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(item.amount),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(share * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
