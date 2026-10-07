import 'package:fylax_front/app/router.dart';
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
      title: 'Cero digitación',
      body: 'Fylax detecta tus gastos automáticamente desde las alertas '
          'bancarias y recibos que llegan a tu correo. Tú nunca escribes '
          'una transacción.',
    ),
    _OnboardingStep(
      title: 'Tu correo, solo lectura',
      body: 'Pedimos acceso de solo lectura (gmail.readonly). Nunca enviamos, '
          'borramos ni modificamos correos; solo leemos recibos para '
          'registrar tus gastos.',
    ),
    _OnboardingStep(
      title: 'Primera sincronización',
      body: 'Vamos a revisar los últimos correos de tus bancos y comercios '
          'para mostrarte tu panorama financiero. Esto puede tomar '
          'unos minutos.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _steps[i].title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _steps[i].body,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () {
                  if (_page < _steps.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    context.go(AppRouter.dashboard);
                  }
                },
                child: Text(_page < _steps.length - 1 ? 'Siguiente' : 'Empezar'),
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
  const _OnboardingStep({required this.title, required this.body});
  final String title;
  final String body;
}
