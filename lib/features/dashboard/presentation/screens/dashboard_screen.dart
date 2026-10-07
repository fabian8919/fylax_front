import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fylax_front/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:fylax_front/features/dashboard/presentation/widgets/category_distribution.dart';
import 'package:fylax_front/features/sync/presentation/widgets/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla principal (F3.1): balance del mes, dinero disponible y
/// distribución por categoría. Carga objetivo < 2 segundos.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fylax'),
        actions: const [
          // Estado visible de la sincronización de correo (F3.4).
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SyncStatusIndicator(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(dashboardSummaryProvider),
          ),
          data: (summary) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              BalanceCard(
                monthBalance: summary.monthBalance,
                availableBudget: summary.availableBudget,
              ),
              const SizedBox(height: 24),
              Text(
                'Gasto por categoría',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              CategoryDistribution(
                spending: summary.spendingByCategory,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRouter.transactionsFeed),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Ver todas las transacciones'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // F3.3 — agregar gasto manual en ≤ 3 toques.
        onPressed: () => context.push(AppRouter.transactionForm),
        icon: const Icon(Icons.add),
        label: const Text('Gasto'),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.cloud_off,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 12),
        Text(
          'No pudimos cargar tu resumen',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}
