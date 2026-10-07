import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de login (F1.1): "Sign in with Google" sin contraseña.
///
/// Si el consent screen no otorga el scope gmail.readonly (F1.2), se
/// muestra un mensaje explicativo de por qué Fylax necesita leer el correo.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next is AuthAuthenticated) {
        context.go(AppRouter.onboarding);
      }
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Fylax',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Tus gastos se registran solos.\nTú solo miras el panorama.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: authState is AuthLoading
                    ? null
                    : () => ref
                        .read(authNotifierProvider.notifier)
                        .signInWithGoogle(),
                icon: const Icon(Icons.login),
                label: const Text('Continuar con Google'),
              ),
              const SizedBox(height: 12),
              Text(
                'Solicitamos acceso de solo lectura a tu correo (gmail.readonly) '
                'para detectar automáticamente tus compras y pagos. '
                'Nunca leemos nada que no sea un recibo.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
