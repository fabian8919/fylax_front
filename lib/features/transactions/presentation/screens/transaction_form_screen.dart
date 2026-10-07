import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/core/constants/app_constants.dart';
import 'package:fylax_front/features/categories/presentation/providers/categories_provider.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:go_router/go_router.dart';

/// F3.3 — creación/edición manual: gastos en efectivo y corrección de
/// comercio o categoría de cualquier transacción. Objetivo: ≤ 3 toques
/// para registrar un gasto manual.
class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.existing});

  /// Si llega una transacción existente, el formulario opera en modo
  /// edición (PATCH /transactions/{id}).
  final Transaction? existing;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _merchant;
  late final TextEditingController _amount;
  String? _categoryId;
  late DateTime _date;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.existing;
    _merchant = TextEditingController(text: tx?.merchantClean ?? '');
    _amount = TextEditingController(
      text: tx == null ? '' : tx.amount.toStringAsFixed(0),
    );
    _categoryId = tx?.categoryId;
    _date = tx?.date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar gasto' : 'Gasto en efectivo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _merchant,
              decoration: const InputDecoration(
                labelText: 'Comercio',
                prefixIcon: Icon(Icons.store),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixIcon: Icon(Icons.payments),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final value = num.tryParse(v ?? '');
                if (value == null || value <= 0) return 'Monto inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('No se pudieron cargar categorías'),
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  for (final c in categories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => _categoryId = v,
                validator: (v) => v == null ? 'Selecciona una categoría' : null,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: Text('Fecha'),
              subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: Icon(isEditing ? Icons.save : Icons.add),
              label: Text(isEditing ? 'Guardar cambios' : 'Agregar gasto'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final tx = widget.existing;
    final newTx = Transaction(
      id: tx?.id ?? '',
      userId: tx?.userId ?? '',
      categoryId: _categoryId!,
      amount: double.parse(_amount.text),
      currency: AppConstants.defaultCurrency,
      date: _date,
      merchantClean: _merchant.text.trim(),
      // Los manuales nunca llevan sourceRefId: la idempotencia
      // UNIQUE (user_id, source_ref_id) solo aplica a gmail_api (PRD §F2.6).
      source: tx?.source ?? TransactionSource.manual,
      sourceRefId: tx?.sourceRefId,
    );

    final repository = ref.read(transactionsRepositoryProvider);
    final result = isEditing
        ? await repository.updateTransaction(newTx)
        : await repository.createTransaction(newTx);

    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(transactionsProvider);
        context.pop();
      },
    );
  }

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }
}
