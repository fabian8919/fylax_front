import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:fylax_front/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// F3.2 — feed de transacciones: lista paginada agrupada por día,
/// scroll infinito fluido y pull-to-refresh. Entrada escalonada de las
/// primeras tarjetas.
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
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      ref.read(transactionsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncTx = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      body: RefreshIndicator(
        color: AppColors.green,
        backgroundColor: AppColors.surfaceHigh,
        onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
        child: asyncTx.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 140),
              const Icon(Icons.error_outline_rounded, size: 48),
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
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ),
            ],
          ),
          data: (transactions) => transactions.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 140),
                    Text(
                      'Aún no tienes transacciones.\n'
                      'Conecta tu correo y deja que Fylax trabaje solo.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : _GroupedFeed(scroll: _scroll, transactions: transactions),
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

/// Lista agrupada por día con encabezados "Hoy" / "Ayer" / fecha.
class _GroupedFeed extends StatelessWidget {
  const _GroupedFeed({required this.scroll, required this.transactions});

  final ScrollController scroll;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    String? lastKey;
    var animated = 0; // solo las primeras tarjetas entran animadas

    for (final tx in transactions) {
      final key = _dayKey(tx.date);
      if (key != lastKey) {
        lastKey = key;
        children.add(_DayHeader(label: key));
      }
      final card = TransactionCard(transaction: tx);
      if (animated < 8) {
        children.add(
          FadeInSlide(
            delay: Duration(milliseconds: 50 * animated),
            offset: 16,
            child: card,
          ),
        );
        animated++;
      } else {
        children.add(card);
      }
    }

    return ListView(
      controller: scroll,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 120),
      children: children,
    );
  }

  static String _dayKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return DateFormat('d MMM yyyy', 'es').format(date);
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}
