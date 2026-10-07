import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:flutter/material.dart';

/// Tarjeta del feed (F3.2): comercio limpio, ícono de categoría,
/// monto y fecha. Indica visualmente el origen (manual vs. gmail_api).
class TransactionCard extends StatelessWidget {
  const TransactionCard({required this.transaction, super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            transaction.isManual ? Icons.edit_note : Icons.mark_email_read,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          transaction.merchantClean,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(Formatters.date(transaction.date)),
        trailing: Text(
          '- ${Formatters.currency(transaction.amount, currency: transaction.currency)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
