import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:fylax_front/features/goals/domain/entities/goal.dart';
import 'package:fylax_front/features/goals/domain/repositories/goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => sl<GoalsRepository>(),
);

/// Lista de propósitos del usuario con mutaciones que refrescan el estado.
final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>(
  (ref) => GoalsNotifier(ref.watch(goalsRepositoryProvider)),
);

class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  GoalsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final GoalsRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getGoals();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (goals) => state = AsyncValue.data(goals),
    );
  }

  Future<String?> create(Goal goal) async {
    final result = await _repository.createGoal(goal);
    return result.fold(
      (failure) => failure.message,
      (_) {
        load();
        return null;
      },
    );
  }

  Future<String?> addContribution(String id, double amount) async {
    final result = await _repository.addContribution(id, amount);
    return result.fold(
      (failure) => failure.message,
      (_) {
        load();
        return null;
      },
    );
  }

  Future<String?> delete(String id) async {
    final result = await _repository.deleteGoal(id);
    return result.fold(
      (failure) => failure.message,
      (_) {
        load();
        return null;
      },
    );
  }
}
