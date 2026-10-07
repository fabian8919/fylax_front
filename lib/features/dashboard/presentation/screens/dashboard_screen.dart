import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/features/auth/presentation/providers/auth_provider.dart';
import 'package:fylax_front/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fylax_front/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:fylax_front/features/dashboard/presentation/widgets/category_distribution.dart';
import 'package:fylax_front/features/sync/presentation/providers/sync_provider.dart';
import 'package:fylax_front/features/sync/presentation/widgets/sync_status_indicator.dart';
import 'package:fylax_front/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:fylax_front/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla principal (F3.1): balance del mes, dinero disponible y
/// distribución por categoría. Carga objetivo < 2 segundos.
///
/// Composición escalonada: cada bloque entra con FadeInSlide y los
/// montos cuentan con animación (AnimatedMoney).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final authState = ref.watch(authNotifierProvider);
    final firstName = switch (authState) {
      AuthAuthenticated(:final user) => user.name.split(' ').first,
      _ => null,
    };

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.green,
        backgroundColor: AppColors.surfaceHigh,
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          ref.invalidate(syncStatusProvider);
        },
        child: summaryAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          ),
          error: (error, _) => _ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(dashboardSummaryProvider),
          ),
          data: (summary) => ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              FadeInSlide(
                child: _Header(firstName: firstName),
              ),
              const SizedBox(height: 20),
              FadeInSlide(
                delay: const Duration(milliseconds: 100),
                child: BalanceCard(
                  monthBalance: summary.monthBalance,
                  availableBudget: summary.availableBudget,
                  totalSpent: summary.spendingByCategory
                      .fold<double>(0, (s, e) => s + e.amount),
                ),
              ),
              const SizedBox(height: 28),
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Gasto por categoría',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 14),
              FadeInSlide(
                delay: const Duration(milliseconds: 280),
                child: CategoryDistribution(spending: summary.spendingByCategory),
              ),
              const SizedBox(height: 28),
              FadeInSlide(
                delay: const Duration(milliseconds: 360),
                child: _RecentHeader(
                  onSeeAll: () => context.go(AppRouter.transactionsFeed),
                ),
              ),
              const SizedBox(height: 6),
              const FadeInSlide(
                delay: Duration(milliseconds: 420),
                child: _RecentTransactions(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.firstName});

  final String? firstName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  firstName == null ? 'Hola' : 'Hola, $firstName',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Tu panorama financiero de hoy',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Estado visible de la sincronización de correo (F3.4).
          const SyncStatusIndicator(),
        ],
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  const _RecentHeader({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Movimientos recientes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'Ver todos',
            style: TextStyle(color: AppColors.green),
          ),
        ),
      ],
    );
  }
}

/// Vista previa: los 4 movimientos más recientes dentro del dashboard.
class _RecentTransactions extends ConsumerWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTx = ref.watch(transactionsProvider);
    final items = asyncTx.valueOrNull ?? const [];
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.green,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final tx in items.take(4)) TransactionCard(transaction: tx),
      ],
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
        const SizedBox(height: 140),
        const Icon(
          Icons.cloud_off_rounded,
          size: 48,
          color: AppColors.error,
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
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}
