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
  const AuthAuthenticated(this.user);
  final User user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

final authRepositoryProvider = Provider<AuthRepository>(
  // TODO(Fase 2): registrar AuthRepositoryImpl(sl()) en injection.dart.
  (ref) => throw UnimplementedError('Registrar AuthRepository en DI'),
);

final signInWithGoogleProvider = Provider(
  (ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)),
);

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthInitial());

  final Ref _ref;

  /// F1.1 — Sign in with Google. El scope gmail.readonly se valida en
  /// el repositorio; si falta, se expone AuthError con mensaje explicativo.
  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    final result = await _ref.read(signInWithGoogleProvider).call();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    state = const AuthUnauthenticated();
  }
}
