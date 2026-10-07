import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/utils/category_icons.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/features/categories/domain/entities/category.dart';
import 'package:fylax_front/features/categories/presentation/providers/categories_provider.dart';
import 'package:fylax_front/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// F3.3 — creación/edición manual: gastos en efectivo y corrección de
/// comercio o categoría de cualquier transacción. Objetivo: ≤ 3 toques
/// para registrar un gasto manual.
///
/// Layout moderno: monto protagonista con vista previa formateada,
/// categorías como chips seleccionables con animación y fecha compacta.
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
  bool _saving = false;

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
        title: Text(isEditing ? 'Editar movimiento' : 'Gasto en efectivo'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: staggered(
            [
              const SizedBox(height: 8),
              // Monto protagonista con preview formateado en vivo.
              TextFormField(
                controller: _amount,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 34,
                      color: AppColors.green,
                    ),
                decoration: InputDecoration(
                  labelText: 'Monto',
                  hintText: '0',
                  prefixText: '\$ ',
                  prefixStyle:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textMuted,
                          ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  final value = num.tryParse(v ?? '');
                  if (value == null || value <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              if (_amount.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    Formatters.currency(num.tryParse(_amount.text) ?? 0),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _merchant,
                decoration: const InputDecoration(
                  labelText: 'Comercio',
                  prefixIcon: Icon(Icons.store_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 22),
              Text(
                'Categoría',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) =>
                    const Text('No se pudieron cargar categorías'),
                data: (categories) => _CategoryChips(
                  categories: categories,
                  selectedId: _categoryId,
                  onSelected: (id) => setState(() => _categoryId = id),
                ),
              ),
              const SizedBox(height: 22),
              _DateTile(
                date: _date,
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
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isEditing ? Icons.check_rounded : Icons.add_rounded,
                        ),
                  label: Text(isEditing ? 'Guardar cambios' : 'Agregar gasto'),
                ),
              ),
            ],
            step: const Duration(milliseconds: 70),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final tx = widget.existing;
    final newTx = Transaction(
      id: tx?.id ?? '',
      userId: tx?.userId ?? '',
      categoryId: _categoryId!,
      amount: double.parse(_amount.text),
      currency: 'COP',
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
    setState(() => _saving = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {
        ref.invalidate(transactionsProvider);
        ref.invalidate(dashboardSummaryProvider);
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

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final c in categories)
          _CategoryChip(
            category: c,
            selected: c.id == selectedId,
            onTap: () => onSelected(c.id),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category.color);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color
                : Colors.white.withValues(alpha: 0.06),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIcon(category.icon),
              size: 16,
              color: selected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    Text(
                      Formatters.date(date),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
