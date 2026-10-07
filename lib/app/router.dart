import 'package:fylax_front/app/theme/app_theme.dart';
import 'package:fylax_front/features/auth/presentation/screens/login_screen.dart';
import 'package:fylax_front/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fylax_front/features/goals/presentation/screens/goal_form_screen.dart';
import 'package:fylax_front/features/goals/presentation/screens/goals_screen.dart';
import 'package:fylax_front/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fylax_front/features/profile/presentation/screens/profile_screen.dart';
import 'package:fylax_front/features/settings/presentation/screens/settings_screen.dart';
import 'package:fylax_front/features/transactions/domain/entities/transaction.dart';
import 'package:fylax_front/features/transactions/presentation/screens/transaction_form_screen.dart';
import 'package:fylax_front/features/transactions/presentation/screens/transactions_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Rutas de la aplicación.
///
/// Flujo: /login → /onboarding → shell principal (Inicio / Movimientos /
/// Propósitos / Perfil) con el formulario de gasto manual como página
/// modal encima. Configuración cuelga del perfil.
abstract final class AppRouter {
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const transactionsFeed = '/transactions';
  static const transactionForm = '/transactions/form';
  static const goals = '/goals';
  static const goalForm = '/goals/form';
  static const profile = '/profile';
  static const settings = '/settings';

  static final config = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: transactionsFeed,
                builder: (context, state) => const TransactionsFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: goals,
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: transactionForm,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: TransactionFormScreen(
            existing: state.extra as Transaction?,
          ),
        ),
      ),
      GoRoute(
        path: goalForm,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: GoalFormScreen(),
        ),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Estructura principal: barra de navegación inferior flotante con
/// indicador animado y botón central degradado para el gasto manual
/// (F3.3 — ≤ 3 toques desde cualquier pantalla).
class MainShell extends StatelessWidget {
  const MainShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      floatingActionButton: _AddExpenseFab(
        onPressed: () => context.push(AppRouter.transactionForm),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _FylaxNavBar(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(
          i,
          initialLocation: i == shell.currentIndex,
        ),
      ),
    );
  }
}

class _FylaxNavBar extends StatelessWidget {
  const _FylaxNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Movimientos',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              const SizedBox(width: 72), // hueco del FAB central
              Expanded(
                child: _NavItem(
                  icon: Icons.savings_rounded,
                  label: 'Propósitos',
                  selected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.green : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: selected ? 44 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: selected ? AppColors.brandGradient : null,
            ),
          ),
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddExpenseFab extends StatefulWidget {
  const _AddExpenseFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AddExpenseFab> createState() => _AddExpenseFabState();
}

class _AddExpenseFabState extends State<_AddExpenseFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) => Transform.scale(
          scale: 1 - _press.value * 0.08,
          child: child,
        ),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.brandGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
