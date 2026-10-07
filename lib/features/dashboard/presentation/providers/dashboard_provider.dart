import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:fylax_front/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:fylax_front/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:fylax_front/features/dashboard/domain/usecases/get_dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => sl<DashboardRepository>(),
);

final getDashboardSummaryProvider = Provider(
  (ref) => GetDashboardSummary(ref.watch(dashboardRepositoryProvider)),
);

/// F3.1 — provider asíncrono; la pantalla principal consume estados
/// data/loading/error directamente (carga objetivo < 2 s — PRD §F3.1).
final dashboardSummaryProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final result = await ref.read(getDashboardSummaryProvider).call();
  return result.fold(
    (failure) => throw failure,
    (summary) => summary,
  );
});

/// Pull-to-refresh del dashboard.
final dashboardRefreshProvider = FutureProvider<void>((ref) async {
  ref.invalidate(dashboardSummaryProvider);
  final result = await ref.read(getDashboardSummaryProvider).call();
  // Propaga el error para que la UI lo capture.
  result.fold(
    (failure) => throw failure,
    (_) => null,
  );
});
