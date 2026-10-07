import 'package:dartz/dartz.dart';
import 'package:fylax_front/core/errors/failure.dart';
import 'package:fylax_front/features/auth/domain/entities/user.dart';

/// Contrato de autenticación (PRD §Épica 1).
///
/// El login es "Sign in with Google" vía Supabase Auth. El OAuth debe
/// solicitar explícitamente el scope gmail.readonly (PRD §F1.2); sin él
/// la app muestra un mensaje explicativo y bloquea el onboarding.
abstract class AuthRepository {
  /// Inicia el flujo OAuth de Google y devuelve la sesión del usuario.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Registra/actualiza al usuario en el backend con el JWT de Supabase
  /// (POST /auth/session — PRD §9).
  Future<Either<Failure, User>> syncSessionWithBackend();

  Future<Either<Failure, Unit>> signOut();

  /// Útil para rutas protegidas y restablecimiento de sesión al arrancar.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Verdadero si el consent screen otorgó el scope gmail.readonly.
  Future<bool> hasGmailReadonlyScope();
}
