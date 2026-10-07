import 'package:fylax_front/app/router.dart';
import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/core/widgets/fade_in_slide.dart';
import 'package:fylax_front/core/widgets/fylax_logo.dart';
import 'package:fylax_front/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de login (F1.1): "Sign in with Google" sin contraseña.
///
/// Dark-first: lienzo negro, marca con degradado azul → verde y entrada
/// escalonada de cada bloque. Si el consent screen no otorga el scope
/// gmail.readonly (F1.2), se muestra un mensaje explicativo.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final loading = authState is AuthLoading;

    ref.listen(authNotifierProvider, (prev, next) {
      if (next is AuthAuthenticated) context.go(AppRouter.onboarding);
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.9),
            radius: 1.4,
            colors: [Color(0xFF10263F), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                ...staggered(
                  [
                    const Center(child: FylaxLogo(size: 96)),
                    const SizedBox(height: 28),
                    Text(
                      'Fylax',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Tus gastos se registran solos.\nTú solo miras el panorama.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 17,
                          ),
                    ),
                  ],
                  step: const Duration(milliseconds: 140),
                ),
                const Spacer(flex: 3),
                ...staggered(
                  [
                    _GoogleButton(
                      loading: loading,
                      onPressed: loading
                          ? null
                          : () => ref
                              .read(authNotifierProvider.notifier)
                              .signInWithGoogle(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Solo lectura de tu correo (gmail.readonly). '
                            'Nunca enviamos ni borramos nada.',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  step: const Duration(milliseconds: 140),
                  initialDelay: const Duration(milliseconds: 420),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: loading ? 0.75 : 1,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: 56,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: AppColors.background,
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.background,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata_rounded, size: 30),
                    SizedBox(width: 4),
                    Text('Continuar con Google'),
                  ],
                ),
        ),
      ),
    );
  }
}
