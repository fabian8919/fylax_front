import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/domain/repositories/transactions_repository.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => throw UnimplementedError('Registrar TransactionsRepository en DI'),
);

/// F3.2 — feed paginado con scroll infinito y pull-to-refresh.
///
/// StateNotifier + paginación manual: cada página se anexa a la lista.
class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    loadFirstPage();
  }

  final TransactionsRepository _repository;
  int _page = 1;
  bool hasMore = true;

  Future<void> loadFirstPage() async {
    _page = 1;
    state = const AsyncValue.loading();
    final result = await _repository.getTransactions(page: 1);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (items) {
        hasMore = items.length >= 20;
        state = AsyncValue.data(items);
      },
    );
  }

  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !hasMore) return;
    final result = await _repository.getTransactions(page: _page + 1);
    await result.fold(
      (failure) async =>
          state = AsyncValue.error(failure, StackTrace.current),
      (items) async {
        _page += 1;
        hasMore = items.isNotEmpty;
        state = AsyncValue.data([...current, ...items]);
      },
    );
  }

  Future<void> refresh() => loadFirstPage();
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>(
  (ref) => TransactionsNotifier(ref.watch(transactionsRepositoryProvider)),
);
