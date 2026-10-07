import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/widgets/animated_money.dart';
import 'package:flutter/material.dart';

/// Tarjeta héroe del dashboard (F3.1): balance del mes con degradado de
/// marca, monto que cuenta con animación y barra de presupuesto disponible.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    required this.monthBalance,
    required this.availableBudget,
    required this.totalSpent,
    super.key,
  });

  final double monthBalance;
  final double availableBudget;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetTotal = availableBudget + totalSpent;
    final spentRatio = budgetTotal > 0
        ? (totalSpent / budgetTotal).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text('Balance del mes', style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedMoney(
            amount: monthBalance,
            style: theme.textTheme.displayMedium?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 38,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Disponible', style: theme.textTheme.bodyMedium),
              AnimatedMoney(
                amount: availableBudget,
                duration: const Duration(milliseconds: 1400),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barra de presupuesto: se llena con animación al cargar.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: spentRatio),
              duration: const Duration(milliseconds: 1300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Stack(
                children: [
                  Container(height: 8, color: AppColors.surfaceBright),
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.blue, AppColors.green],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Has usado el ${(spentRatio * 100).toStringAsFixed(0)}% de tu presupuesto',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
