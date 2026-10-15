import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:fylax_front/features/auth/domain/entities/user.dart';
import 'package:fylax_front/features/auth/domain/repositories/auth_repository.dart';
import 'package:fylax_front/features/auth/domain/usecases/sign_in_with_google.dart';

/// Estado de autenticación (Riverpod — PRD §5.1).
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  /// [isNewSignIn] distingue un login recién hecho (→ onboarding) de una
  /// sesión restaurada al abrir la app (→ directo al dashboard).
  const AuthAuthenticated(this.user, {this.isNewSignIn = false});
  final User user;
  final bool isNewSignIn;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => sl<AuthRepository>(),
);

final signInWithGoogleProvider = Provider(
  (ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)),
);

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthInitial()) {
    _restoreSession();
  }

  final Ref _ref;

  /// Sesión persistente (F1.1): si Supabase guardó una sesión vigente,
  /// arranca autenticado sin pasar por el login.
  Future<void> _restoreSession() async {
    final result = await _ref.read(authRepositoryProvider).getCurrentUser();
    result.fold(
      (_) => state = const AuthUnauthenticated(),
      (user) => state = user == null
          ? const AuthUnauthenticated()
          : AuthAuthenticated(user),
    );
  }

  /// F1.1 — Sign in with Google. El scope gmail.readonly se valida en
  /// el repositorio; si falta, se expone AuthError con mensaje explicativo.
  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    final result = await _ref.read(signInWithGoogleProvider).call();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user, isNewSignIn: true),
    );
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    state = const AuthUnauthenticated();
  }
}
