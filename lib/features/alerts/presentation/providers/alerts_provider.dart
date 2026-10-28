import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:fylax_front/features/alerts/domain/entities/plan_alert.dart';
import 'package:fylax_front/features/alerts/domain/repositories/alerts_repository.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>(
  (ref) => sl<AlertsRepository>(),
);

final alertsProvider =
    StateNotifierProvider<AlertsNotifier, AsyncValue<List<PlanAlert>>>(
  (ref) => AlertsNotifier(ref.watch(alertsRepositoryProvider)),
);

class AlertsNotifier extends StateNotifier<AsyncValue<List<PlanAlert>>> {
  AlertsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final AlertsRepository _repository;

  Future<void> load() async {
    final result = await _repository.getUnreadAlerts();
    result.fold(
      (_) => state = const AsyncValue.data([]),
      (alerts) => state = AsyncValue.data(alerts),
    );
  }

  Future<void> markAsRead(String id) async {
    final current = state.valueOrNull ?? const <PlanAlert>[];
    state = AsyncValue.data(
      current.where((alert) => alert.id != id).toList(growable: false),
    );
    await _repository.markAsRead(id);
  }
}
