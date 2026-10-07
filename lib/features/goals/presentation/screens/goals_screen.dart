import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/core/widgets/animated_money.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/features/goals/domain/entities/goal.dart';
import 'package:fylax_front/features/goals/presentation/providers/goals_provider.dart';
import 'package:fylax_front/features/goals/presentation/widgets/goal_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de propósitos de ahorro: la razón de fondo para cuidar la
/// salud financiera (carro, moto, viaje, saldar deudas…).
///
/// Cada tarjeta muestra anillo de progreso animado, aportes rápidos y
/// acción de eliminar. El botón degradado crea un propósito nuevo.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis propósitos')),
      body: goalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.green),
        ),
        error: (_, __) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.read(goalsProvider.notifier).load(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
        data: (goals) => RefreshIndicator(
          color: AppColors.green,
          backgroundColor: AppColors.surfaceHigh,
          onRefresh: () => ref.read(goalsProvider.notifier).load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              if (goals.isEmpty)
                const _EmptyGoals()
              else ...[
                for (var i = 0; i < goals.length; i++)
                  FadeInSlide(
                    delay: Duration(milliseconds: 90 * i),
                    child: GoalCard(goal: goals[i]),
                  ),
              ],
              const SizedBox(height: 16),
              FadeInSlide(
                delay: Duration(milliseconds: 90 * goals.length + 80),
                child: _NewGoalButton(
                  onPressed: () => context.push(AppRouter.goalForm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientSoft,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.savings_rounded,
              size: 44,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Define tu propósito',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Ahorrar es más fácil cuando sabes para qué:\n'
            'una moto, un viaje, saldar una deuda…',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de propósito con anillo de progreso animado.
class GoalCard extends ConsumerWidget {
  const GoalCard({required this.goal, super.key});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = goalColor(goal.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _ProgressRing(goal: goal, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _confirmDelete(context, ref),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedMoney(
                    amount: goal.savedAmount,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'de ${Formatters.currency(goal.targetAmount)}'
                    '${goal.deadline != null ? ' · para ${Formatters.date(goal.deadline!)}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (goal.isCompleted)
                    const _CompletedBadge()
                  else
                    GestureDetector(
                      onTap: () => _showContributionSheet(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, size: 15, color: color),
                            const SizedBox(width: 4),
                            Text(
                              'Agregar aporte',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Eliminar propósito'),
        content: Text('¿Eliminar "${goal.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(goalsProvider.notifier).delete(goal.id);
    }
  }

  void _showContributionSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Aporte a "${goal.name}"',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Te faltan ${Formatters.currency(goal.remaining)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monto del aporte',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () async {
                final amount = num.tryParse(controller.text);
                if (amount == null || amount <= 0) return;
                Navigator.pop(context);
                final error = await ref
                    .read(goalsProvider.notifier)
                    .addContribution(goal.id, amount.toDouble());
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              },
              child: const Text('Guardar aporte'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.goal, required this.color});

  final Goal goal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 86,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: goal.progress),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: AppColors.surfaceBright,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(goalIcon(goal.icon), color: color, size: 22),
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 15, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '¡Propósito cumplido!',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewGoalButton extends StatelessWidget {
  const _NewGoalButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo propósito'),
      ),
    );
  }
}
