import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:fylax_front/features/alerts/presentation/providers/alerts_provider.dart';
import 'package:fylax_front/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fylax_front/features/goals/presentation/providers/goals_provider.dart';
import 'package:fylax_front/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Actualización en tiempo real (Supabase Realtime — postgres_changes).
///
/// Mientras la app está abierta, un INSERT en `transactions` (ingesta de
/// Gmail o gasto manual) invalida los providers afectados y la UI se
/// refresca sola, sin pull-to-refresh. RLS (`tx_select_own`) garantiza
/// que cada usuario solo recibe sus propios movimientos.
///
/// Es un Provider keep-alive (sin autoDispose): vive toda la sesión y se
/// activa al entrar al shell principal (ver DashboardScreen).
final transactionsRealtimeProvider = Provider<void>((ref) {
  // Modo demo (sin Supabase configurado): no hay canal.
  if (!AppConstants.isBackendConfigured) return;

  final client = Supabase.instance.client;
  final channel = client
      .channel('fylax-transactions')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'transactions',
        callback: (_) {
          ref
            ..invalidate(dashboardSummaryProvider)
            ..invalidate(transactionsProvider)
            ..invalidate(goalsProvider)
            ..invalidate(alertsProvider);
        },
      )
      .subscribe();

  ref.onDispose(() => client.removeChannel(channel));
});
