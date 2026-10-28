import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/features/alerts/domain/entities/plan_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlanAlertCard extends StatelessWidget {
  const PlanAlertCard({
    required this.alert,
    required this.onDismiss,
    super.key,
  });

  final PlanAlert alert;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = alert.isOffTrack ? AppColors.error : const Color(0xFFFFC857);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: Material(
        key: ValueKey(alert.id),
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go(AppRouter.goals),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    alert.isOffTrack
                        ? Icons.warning_amber_rounded
                        : Icons.notifications_active_rounded,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        alert.message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ver plan de acción',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  tooltip: 'Marcar como leída',
                  icon: const Icon(Icons.close_rounded, size: 19),
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
