import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Onboarding de 3 pantallas (F1.4 — completable en menos de 5 minutos):
/// 1. Propuesta de valor (captura 100% automática).
/// 2. Permiso de correo (por qué gmail.readonly y qué NO hacemos).
/// 3. Primera sincronización (estado de "Sincronizando correos…").
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = [
    _OnboardingStep(
      icon: Icons.auto_awesome_rounded,
      title: 'Cero digitación',
      body: 'Fylax detecta tus gastos automáticamente desde las alertas '
          'bancarias y recibos que llegan a tu correo. Tú nunca escribes '
          'una transacción.',
    ),
    _OnboardingStep(
      icon: Icons.mark_email_read_rounded,
      title: 'Tu correo, solo lectura',
      body: 'Pedimos acceso de solo lectura (gmail.readonly). Nunca '
          'enviamos, borramos ni modificamos correos; solo leemos recibos '
          'para registrar tus gastos.',
    ),
    _OnboardingStep(
      icon: Icons.sync_rounded,
      title: 'Primera sincronización',
      body: 'Vamos a revisar los últimos correos de tus bancos y comercios '
          'para mostrarte tu panorama financiero. Esto puede tomar '
          'unos minutos.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRouter.dashboard),
                child: const Text(
                  'Omitir',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _StepView(step: _steps[i]),
              ),
            ),
            const SizedBox(height: 12),
            // Indicador de página con pill animado.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _steps.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: i == _page ? 28 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: i == _page ? AppColors.brandGradient : null,
                      color: i == _page ? null : AppColors.surfaceBright,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SizedBox(
                  key: ValueKey(isLast),
                  width: double.infinity,
                  child: isLast
                      ? _GradientButton(
                          label: 'Empezar',
                          onPressed: () => context.go(AppRouter.dashboard),
                        )
                      : FilledButton(
                          onPressed: () => _controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          ),
                          child: const Text('Siguiente'),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientSoft,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: AppColors.blue.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(step.icon, size: 52, color: AppColors.green),
          ),
          const SizedBox(height: 36),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(label),
      ),
    );
  }
}
