import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/features/auth/presentation/providers/auth_provider.dart';
import 'package:fylax_front/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fylax_front/features/goals/presentation/providers/goals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Configura el ingreso y el presupuesto que alimentan todos los planes.
/// Se muestra al terminar el onboarding y también desde Perfil.
class FinancialSetupScreen extends ConsumerStatefulWidget {
  const FinancialSetupScreen({this.initialSetup = false, super.key});

  final bool initialSetup;

  @override
  ConsumerState<FinancialSetupScreen> createState() =>
      _FinancialSetupScreenState();
}

class _FinancialSetupScreenState extends ConsumerState<FinancialSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _income = TextEditingController();
  final _budget = TextEditingController();
  String _frequency = 'monthly';
  bool _budgetTouched = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authNotifierProvider);
    final user = switch (auth) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };
    _frequency = user?.incomeFrequency ?? 'monthly';
    if ((user?.incomeAmount ?? 0) > 0) {
      _income.text = user!.incomeAmount.toStringAsFixed(0);
    }
    if ((user?.monthlyBudget ?? 0) > 0) {
      _budget.text = user!.monthlyBudget.toStringAsFixed(0);
      _budgetTouched = true;
    }
    _income.addListener(_suggestBudget);
  }

  double get _monthlyIncome {
    final amount = double.tryParse(_income.text) ?? 0;
    return amount * (_frequency == 'biweekly' ? 2 : 1);
  }

  void _suggestBudget() {
    if (!_budgetTouched) {
      _budget.text = (_monthlyIncome * 0.8).round().toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = double.tryParse(_budget.text) ?? 0;
    final savings =
        (_monthlyIncome - budget).clamp(0, _monthlyIncome).toDouble();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.initialSetup,
        title: const Text('Ingresos y presupuesto'),
        actions: [
          if (widget.initialSetup)
            TextButton(
              onPressed: () => context.go(AppRouter.dashboard),
              child: const Text('Después'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: staggered(
            [
              Text(
                'Tu punto de partida',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Con tu ingreso y tus gastos definimos cuánto puedes destinar '
                'a cada propósito y te damos un plan concreto.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                '¿Cada cuánto recibes tu nómina?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'monthly',
                      label: Text('Mensual'),
                      icon: Icon(Icons.calendar_month_rounded),
                    ),
                    ButtonSegment(
                      value: 'biweekly',
                      label: Text('Quincenal'),
                      icon: Icon(Icons.date_range_rounded),
                    ),
                  ],
                  selected: {_frequency},
                  onSelectionChanged: (value) {
                    _frequency = value.first;
                    _suggestBudget();
                  },
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _income,
                decoration: InputDecoration(
                  labelText: _frequency == 'biweekly'
                      ? 'Ingreso de cada quincena'
                      : 'Ingreso de cada mes',
                  hintText: 'Ej. 2500000',
                  prefixText: '\$ ',
                  prefixIcon: const Icon(Icons.payments_rounded),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  final amount = double.tryParse(value ?? '') ?? 0;
                  return amount > 0
                      ? null
                      : 'Escribe un ingreso mayor que cero';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budget,
                decoration: const InputDecoration(
                  labelText: 'Presupuesto mensual de gastos',
                  helperText: 'Incluye necesidades y gastos flexibles',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  _budgetTouched = true;
                  setState(() {});
                },
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  return amount == null || amount < 0
                      ? 'Escribe un presupuesto válido'
                      : null;
                },
              ),
              const SizedBox(height: 18),
              _SummaryCard(
                monthlyIncome: _monthlyIncome,
                savings: savings,
                overBudget: budget > _monthlyIncome,
              ),
              const SizedBox(height: 18),
              const _DistributionCard(),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    widget.initialSetup
                        ? 'Crear mi plan financiero'
                        : 'Guardar y actualizar mis planes',
                  ),
                ),
              ),
            ],
            step: const Duration(milliseconds: 65),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final error =
        await ref.read(authNotifierProvider.notifier).updateFinancialProfile(
              incomeAmount: double.parse(_income.text),
              incomeFrequency: _frequency,
              monthlyBudget: double.parse(_budget.text),
            );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(goalsProvider);
    if (widget.initialSetup) {
      context.go(AppRouter.dashboard);
    } else {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planes actualizados con tu nueva configuración'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _income.removeListener(_suggestBudget);
    _income.dispose();
    _budget.dispose();
    super.dispose();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.monthlyIncome,
    required this.savings,
    required this.overBudget,
  });

  final double monthlyIncome;
  final double savings;
  final bool overBudget;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: overBudget
              ? AppColors.error.withValues(alpha: 0.45)
              : AppColors.green.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'Ingreso mensual',
              amount: monthlyIncome,
              color: AppColors.textPrimary,
            ),
          ),
          Container(width: 1, height: 46, color: Colors.white12),
          Expanded(
            child: _Metric(
              label: 'Disponible para propósitos',
              amount: savings,
              color: overBudget ? AppColors.error : AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        FittedBox(
          child: Text(
            Formatters.currency(amount),
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución sugerida',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(flex: 50, child: ColoredBox(color: AppColors.blue)),
                  SizedBox(width: 3),
                  Expanded(
                    flex: 30,
                    child: ColoredBox(color: AppColors.greenSoft),
                  ),
                  SizedBox(width: 3),
                  Expanded(flex: 20, child: ColoredBox(color: AppColors.green)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('50 % necesidades · 30 % gustos · 20 % propósitos'),
          const SizedBox(height: 4),
          Text(
            'Es una guía inicial: puedes ajustar tu presupuesto a tu realidad.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
