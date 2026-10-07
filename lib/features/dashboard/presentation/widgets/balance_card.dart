import 'package:fylax_front/core/utils/formatters.dart';
import 'package:flutter/material.dart';

/// Tarjeta principal del dashboard: balance del mes + presupuesto restante
/// (F3.1 — "dinero disponible").
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.monthBalance,
    required this.availableBudget,
    super.key,
  });

  final double monthBalance;
  final double availableBudget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = monthBalance >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance del mes', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              Formatters.currency(monthBalance),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isPositive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Disponible', style: theme.textTheme.bodyMedium),
                Text(
                  Formatters.currency(availableBudget),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
