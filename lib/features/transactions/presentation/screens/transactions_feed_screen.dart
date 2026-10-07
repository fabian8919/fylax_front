import 'package:fylax_front/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:fylax_front/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// F3.2 — feed de transacciones: lista paginada, scroll infinito fluido
/// y pull-to-refresh. Cada tarjeta muestra comercio limpio, ícono de
/// categoría, monto y fecha.
class TransactionsFeedScreen extends ConsumerStatefulWidget {
  const TransactionsFeedScreen({super.key});

  @override
  ConsumerState<TransactionsFeedScreen> createState() =>
      _TransactionsFeedScreenState();
}

class _TransactionsFeedScreenState
    extends ConsumerState<TransactionsFeedScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      ref.read(transactionsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncTx = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transacciones')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
        child: asyncTx.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              const Text(
                'No pudimos cargar tus transacciones',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Center(
                child: FilledButton.icon(
                  onPressed: () =>
                      ref.read(transactionsProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ),
            ],
          ),
          data: (transactions) => transactions.isEmpty
              ? const ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: 120),
                    Text(
                      'Aún no tienes transacciones.\n'
                      'Conecta tu correo y deja que Fylax trabaje solo.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.builder(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, i) =>
                      TransactionCard(transaction: transactions[i]),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }
}
