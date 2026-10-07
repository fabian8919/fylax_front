import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/utils/formatters.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/features/goals/domain/entities/goal.dart';
import 'package:fylax_front/features/goals/presentation/providers/goals_provider.dart';
import 'package:fylax_front/features/goals/presentation/widgets/goal_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Formulario de propósito nuevo: nombre, monto objetivo, ícono, color
/// y fecha límite opcional. Pensado para completarse en segundos.
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key});

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();
  String _icon = 'emergency';
  String _color = goalColorPalette.first;
  DateTime? _deadline;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo propósito'),
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
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: '¿Para qué estás ahorrando?',
                  hintText: 'Ej. Carro, viaje a Europa, saldar deuda…',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _target,
                decoration: const InputDecoration(
                  labelText: 'Monto objetivo',
                  hintText: '0',
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final value = num.tryParse(v ?? '');
                  if (value == null || value <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 22),
              Text(
                'Ícono',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              _IconPicker(
                selected: _icon,
                color: goalColor(_color),
                onSelected: (icon) => setState(() => _icon = icon),
              ),
              const SizedBox(height: 22),
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              _ColorPicker(
                selected: _color,
                onSelected: (color) => setState(() => _color = color),
              ),
              const SizedBox(height: 22),
              _DeadlineTile(
                deadline: _deadline,
                onPick: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().add(const Duration(days: 180)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
                onClear: _deadline == null
                    ? null
                    : () => setState(() => _deadline = null),
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
                      : const Icon(Icons.check_rounded),
                  label: const Text('Crear propósito'),
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final goal = Goal(
      id: '',
      userId: '',
      name: _name.text.trim(),
      targetAmount: double.parse(_target.text),
      savedAmount: 0,
      icon: _icon,
      color: _color,
      deadline: _deadline,
    );

    final error = await ref.read(goalsProvider.notifier).create(goal);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      context.pop();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }
}

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selected,
    required this.color,
    required this.onSelected,
  });

  final String selected;
  final Color color;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final entry in goalIconCatalog.entries)
          GestureDetector(
            onTap: () => onSelected(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: entry.key == selected
                    ? color.withValues(alpha: 0.18)
                    : AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: entry.key == selected
                      ? color
                      : Colors.white.withValues(alpha: 0.06),
                  width: entry.key == selected ? 1.4 : 1,
                ),
              ),
              child: Icon(
                entry.value,
                color: entry.key == selected
                    ? color
                    : AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
      ],
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        for (final hex in goalColorPalette)
          GestureDetector(
            onTap: () => onSelected(hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: goalColor(hex),
                border: Border.all(
                  color: hex == selected
                      ? Colors.white
                      : Colors.transparent,
                  width: 2.4,
                ),
                boxShadow: hex == selected
                    ? [
                        BoxShadow(
                          color: goalColor(hex).withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: hex == selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({
    required this.deadline,
    required this.onPick,
    this.onClear,
  });

  final DateTime? deadline;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.event_rounded,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha límite (opcional)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    Text(
                      deadline == null
                          ? 'Sin fecha'
                          : Formatters.date(deadline!),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onPressed: onClear,
                )
              else
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
