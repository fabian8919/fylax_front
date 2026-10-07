import 'package:fylax_front/features/auth/presentation/screens/login_screen.dart';
import 'package:fylax_front/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fylax_front/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fylax_front/features/transactions/presentation/screens/transaction_form_screen.dart';
import 'package:fylax_front/features/transactions/presentation/screens/transactions_feed_screen.dart';
import 'package:go_router/go_router.dart';

/// Rutas de la aplicación.
///
/// Flujo: /login → /onboarding → /dashboard (shell con feed y formulario).
abstract final class AppRouter {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const transactionsFeed = '/transactions';
  static const transactionForm = '/transactions/form';

  static final config = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: transactionsFeed,
        builder: (context, state) => const TransactionsFeedScreen(),
      ),
      GoRoute(
        path: transactionForm,
        builder: (context, state) => const TransactionFormScreen(),
      ),
    ],
  );
}
